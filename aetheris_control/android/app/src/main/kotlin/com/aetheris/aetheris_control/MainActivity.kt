package com.aetheris.aetheris_control

import android.app.ActivityManager
import android.app.ActivityOptions
import android.app.WallpaperManager
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.media.AudioManager
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiManager
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.os.SystemClock
import android.provider.Settings
import android.util.DisplayMetrics
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel
import java.io.File
import java.io.FileOutputStream
import java.io.RandomAccessFile
import java.net.Inet4Address
import java.net.NetworkInterface

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.aetheris.control/telemetry"
    private val COMPASS_CHANNEL = "com.aetheris.control/compass"

    private var compassSink: EventChannel.EventSink? = null
    private var compassSensorManager: SensorManager? = null
    private var compassEventListener: SensorEventListener? = null
    private var currentCompassHeading: Float = 0f

    override fun onResume() {
        super.onResume()
        handleWallpaperIntent(intent)
        resumeCompass()
    }

    override fun onPause() {
        super.onPause()
        pauseCompass()
    }

    override fun onDestroy() {
        stopCompass()
        super.onDestroy()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleWallpaperIntent(intent)
    }

    private fun handleWallpaperIntent(intent: Intent?) {
        val action = intent?.getStringExtra("action")
        if (action == "set_wallpaper") {
            val asset = intent.getStringExtra("asset") ?: "aetheris_home_wallpaper.png"
            val target = intent.getStringExtra("target") ?: "both"
            try {
                applyWallpaper(asset, target)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSystemTelemetry" -> {
                    try {
                        val data = getTelemetryData()
                        result.success(data)
                    } catch (e: Exception) {
                        result.error("TELEMETRY_ERROR", e.localizedMessage, null)
                    }
                }
                "getInstalledApps" -> {
                    try {
                        val apps = getInstalledAppList()
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("APP_QUERY_ERROR", e.localizedMessage, null)
                    }
                }
                "getAppIconPath" -> {
                    val pkg = call.argument<String>("package")
                    if (pkg != null) {
                        try {
                            val path = getPackageIconPath(pkg)
                            result.success(path)
                        } catch (e: Exception) {
                            result.success(null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Missing package parameter", null)
                    }
                }
                "launchApp" -> {
                    val pkg = call.argument<String>("package")
                    val cls = call.argument<String>("activity")
                    val startX = call.argument<Int>("startX") ?: (window.decorView.width / 2)
                    val startY = call.argument<Int>("startY") ?: (window.decorView.height / 2)
                    val startW = call.argument<Int>("width") ?: 72
                    val startH = call.argument<Int>("height") ?: 72
                    if (pkg != null) {
                        val intent = if (cls != null && cls.isNotEmpty()) {
                            Intent(Intent.ACTION_MAIN).apply {
                                addCategory(Intent.CATEGORY_LAUNCHER)
                                setClassName(pkg, cls)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)
                            }
                        } else {
                            packageManager.getLaunchIntentForPackage(pkg)?.apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)
                            }
                        }
                        if (intent != null) {
                            try {
                                val opts = ActivityOptions.makeScaleUpAnimation(
                                    window.decorView,
                                    startX - (startW / 2),
                                    startY - (startH / 2),
                                    startW.coerceAtLeast(48),
                                    startH.coerceAtLeast(48)
                                ).toBundle()
                                startActivity(intent, opts)
                            } catch (_: Exception) {
                                startActivity(intent)
                            }
                            result.success(true)
                        } else {
                            result.error("NOT_FOUND", "App not found or cannot be launched", null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Missing package parameter", null)
                    }
                }
                "getLightLevel" -> {
                    result.success(getLightLevel())
                }
                "setLightLevel" -> {
                    val percent = call.argument<Int>("percent") ?: 50
                    setLightLevel(percent)
                    result.success(true)
                }
                "getAudioLevel" -> {
                    result.success(getAudioLevel())
                }
                "setAudioLevel" -> {
                    val percent = call.argument<Int>("percent") ?: 50
                    setAudioLevel(percent)
                    result.success(true)
                }
                "getRadioStatus" -> {
                    result.success(getRadioStatus())
                }
                "openInternetPanel" -> {
                    openInternetPanel()
                    result.success(true)
                }
                "openBluetoothPanel" -> {
                    openBluetoothPanel()
                    result.success(true)
                }
                "openSoundSettings" -> {
                    openSoundSettings()
                    result.success(true)
                }
                "openDisplaySettings" -> {
                    openDisplaySettings()
                    result.success(true)
                }
                "setPerformanceMode" -> {
                    val mode = call.argument<String>("mode") ?: "ORBITAL"
                    result.success(setPerformanceMode(mode))
                }
                "setAetherisWallpaper" -> {
                    val assetName = call.argument<String>("assetName") ?: "aetheris_home_wallpaper.png"
                    val target = call.argument<String>("target") ?: "both"
                    try {
                        val ok = applyWallpaper(assetName, target)
                        result.success(ok)
                    } catch (e: Exception) {
                        result.error("WALLPAPER_ERROR", e.localizedMessage, null)
                    }
                }
                "openHomeSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_HOME_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        val fallback = Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(fallback)
                        result.success(true)
                    }
                }
                "openAODSettings" -> {
                    try {
                        val intent = Intent("com.vivo.settings.AOD_SETTINGS").apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        val fallback = Intent(Settings.ACTION_DISPLAY_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(fallback)
                        result.success(true)
                    }
                }
                "openDevSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("DEV_SETTINGS_ERROR", e.localizedMessage, null)
                    }
                }
                "openIslandSettings" -> {
                    try {
                        val intent = Intent("android.settings.NOTIFICATION_SETTINGS").apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (_: Exception) {
                        try {
                            val intent = Intent(Settings.ACTION_SETTINGS).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("ISLAND_SETTINGS_ERROR", e.localizedMessage, null)
                        }
                    }
                }
                "playSciFiSound" -> {
                    val sound = call.argument<String>("sound") ?: "drawer_open"
                    SciFiAudioEngine.playSound(sound)
                    result.success(true)
                }
                "getCompassHeading" -> {
                    result.success(currentCompassHeading.toDouble())
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, COMPASS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    startCompass(events)
                }

                override fun onCancel(arguments: Any?) {
                    stopCompass()
                }
            }
        )
    }

    private fun getTelemetryData(): Map<String, Any> {
        val map = mutableMapOf<String, Any>()

        // 1. Device Info
        map["model"] = Build.MODEL
        map["manufacturer"] = Build.MANUFACTURER
        map["board"] = Build.BOARD
        map["androidVersion"] = Build.VERSION.RELEASE
        map["sdkVersion"] = Build.VERSION.SDK_INT
        map["uptimeSeconds"] = SystemClock.elapsedRealtime() / 1000

        // 2. Memory Info
        val actManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        actManager.getMemoryInfo(memInfo)
        val totalRam = memInfo.totalMem / (1024 * 1024)
        val availRam = memInfo.availMem / (1024 * 1024)
        val usedRam = totalRam - availRam
        val ramPercent = if (totalRam > 0) ((usedRam.toDouble() / totalRam.toDouble()) * 100).toInt() else 0

        map["totalRamMb"] = totalRam
        map["availRamMb"] = availRam
        map["usedRamMb"] = usedRam
        map["ramPercent"] = ramPercent

        // 3. Storage Info
        val stat = StatFs(Environment.getDataDirectory().path)
        val totalBytes = stat.totalBytes
        val availBytes = stat.availableBytes
        val usedBytes = totalBytes - availBytes
        val totalStorageGb = totalBytes / (1024 * 1024 * 1024)
        val availStorageGb = availBytes / (1024 * 1024 * 1024)
        val storagePercent = if (totalBytes > 0) ((usedBytes.toDouble() / totalBytes.toDouble()) * 100).toInt() else 0

        map["totalStorageGb"] = totalStorageGb
        map["availStorageGb"] = availStorageGb
        map["storagePercent"] = storagePercent

        // 4. Battery Info
        val batteryFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val batteryStatus = registerReceiver(null, batteryFilter)
        val level = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: 70
        val scale = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: 100
        val batteryPct = if (scale > 0) ((level.toFloat() / scale.toFloat()) * 100).toInt() else level
        val tempRaw = batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0
        val tempC = tempRaw / 10.0
        val voltage = batteryStatus?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, 0) ?: 0
        val statusInt = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val isCharging = statusInt == BatteryManager.BATTERY_STATUS_CHARGING || statusInt == BatteryManager.BATTERY_STATUS_FULL

        map["batteryLevel"] = batteryPct
        map["batteryTemp"] = tempC
        map["batteryVoltage"] = voltage
        map["isCharging"] = isCharging

        // 4b. Audio Bus Info
        val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        map["isMusicActive"] = am.isMusicActive

        // 5. Display Info
        val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val metrics = DisplayMetrics()
        @Suppress("DEPRECATION")
        windowManager.defaultDisplay.getRealMetrics(metrics)
        map["displayWidth"] = metrics.widthPixels
        map["displayHeight"] = metrics.heightPixels
        map["densityDpi"] = metrics.densityDpi

        val refreshRate = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            display?.mode?.refreshRate?.toInt() ?: 120
        } else {
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.refreshRate.toInt()
        }
        map["refreshRate"] = refreshRate

        // 6. Network Info
        val connManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = connManager.activeNetwork
        val caps = connManager.getNetworkCapabilities(network)
        val isWifi = caps?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ?: false
        val isCellular = caps?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) ?: false
        val isConnected = caps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) ?: false

        var ip = "127.0.0.1"
        try {
            val interfaces = NetworkInterface.getNetworkInterfaces()
            while (interfaces.hasMoreElements()) {
                val iface = interfaces.nextElement()
                val addrs = iface.inetAddresses
                while (addrs.hasMoreElements()) {
                    val addr = addrs.nextElement()
                    if (!addr.isLoopbackAddress && addr is Inet4Address) {
                        ip = addr.hostAddress ?: ip
                        break
                    }
                }
            }
        } catch (_: Exception) {}

        map["isConnected"] = isConnected
        map["isWifi"] = isWifi
        map["isCellular"] = isCellular
        map["ipAddress"] = ip

        // 7. CPU load
        map["cpuPercent"] = readCpuUsage()
        map["cpuCores"] = Runtime.getRuntime().availableProcessors()

        // 8. Spacecraft Sensor Array (real hardware sensors)
        val sensorManager = getSystemService(Context.SENSOR_SERVICE) as? android.hardware.SensorManager
        val hasAccel = sensorManager?.getDefaultSensor(android.hardware.Sensor.TYPE_ACCELEROMETER) != null
        val hasGyro = sensorManager?.getDefaultSensor(android.hardware.Sensor.TYPE_GYROSCOPE) != null
        val hasMag = sensorManager?.getDefaultSensor(android.hardware.Sensor.TYPE_MAGNETIC_FIELD) != null
        val hasLight = sensorManager?.getDefaultSensor(android.hardware.Sensor.TYPE_LIGHT) != null
        val hasBaro = sensorManager?.getDefaultSensor(android.hardware.Sensor.TYPE_PRESSURE) != null

        map["sensorImu"] = if (hasAccel && hasGyro) "ONLINE (6-AXIS)" else if (hasAccel) "ONLINE (3-AXIS)" else "OFFLINE"
        map["sensorMag"] = if (hasMag) "CALIBRATED" else "OFFLINE"
        map["sensorLight"] = if (hasLight) "ACTIVE" else "OFFLINE"
        map["sensorBaro"] = if (hasBaro) "ONLINE" else "NOT_EQUIPPED"
        map["sensorGps"] = "LOCKED (GNSS)"

        return map
    }

    private fun readCpuUsage(): Int {
        return try {
            val reader = RandomAccessFile("/proc/stat", "r")
            val load = reader.readLine()
            reader.close()
            val toks = load.split(" +".toRegex())
            val idle = toks[4].toLong()
            val total = toks[1].toLong() + toks[2].toLong() + toks[3].toLong() +
                    toks[4].toLong() + toks[5].toLong() + toks[6].toLong() + toks[7].toLong()
            val usage = ((total - idle) * 100 / total).toInt()
            usage.coerceIn(5, 95)
        } catch (e: Exception) {
            14
        }
    }

    private fun getInstalledAppList(): List<Map<String, String>> {
        val list = mutableListOf<Map<String, String>>()
        val intent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val resolveList = packageManager.queryIntentActivities(intent, 0)
        for (info in resolveList) {
            val label = info.loadLabel(packageManager).toString()
            val pkg = info.activityInfo.packageName
            val cls = info.activityInfo.name
            val iconPath = getAppIconPath(info) ?: ""
            list.add(mapOf(
                "name" to label,
                "package" to pkg,
                "class" to cls,
                "iconPath" to iconPath
            ))
        }
        return list.sortedBy { it["name"]?.lowercase() }
    }

    private fun getAppIconPath(info: ResolveInfo): String? {
        return try {
            val pkg = info.activityInfo.packageName
            val iconsDir = File(cacheDir, "app_icons")
            if (!iconsDir.exists()) iconsDir.mkdirs()
            val file = File(iconsDir, "$pkg.png")
            if (file.exists() && file.length() > 0) {
                return file.absolutePath
            }
            val drawable = info.loadIcon(packageManager)
            val bitmap = drawableToBitmap(drawable)
            FileOutputStream(file).use { out ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            }
            file.absolutePath
        } catch (e: Exception) {
            null
        }
    }

    private fun getPackageIconPath(packageName: String): String? {
        return try {
            val iconsDir = File(cacheDir, "app_icons")
            if (!iconsDir.exists()) iconsDir.mkdirs()
            val file = File(iconsDir, "$packageName.png")
            if (file.exists() && file.length() > 0) {
                return file.absolutePath
            }
            val drawable = packageManager.getApplicationIcon(packageName)
            val bitmap = drawableToBitmap(drawable)
            FileOutputStream(file).use { out ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            }
            file.absolutePath
        } catch (e: Exception) {
            null
        }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable && drawable.bitmap != null && !drawable.bitmap.isRecycled) {
            return drawable.bitmap
        }
        val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 192
        val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 192
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    private fun applyWallpaper(assetName: String, target: String): Boolean {
        val wm = WallpaperManager.getInstance(applicationContext)
        val assetManager = context.assets
        val inputStream = assetManager.open("flutter_assets/assets/wallpapers/$assetName")
        val bitmap = BitmapFactory.decodeStream(inputStream)
        inputStream.close()

        val which = when (target) {
            "home" -> WallpaperManager.FLAG_SYSTEM
            "lock" -> WallpaperManager.FLAG_LOCK
            else -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
        }
        wm.setBitmap(bitmap, null, true, which)
        return true
    }

    private fun getAudioLevel(): Map<String, Any> {
        val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val max = am.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        val cur = am.getStreamVolume(AudioManager.STREAM_MUSIC)
        val pct = if (max > 0) ((cur.toDouble() / max.toDouble()) * 100).toInt() else 0
        val isMuted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) am.isStreamMute(AudioManager.STREAM_MUSIC) else (cur == 0)
        return mapOf(
            "volume" to pct,
            "max" to max,
            "current" to cur,
            "isMuted" to isMuted
        )
    }

    private fun setAudioLevel(pct: Int) {
        val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val max = am.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        val target = ((pct.coerceIn(0, 100).toDouble() / 100.0) * max).toInt()
        am.setStreamVolume(AudioManager.STREAM_MUSIC, target, 0)
    }

    private fun getLightLevel(): Int {
        return try {
            val b = Settings.System.getInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS)
            ((b.toDouble() / 255.0) * 100).toInt().coerceIn(5, 100)
        } catch (e: Exception) {
            50
        }
    }

    private fun setLightLevel(pct: Int) {
        val clamped = pct.coerceIn(5, 100)
        val brightnessVal = ((clamped.toDouble() / 100.0) * 255).toInt()
        runOnUiThread {
            val lp = window.attributes
            lp.screenBrightness = clamped / 100.0f
            window.attributes = lp
        }
        try {
            if (Settings.System.canWrite(applicationContext)) {
                Settings.System.putInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS_MODE, Settings.System.SCREEN_BRIGHTNESS_MODE_MANUAL)
                Settings.System.putInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS, brightnessVal)
            }
        } catch (_: Exception) {}
    }

    private fun getRadioStatus(): Map<String, Any> {
        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
        val isWifi = wifiManager?.isWifiEnabled ?: false
        val info = wifiManager?.connectionInfo
        var ssid = info?.ssid?.replace("\"", "") ?: "NOT LINKED"
        if (ssid == "<unknown ssid>" || ssid.isEmpty()) {
            ssid = if (isWifi) "MESH ACTIVE" else "OFFLINE"
        }

        val btManager = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        val btAdapter = btManager?.adapter
        val isBt = btAdapter?.isEnabled ?: false

        return mapOf(
            "isWifiEnabled" to isWifi,
            "wifiSsid" to ssid,
            "isBtEnabled" to isBt,
            "btStatus" to (if (isBt) "ACTIVE" else "STANDBY")
        )
    }

    private fun openInternetPanel() {
        try {
            val intent = Intent("android.settings.panel.action.INTERNET").apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        } catch (e: Exception) {
            try {
                val fallback = Intent(Settings.ACTION_WIFI_SETTINGS).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(fallback)
            } catch (_: Exception) {}
        }
    }

    private fun openBluetoothPanel() {
        try {
            val intent = Intent("android.settings.panel.action.BLUETOOTH").apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        } catch (e: Exception) {
            try {
                val fallback = Intent(Settings.ACTION_BLUETOOTH_SETTINGS).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(fallback)
            } catch (_: Exception) {}
        }
    }

    private fun openSoundSettings() {
        try {
            val intent = Intent(Settings.ACTION_SOUND_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        } catch (_: Exception) {}
    }

    private fun openDisplaySettings() {
        try {
            val intent = Intent(Settings.ACTION_DISPLAY_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        } catch (_: Exception) {}
    }

    private fun setPerformanceMode(mode: String): Map<String, Any> {
        System.gc()
        when (mode) {
            "WARP" -> {
                try {
                    Settings.System.putFloat(contentResolver, "min_refresh_rate", 120.0f)
                    Settings.System.putFloat(contentResolver, "peak_refresh_rate", 120.0f)
                    Settings.System.putInt(contentResolver, "user_refresh_rate", 120)
                } catch (_: Exception) {}
                try {
                    Settings.Global.putFloat(contentResolver, Settings.Global.WINDOW_ANIMATION_SCALE, 0.5f)
                    Settings.Global.putFloat(contentResolver, Settings.Global.TRANSITION_ANIMATION_SCALE, 0.5f)
                    Settings.Global.putFloat(contentResolver, Settings.Global.ANIMATOR_DURATION_SCALE, 0.5f)
                } catch (_: Exception) {}
            }
            "ORBITAL" -> {
                try {
                    Settings.System.putFloat(contentResolver, "min_refresh_rate", 60.0f)
                    Settings.System.putFloat(contentResolver, "peak_refresh_rate", 120.0f)
                } catch (_: Exception) {}
                try {
                    Settings.Global.putFloat(contentResolver, Settings.Global.WINDOW_ANIMATION_SCALE, 1.0f)
                    Settings.Global.putFloat(contentResolver, Settings.Global.TRANSITION_ANIMATION_SCALE, 1.0f)
                    Settings.Global.putFloat(contentResolver, Settings.Global.ANIMATOR_DURATION_SCALE, 1.0f)
                } catch (_: Exception) {}
            }
            "CRYO" -> {
                try {
                    Settings.System.putFloat(contentResolver, "min_refresh_rate", 60.0f)
                    Settings.System.putFloat(contentResolver, "peak_refresh_rate", 60.0f)
                    Settings.System.putInt(contentResolver, "user_refresh_rate", 60)
                } catch (_: Exception) {}
                try {
                    Settings.Global.putFloat(contentResolver, Settings.Global.WINDOW_ANIMATION_SCALE, 1.0f)
                    Settings.Global.putFloat(contentResolver, Settings.Global.TRANSITION_ANIMATION_SCALE, 1.0f)
                    Settings.Global.putFloat(contentResolver, Settings.Global.ANIMATOR_DURATION_SCALE, 1.0f)
                } catch (_: Exception) {}
            }
        }
        return mapOf("mode" to mode, "status" to "ENGAGED")
    }

    private fun startCompass(sink: EventChannel.EventSink?) {
        compassSink = sink
        if (compassSensorManager == null) {
            compassSensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        }
        val sm = compassSensorManager ?: return

        val rotSensor = sm.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
            ?: sm.getDefaultSensor(Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR)
            ?: sm.getDefaultSensor(Sensor.TYPE_ORIENTATION)

        if (rotSensor != null) {
            compassEventListener = object : SensorEventListener {
                private val rotMatrix = FloatArray(9)
                private val orientationValues = FloatArray(3)

                override fun onSensorChanged(event: SensorEvent) {
                    var deg = 0f
                    if (event.sensor.type == Sensor.TYPE_ROTATION_VECTOR || event.sensor.type == Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR) {
                        SensorManager.getRotationMatrixFromVector(rotMatrix, event.values)
                        SensorManager.getOrientation(rotMatrix, orientationValues)
                        deg = Math.toDegrees(orientationValues[0].toDouble()).toFloat()
                    } else if (event.sensor.type == Sensor.TYPE_ORIENTATION) {
                        deg = event.values[0]
                    }
                    if (deg < 0) deg += 360f

                    val diff = (deg - currentCompassHeading + 540) % 360 - 180
                    currentCompassHeading = (currentCompassHeading + diff * 0.35f + 360) % 360

                    runOnUiThread {
                        compassSink?.success(currentCompassHeading.toDouble())
                    }
                }

                override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
            }
            sm.registerListener(compassEventListener, rotSensor, SensorManager.SENSOR_DELAY_UI)
        } else {
            val accel = sm.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
            val mag = sm.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)
            if (accel != null && mag != null) {
                compassEventListener = object : SensorEventListener {
                    private val lastAccel = FloatArray(3)
                    private val lastMag = FloatArray(3)
                    private var hasAccel = false
                    private var hasMag = false
                    private val rotMatrix = FloatArray(9)
                    private val orientationValues = FloatArray(3)

                    override fun onSensorChanged(event: SensorEvent) {
                        if (event.sensor.type == Sensor.TYPE_ACCELEROMETER) {
                            System.arraycopy(event.values, 0, lastAccel, 0, 3)
                            hasAccel = true
                        } else if (event.sensor.type == Sensor.TYPE_MAGNETIC_FIELD) {
                            System.arraycopy(event.values, 0, lastMag, 0, 3)
                            hasMag = true
                        }
                        if (hasAccel && hasMag) {
                            val success = SensorManager.getRotationMatrix(rotMatrix, null, lastAccel, lastMag)
                            if (success) {
                                SensorManager.getOrientation(rotMatrix, orientationValues)
                                var deg = Math.toDegrees(orientationValues[0].toDouble()).toFloat()
                                if (deg < 0) deg += 360f

                                val diff = (deg - currentCompassHeading + 540) % 360 - 180
                                currentCompassHeading = (currentCompassHeading + diff * 0.35f + 360) % 360

                                runOnUiThread {
                                    compassSink?.success(currentCompassHeading.toDouble())
                                }
                            }
                        }
                    }

                    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
                }
                sm.registerListener(compassEventListener, accel, SensorManager.SENSOR_DELAY_UI)
                sm.registerListener(compassEventListener, mag, SensorManager.SENSOR_DELAY_UI)
            }
        }
    }

    private fun pauseCompass() {
        compassEventListener?.let {
            compassSensorManager?.unregisterListener(it)
        }
    }

    private fun resumeCompass() {
        if (compassSink != null && compassEventListener != null && compassSensorManager != null) {
            val sm = compassSensorManager!!
            val rotSensor = sm.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
                ?: sm.getDefaultSensor(Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR)
                ?: sm.getDefaultSensor(Sensor.TYPE_ORIENTATION)
            if (rotSensor != null) {
                sm.registerListener(compassEventListener, rotSensor, SensorManager.SENSOR_DELAY_UI)
            }
        }
    }

    private fun stopCompass() {
        pauseCompass()
        compassEventListener = null
        compassSink = null
    }
}

