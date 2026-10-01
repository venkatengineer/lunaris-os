# AETHERIS / SOLARIS OS MOBILE // CONFIGURATION & REVERSIBILITY LOG
**Target Device:** Vivo V40 5G (Model `V2348`) • **Serial:** `10BECB0R9D006EA`
**System Firmware:** Android 16 (SDK 36, VOS 7.0) • **Patch:** 2026-08-01

---

## 1. APPLIED SYSTEM CHANGES & CONFIGURATIONS

| Subsystem | Change Applied | Tool / Command Used | Reversible State |
| :--- | :--- | :--- | :--- |
| **Default Home Launcher** | Set to `com.aetheris.aetheris_control/.MainActivity` | `cmd package set-home-activity com.aetheris.aetheris_control/.MainActivity` | Can revert to Vivo stock launcher (`com.android.launcher3`) at any time |
| **Display Refresh Rate** | Enforced 120Hz smooth refresh rate | `settings put system min_refresh_rate 120.0`<br>`settings put system peak_refresh_rate 120.0`<br>`settings put system user_refresh_rate 120` | Default is adaptive 60/90/120Hz |
| **System UI Animations** | Calibrated to snappy 0.5x aerospace response (150–250ms) | `settings put global window_animation_scale 0.5`<br>`settings put global transition_animation_scale 0.5`<br>`settings put global animator_duration_scale 0.5` | Default is `1.0` |
| **Material You (Monet) Palette** | Set system accent to Aetheris Emerald (`#00ff88`) | `settings put secure theme_customization_overlay_packages ...` | Stored in backup |
| **Display Timeout** | Set to 10 minutes while connected | `settings put system screen_off_timeout 600000` | Default is 30000 (30s) |
| **Wireless Debugging** | Enabled TCP/IP port 5555 | `adb tcpip 5555` (Connected at `10.128.10.31:5555`) | Disables on reboot or `adb usb` |
| **Wallpapers** | Pushed clean OLED obsidian & emerald aerospace wallpapers | Pushed to `/sdcard/Pictures/Aetheris/` | Stock wallpapers preserved |
| **Quick Settings Tile** | Deployed `AetherisTileService` (Aetheris HUD) | Manifest declaration in `com.aetheris.aetheris_control` | Removable via notification shade edit |
| **Telemetry Widget** | Deployed `AetherisWidgetProvider` RemoteViews widget | Registered with Android `AppWidgetManager` | Removable via home screen widget manager |
| **Solaris Core & Visual Identity** | Integrated signature interactive astrolabe core, controlled asymmetry, floating vector icons, open HUD telemetry disclosure | `lib/main.dart` & `assets/icons/` | Fully reversible |

---

## 2. SOLARIS VISUAL IDENTITY EVOLUTION (2040 SPACECRAFT OS)
- **Signature Solaris Core:** Precision geometric solar core + inner hexagonal aperture + rotating orbital arc track + cardinal graduation ticks. Ambient 45s cycle + 220ms damped spring touch reaction that expands/contracts secondary hardware telemetry.
- **Controlled Asymmetry:** Off-axis clock with superscript seconds & dynamic calendar on the left; Solaris Core on the right.
- **Elimination of Rectangular Dependencies:** Zero enclosing boxes around icons, status line, dock, or app drawer affordance.
- **Floating Vector Glyphs:** 20 canonical application icons generated with 4x supersampling and subtle atmospheric halo glow on 100% transparent backgrounds.
- **Integrated Dock:** Seamless glass shelf with top hairline gradient border naturally anchoring quick apps.
- **Zero Overflow & 120 FPS Performance:** Streamlined micro-metric telemetry line and hardware acceleration.

---