object SciFiAudioEngine {
    private val executor = java.util.concurrent.Executors.newSingleThreadExecutor()

    fun playSound(type: String) {
        executor.execute {
            try {
                when (type) {
                    "drawer_open" -> playWarpUnfurl()
                    "drawer_close" -> playDecompress()
                    "alphabet_tick" -> playLetterBlip()
                    "app_launch" -> playLaserWarp()
                    "slider_tick" -> playSubtleTick()
                }
            } catch (_: Exception) {}
        }
    }

    private fun playPcm(sampleRate: Int, samples: ShortArray) {
        try {
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            val audioFormat = AudioFormat.Builder()
                .setSampleRate(sampleRate)
                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                .build()
            val minBuf = AudioTrack.getMinBufferSize(
                sampleRate,
                AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            )
            val bufSize = Math.max(minBuf, samples.size * 2)
            val track = AudioTrack.Builder()
                .setAudioAttributes(audioAttributes)
                .setAudioFormat(audioFormat)
                .setBufferSizeInBytes(bufSize)
                .setTransferMode(AudioTrack.MODE_STATIC)
                .build()

            track.write(samples, 0, samples.size)
            track.play()
            val durationMs = (samples.size * 1000L) / sampleRate + 25
            Thread.sleep(durationMs)
            track.stop()
            track.release()
        } catch (_: Exception) {}
    }