## 3. SOLARIS OS — SPACESHIP COCKPIT TRANSFORMATION
The phone is now transformed into the **primary flight bridge computer of the spacecraft SOLARIS**:
- **Deep Space Celestial Starfield:** Multi-depth breathing star canvas with 18 celestial stars, orbital canopy arc, and deep vignette.
- **Star Tracker / Nav Viewport:** Real-time 25° inclined orbital trajectory, cardinal graduation ticks (`000°`, `090°`, `180°`, `270°`), spacecraft heading chevron reticle, and active waypoint marker completing a 90-second orbital circuit.
- **Flight Pillars HUD (4-Column Telemetry):**
  - `POWER`: Real battery status, dynamic transfer state (`TRANSFER ⚡`, `RESERVE`, `NOMINAL`).
  - `CORE`: Real CPU utilization (`NOMINAL` / `BURST`).
  - `PROPULSION`: Dynamic compute load indicator (`ACTIVE` / `IDLE IMPULSE`).
  - `COMMS`: Real Wi-Fi/Cellular connectivity (`ONLINE 5G MESH`).
- **Interactive Telemetry Disclosure:** Tapping the flight pillars unfolds the hardware telemetry panel (Snapdragon 7 Gen 3, ZEISS 50MP optical array, BlueVolt battery thermal readout, available RAM, and live hardware sensor feeds).
- **Live Hardware Sensor Array Integration:** Native Kotlin layer (`MainActivity.kt`) interfaces directly with Vivo hardware sensors (`SensorManager`): IMU 6-axis, 3-axis Magnetometer, Ambient Light flux detector, and GNSS status.
- **Mission Vector Cycling:** Configurable active mission strip (`EXPEDITION-7`, `DEEP MATRIX`, `FLIGHT CADENCE`, `STANDBY VOYAGE`), cycleable on tap.
- **Spacecraft Systems Architecture:** Applications categorized and styled as onboard systems:
  - `NAV` (Maps), `COMMS` (Dialer), `RELAY` (Messages), `OPTICAL` (Camera), `STORAGE` (Files), `SYSTEMS` (Settings), `ENGINEERING` (Termux), `ACOUSTIC` (Spotify).
- **180ms HUD Initiation Transition:** Instant feedback banner (`ENGAGING <SYSTEM>...`) with haptic pulse upon launching ship systems.
- **Authentic Original Android App Icons:** Complete native extraction pipeline via `MainActivity.kt` (`info.loadIcon(packageManager)`) caching genuine high-resolution system app icons into application cache. Replaced all placeholder/paint vector glyphs with the phone's official Android app icons across the Home Screen Bridge, Integrated Dock, and All Ship Systems Matrix.
- **Engineering Deck (Deck 1):** Dedicated secondary console with hardware propulsion metrics, BlueVolt life support power bus, sensor diagnostics, and direct system shortcuts.

---

## 4. BACKUP DATA ARCHIVE

Full raw setting dumps are saved on host at:
- `/home/venkatengineer/aetheris_mobile_backup/settings_global_backup.txt`
- `/home/venkatengineer/aetheris_mobile_backup/settings_secure_backup.txt`
- `/home/venkatengineer/aetheris_mobile_backup/settings_system_backup.txt`

---

## 5. COMPLETE ROLLBACK PROCEDURE

To restore stock Vivo settings at any time without reboot:

### A. Restore Stock Vivo Launcher:
```bash
adb shell cmd package set-home-activity com.android.launcher3/com.bbk.launcher2.Launcher
```

### B. Restore Standard Animation Speeds:
```bash
adb shell settings put global window_animation_scale 1.0
adb shell settings put global transition_animation_scale 1.0
adb shell settings put global animator_duration_scale 1.0
```

### C. Restore Default Refresh Rate (Adaptive):
```bash
adb shell settings delete system min_refresh_rate
adb shell settings put system peak_refresh_rate 120.0
adb shell settings delete system user_refresh_rate
```

### D. Restore Default Material You Theme Accent:
```bash
adb shell settings put secure theme_customization_overlay_packages '{"_applied_timestamp":1786930774784,"material_you_overlay_enable":1,"android.theme.customization.color_screen":1,"android.theme.customization.color_index":"0","android.theme.customization.theme_style":"TONAL_SPOT","android.theme.customization.color_source":"preset","android.theme.customization.system_palette":"0023ff","android.theme.customization.accent_color":"0023ff"}'
```

### E. Uninstall Aetheris Mobile App (Optional):
```bash
adb uninstall com.aetheris.aetheris_control
```