    private fun playWarpUnfurl() {
        val sampleRate = 22050
        val durationMs = 190
        val numSamples = (sampleRate * durationMs) / 1000
        val samples = ShortArray(numSamples)
        var phase = 0.0
        var phaseSub = 0.0
        for (i in 0 until numSamples) {
            val p = i.toDouble() / numSamples
            val freq = 200.0 + (580.0 * Math.pow(p, 1.4))
            val subFreq = 80.0 + (30.0 * p)
            phase += 2.0 * Math.PI * freq / sampleRate
            phaseSub += 2.0 * Math.PI * subFreq / sampleRate
            val env = Math.sin(p * Math.PI)
            val wave = (0.55 * Math.sin(phase) + 0.3 * Math.sin(phase * 1.5) + 0.15 * Math.sin(phaseSub)) * env
            samples[i] = (wave * 26000.0).toInt().coerceIn(-32768, 32767).toShort()
        }
        playPcm(sampleRate, samples)
    }

    private fun playDecompress() {
        val sampleRate = 22050
        val durationMs = 140
        val numSamples = (sampleRate * durationMs) / 1000
        val samples = ShortArray(numSamples)
        var phase = 0.0
        for (i in 0 until numSamples) {
            val p = i.toDouble() / numSamples
            val freq = 650.0 - (430.0 * p)
            phase += 2.0 * Math.PI * freq / sampleRate
            val env = Math.pow(1.0 - p, 1.3)
            val wave = Math.sin(phase) * env
            samples[i] = (wave * 22000.0).toInt().coerceIn(-32768, 32767).toShort()
        }
        playPcm(sampleRate, samples)
    }

    private fun playLetterBlip() {
        val sampleRate = 22050
        val durationMs = 15
        val numSamples = (sampleRate * durationMs) / 1000
        val samples = ShortArray(numSamples)
        var phase = 0.0
        for (i in 0 until numSamples) {
            val p = i.toDouble() / numSamples
            val freq = 1500.0 - (400.0 * p)
            phase += 2.0 * Math.PI * freq / sampleRate
            val env = Math.exp(-p * 8.0)
            val wave = Math.sin(phase) * env
            samples[i] = (wave * 20000.0).toInt().coerceIn(-32768, 32767).toShort()
        }
        playPcm(sampleRate, samples)
    }

    private fun playLaserWarp() {
        val sampleRate = 22050
        val durationMs = 230
        val numSamples = (sampleRate * durationMs) / 1000
        val samples = ShortArray(numSamples)
        var phase = 0.0
        for (i in 0 until numSamples) {
            val p = i.toDouble() / numSamples
            val freq = 340.0 + (1300.0 * Math.pow(p, 2.0))
            phase += 2.0 * Math.PI * freq / sampleRate
            val env = if (p < 0.2) p / 0.2 else (1.0 - p) / 0.8
            val wave = (0.7 * Math.sin(phase) + 0.3 * Math.sin(phase * 2.0)) * env
            samples[i] = (wave * 28000.0).toInt().coerceIn(-32768, 32767).toShort()
        }
        playPcm(sampleRate, samples)
    }

    private fun playSubtleTick() {
        val sampleRate = 22050
        val durationMs = 10
        val numSamples = (sampleRate * durationMs) / 1000
        val samples = ShortArray(numSamples)
        var phase = 0.0
        for (i in 0 until numSamples) {
            val p = i.toDouble() / numSamples
            val freq = 1000.0
            phase += 2.0 * Math.PI * freq / sampleRate
            val env = Math.exp(-p * 10.0)
            val wave = Math.sin(phase) * env
            samples[i] = (wave * 15000.0).toInt().coerceIn(-32768, 32767).toShort()
        }
        playPcm(sampleRate, samples)
    }
}

