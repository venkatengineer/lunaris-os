import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const SolarisApp());
}

// =============================================================================
// SOLARIS SPACING & DESIGN TOKENS (CALM, RESTRAINED, AEROSPACE)
// =============================================================================
class SolarisSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

class SolarisColors {
  // Deep Space Matte Surfaces (90%)
  static const Color spaceBlack = Color(0xFF020408);
  static const Color cockpitGlass = Color(0xEE070D16);
  static const Color surfaceElevated = Color(0xF50B1420);
  static const Color cardBg = Color(0xCC0A121D);
  static const Color border = Color(0x2E00E5FF); // 18% cyan hairline
  static const Color borderBright = Color(0x8000E5FF); // 50% cyan
  static const Color borderMuted = Color(0x14FFFFFF); // 8% white hairline
  static const Color divider = Color(0x1E00E5FF);

  // Active Flight Accents (8%)
  static const Color cyan = Color(0xFF00E5FF);
  static const Color emerald = Color(0xFF00E676);
  static const Color purple = Color(0xFFA855F7);

  // Warnings / Flight Alerts (2%)
  static const Color amber = Color(0xFFFFB300);
  static const Color crimson = Color(0xFFFF1744);

  // Typography Hierarchy
  static const Color textPrimary = Color(0xFFECEFF1);
  static const Color textSecondary = Color(0xFF90A4AE);
  static const Color textMuted = Color(0xFF546E7A);
}

class SolarisApp extends StatelessWidget {
  const SolarisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solaris OS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: SolarisColors.spaceBlack,
        fontFamily: 'Rajdhani',
        colorScheme: const ColorScheme.dark(
          primary: SolarisColors.cyan,
          secondary: SolarisColors.emerald,
          surface: SolarisColors.cockpitGlass,
        ),
      ),
      home: const SolarisHomeScreen(),
    );
  }
}

// =============================================================================
// DEEP SPACE STARFIELD LAYER (CALM, SUBTLE, BREATHING CELESTIAL POINTS)
// =============================================================================
class StarfieldPainter extends CustomPainter {
  final double shimmer;

  // Fixed deterministic celestial star coordinates
  static final List<Offset> _fixedStars = [
    const Offset(0.12, 0.08), const Offset(0.85, 0.06), const Offset(0.48, 0.14),
    const Offset(0.24, 0.22), const Offset(0.72, 0.19), const Offset(0.92, 0.28),
    const Offset(0.08, 0.36), const Offset(0.38, 0.42), const Offset(0.64, 0.38),
    const Offset(0.88, 0.48), const Offset(0.15, 0.58), const Offset(0.52, 0.64),
    const Offset(0.78, 0.62), const Offset(0.28, 0.74), const Offset(0.90, 0.78),
    const Offset(0.10, 0.86), const Offset(0.44, 0.90), const Offset(0.82, 0.94),
  ];

  StarfieldPainter({required this.shimmer});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep Space Vignette
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.3),
        radius: 1.2,
        colors: [
          const Color(0xFF050B14),
          SolarisColors.spaceBlack,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Faint Orbital Arc (Curving across upper canopy)
    final arcPaint = Paint()
      ..color = SolarisColors.cyan.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.15), radius: size.width * 0.9),
      0.1,
      math.pi * 0.8,
      false,
      arcPaint,
    );

    // 3. Tiny Distant Celestial Stars
    for (int i = 0; i < _fixedStars.length; i++) {
      final pos = _fixedStars[i];
      final px = pos.dx * size.width;
      final py = pos.dy * size.height;

      final phase = (shimmer + (i * 0.18)) % 1.0;
      final alpha = 0.20 + (math.sin(phase * 2 * math.pi) * 0.18).abs();
      final radius = (i % 3 == 0) ? 1.4 : 0.9;

      final starPaint = Paint()
        ..color = ((i % 4 == 0) ? SolarisColors.cyan : SolarisColors.textPrimary)
            .withOpacity(alpha.clamp(0.05, 0.65))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(px, py), radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) {
    return oldDelegate.shimmer != shimmer;
  }
}

// =============================================================================
// SIGNATURE NAVIGATION VIEWPORT / STAR TRACKER (SPACECRAFT RETICLE + ORBIT)
// =============================================================================
class SolarisNavViewportWidget extends StatefulWidget {
  final bool isExpanded;
  final double heading;
  final String cardinal;
  final VoidCallback onTap;

  const SolarisNavViewportWidget({
    super.key,
    required this.isExpanded,
    this.heading = 0.0,
    this.cardinal = 'N',
    required this.onTap,
  });

  @override
  State<SolarisNavViewportWidget> createState() => _SolarisNavViewportWidgetState();
}

class _SolarisNavViewportWidgetState extends State<SolarisNavViewportWidget>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 90),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _pulseController.forward(from: 0.0).then((_) {
      if (mounted) _pulseController.reverse();
    });
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_orbitController, _pulseAnimation]),
        builder: (context, _) {
          return CustomPaint(
            size: const Size(82, 82),
            painter: SolarisNavViewportPainter(
              heading: widget.heading,
              cardinal: widget.cardinal,
              orbitProgress: _orbitController.value,
              pulse: _pulseAnimation.value,
              isExpanded: widget.isExpanded,
            ),
          );
        },
      ),
    );
  }
}

class SolarisNavViewportPainter extends CustomPainter {
  final double heading;
  final String cardinal;
  final double orbitProgress;
  final double pulse;
  final bool isExpanded;

  SolarisNavViewportPainter({
    required this.heading,
    required this.cardinal,
    required this.orbitProgress,
    required this.pulse,
    required this.isExpanded,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final maxR = size.width / 2;

    // 1. Dark circular backing radar glass
    final bgPaint = Paint()
      ..color = const Color(0xCC060D19)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxR - 2.0, bgPaint);

    final outerRingPaint = Paint()
      ..color = SolarisColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, maxR - 2.0, outerRingPaint);

    // 2. Fixed Aircraft/Ship Forward Reference Marker at 12 o'clock (Top)
    final fixedMarkerPath = Path();
    fixedMarkerPath.moveTo(cx, cy - maxR + 1.0);
    fixedMarkerPath.lineTo(cx - 3.5, cy - maxR + 6.0);
    fixedMarkerPath.lineTo(cx + 3.5, cy - maxR + 6.0);
    fixedMarkerPath.close();
    final markerPaint = Paint()
      ..color = SolarisColors.cyan
      ..style = PaintingStyle.fill;
    canvas.drawPath(fixedMarkerPath, markerPaint);

    // 3. Rotating Compass Rose (rotates by -heading in radians)
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-heading * math.pi / 180);

    // Subtle inner coordinate grid ring
    final innerGridPaint = Paint()
      ..color = SolarisColors.cyan.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(Offset.zero, maxR - 11.0, innerGridPaint);

    // Compass ticks every 15 degrees
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int deg = 0; deg < 360; deg += 15) {
      final rad = deg * math.pi / 180;
      final isCardinal = deg % 90 == 0;
      final isMajor = deg % 45 == 0;

      final double rOuter = maxR - 3.5;
      final double rInner = isCardinal
          ? (rOuter - 5.5)
          : (isMajor ? (rOuter - 3.5) : (rOuter - 2.0));

      tickPaint.color = isCardinal
          ? (deg == 0 ? SolarisColors.emerald : SolarisColors.cyan.withOpacity(0.8))
          : (isMajor ? SolarisColors.borderBright : SolarisColors.borderMuted);
      tickPaint.strokeWidth = isCardinal ? 1.5 : (isMajor ? 1.0 : 0.7);

      final p1 = Offset(rInner * math.sin(rad), -rInner * math.cos(rad));
      final p2 = Offset(rOuter * math.sin(rad), -rOuter * math.cos(rad));
      canvas.drawLine(p1, p2, tickPaint);
    }

    // Cardinal Letters: N, E, S, W
    const cardinalLabels = [
      {'text': 'N', 'deg': 0.0, 'color': SolarisColors.emerald, 'bold': true},
      {'text': 'E', 'deg': 90.0, 'color': SolarisColors.cyan, 'bold': false},
      {'text': 'S', 'deg': 180.0, 'color': SolarisColors.textSecondary, 'bold': false},
      {'text': 'W', 'deg': 270.0, 'color': SolarisColors.cyan, 'bold': false},
    ];

    for (final c in cardinalLabels) {
      final rad = (c['deg'] as double) * math.pi / 180;
      final text = c['text'] as String;
      final color = c['color'] as Color;
      final isBold = c['bold'] as bool;
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: isBold ? 8.5 : 7.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final rText = maxR - 11.5;
      final tx = rText * math.sin(rad) - (tp.width / 2);
      final ty = -rText * math.cos(rad) - (tp.height / 2);
      tp.paint(canvas, Offset(tx, ty));
    }

    // 4. Magnetic North Needle (Points toward North inside rotating frame, i.e., angle 0 / -Y)
    final needlePath = Path();
    needlePath.moveTo(0, -(maxR - 15.0)); // North tip
    needlePath.lineTo(3.2, -10.0);
    needlePath.lineTo(-3.2, -10.0);
    needlePath.close();

    final needlePaint = Paint()
      ..color = SolarisColors.emerald
      ..style = PaintingStyle.fill;
    canvas.drawPath(needlePath, needlePaint);

    // South Tapered Tail
    final southPath = Path();
    southPath.moveTo(0, maxR - 18.0); // South tip
    southPath.lineTo(2.5, 10.0);
    southPath.lineTo(-2.5, 10.0);
    southPath.close();

    final southPaint = Paint()
      ..color = SolarisColors.borderBright
      ..style = PaintingStyle.fill;
    canvas.drawPath(southPath, southPaint);

    canvas.restore();

    // 5. Fixed Center Hub Bezel with Live Degree Readout
    final hubRadius = 11.5 + (pulse * 1.5);
    final hubPaint = Paint()
      ..color = const Color(0xF208101D)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, hubRadius, hubPaint);

    final hubBorder = Paint()
      ..color = (isExpanded ? SolarisColors.cyan : SolarisColors.emerald).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, hubRadius, hubBorder);

    // Digital Heading Readout in Center
    final headingDegStr = '${heading.toInt().toString().padLeft(3, '0')}°';
    final headingTp = TextPainter(
      text: TextSpan(
        text: headingDegStr,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 7.0,
          fontWeight: FontWeight.bold,
          color: isExpanded ? SolarisColors.cyan : SolarisColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    headingTp.paint(canvas, Offset(cx - headingTp.width / 2, cy - headingTp.height / 2));

    // Tap pulse ripple effect
    if (pulse > 0.01) {
      final pulseRadius = hubRadius + (pulse * 24.0);
      final pulsePaint = Paint()
        ..color = SolarisColors.cyan.withOpacity((1.0 - pulse) * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SolarisNavViewportPainter oldDelegate) {
    return oldDelegate.heading != heading ||
        oldDelegate.cardinal != cardinal ||
        oldDelegate.orbitProgress != orbitProgress ||
        oldDelegate.pulse != pulse ||
        oldDelegate.isExpanded != isExpanded;
  }
}

// =============================================================================
// AUTHENTIC ANDROID APP ICON COMPONENT
// =============================================================================
final Map<String, String> _globalPackageIconMap = {};

class SolarisAppIcon extends StatefulWidget {
  final String packageName;
  final String? directIconPath;
  final double size;
  final String? fallbackLetter;

  const SolarisAppIcon({
    super.key,
    required this.packageName,
    this.directIconPath,
    this.size = 48,
    this.fallbackLetter,
  });

  @override
  State<SolarisAppIcon> createState() => _SolarisAppIconState();
}

class _SolarisAppIconState extends State<SolarisAppIcon> {
  static const _platform = MethodChannel('com.aetheris.control/telemetry');
  String? _iconPath;

  @override
  void initState() {
    super.initState();
    _resolveIcon();
  }

  @override
  void didUpdateWidget(covariant SolarisAppIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName ||
        oldWidget.directIconPath != widget.directIconPath) {
      _resolveIcon();
    }
  }

  void _resolveIcon() {
    if (widget.directIconPath != null && widget.directIconPath!.isNotEmpty) {
      _iconPath = widget.directIconPath;
      return;
    }
    final cached = _globalPackageIconMap[widget.packageName];
    if (cached != null && cached.isNotEmpty) {
      _iconPath = cached;
      return;
    }
    _platform.invokeMethod<String>('getAppIconPath', {'package': widget.packageName}).then((path) {
      if (path != null && mounted) {
        _globalPackageIconMap[widget.packageName] = path;
        setState(() => _iconPath = path);
      }
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final hasValidFile = _iconPath != null && _iconPath!.isNotEmpty;

    final radius = widget.size * 0.22;
    if (hasValidFile) {
      final pixelSize = (widget.size * MediaQuery.of(context).devicePixelRatio).round().clamp(64, 256);
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: SolarisColors.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.50),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.file(
            File(_iconPath!),
            width: widget.size,
            height: widget.size,
            cacheWidth: pixelSize,
            cacheHeight: pixelSize,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => _buildFallback(),
          ),
        ),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    final letter = widget.fallbackLetter?.isNotEmpty == true
        ? widget.fallbackLetter![0].toUpperCase()
        : '⬡';
    final radius = widget.size * 0.22;
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: SolarisColors.surfaceElevated,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: SolarisColors.border, width: 0.8),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: 'Orbitron',
          color: SolarisColors.cyan,
          fontSize: widget.size * 0.42,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// =============================================================================
// TACTILE AEROSPACE COCKPIT PRESSABLE FEEDBACK
// =============================================================================
class SolarisPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double pressedScale;

  const SolarisPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.90,
  });

  @override
  State<SolarisPressable> createState() => _SolarisPressableState();
}

class _SolarisPressableState extends State<SolarisPressable> with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
      reverseDuration: const Duration(milliseconds: 140),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _anim.forward(),
      onTapUp: (_) {
        _anim.reverse();
        widget.onTap();
      },
      onTapCancel: () => _anim.reverse(),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final scale = 1.0 - (_anim.value * (1.0 - widget.pressedScale));
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

// =============================================================================
// HIGH-TECH EXTRATERRESTRIAL TACTICAL REACTOR SLIDER
// =============================================================================
class SolarisTacticalSlider extends StatefulWidget {
  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;
  final Color accentColor;
  final VoidCallback? onHeaderTap;
  final String? statusTag;

  const SolarisTacticalSlider({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.accentColor,
    this.onHeaderTap,
    this.statusTag,
  });

  @override
  State<SolarisTacticalSlider> createState() => _SolarisTacticalSliderState();
}

class _SolarisTacticalSliderState extends State<SolarisTacticalSlider> {
  int _lastTick = -1;

  void _handleTouch(double localX, double width) {
    if (width <= 0) return;
    final clampedX = localX.clamp(0.0, width);
    final int newVal = (clampedX / width * 100).round().clamp(0, 100);
    if (newVal != widget.value) {
      widget.onChanged(newVal);
      // Sci-fi tick sound on every 6% boundary
      final currentTick = (newVal / 6).floor();
      if (currentTick != _lastTick) {
        _lastTick = currentTick;
        HapticFeedback.selectionClick();
        _SolarisHomeScreenState.platform.invokeMethod('playSciFiSound', {'sound': 'slider_tick'}).catchError((_) {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.value.clamp(0, 100);
    const int segments = 16;
    final int activeSegments = (pct / 100.0 * segments).round();

    return SolarisHullPanel(
      cut: 7.0,
      chamferTopRight: true,
      chamferBottomLeft: true,
      chamferTopLeft: false,
      chamferBottomRight: false,
      fillColor: SolarisColors.cockpitGlass,
      borderColor: widget.accentColor.withOpacity(0.35),
      borderWidth: 0.8,
      boxShadow: [
        BoxShadow(
          color: widget.accentColor.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onHeaderTap,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: widget.accentColor.withOpacity(0.4), width: 0.6),
                        ),
                        child: Icon(widget.icon, size: 11, color: widget.accentColor),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 9,
                            color: SolarisColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: widget.accentColor.withOpacity(0.45), width: 0.6),
                ),
                child: Text(
                  widget.statusTag ?? '$pct%',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 8.5,
                    color: widget.accentColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // High-Tech Tactical Reactor Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (d) => _handleTouch(d.localPosition.dx, w),
                onHorizontalDragUpdate: (d) => _handleTouch(d.localPosition.dx, w),
                onTapDown: (d) => _handleTouch(d.localPosition.dx, w),
                child: Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF090E17),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: SolarisColors.border, width: 0.8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                  child: Stack(
                    children: [
                      // Multi-segment LED power bars
                      Row(
                        children: List.generate(segments, (idx) {
                          final isActive = idx < activeSegments;
                          final segmentColor = isActive
                              ? widget.accentColor
                              : const Color(0xFF141E2C);
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: idx == 0 || idx == segments - 1 ? 0.5 : 1.0),
                              decoration: BoxDecoration(
                                color: segmentColor,
                                borderRadius: BorderRadius.circular(1.5),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: widget.accentColor.withOpacity(0.45),
                                          blurRadius: 3,
                                          spreadRadius: 0.5,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          );
                        }),
                      ),

                      // Holographic scan cursor marker
                      Positioned(
                        left: ((w - 10) * (pct / 100.0)).clamp(0.0, w - 10),
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: widget.accentColor,
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUBTLE AEROSPACE HORIZON LINE TRANSITION PAINTER
// =============================================================================
class _MatrixScanlinePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  _MatrixScanlinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.02 || progress >= 0.98) return;
    final scanY = size.height * (1.0 - progress);

    // Ultra-delicate aerospace telemetry horizon indicator
    final alpha = math.sin(progress * math.pi);
    final beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          SolarisColors.cyan.withOpacity(0.35 * alpha),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, scanY - 1, size.width, 2))
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), beamPaint);
  }

  @override
  bool shouldRepaint(covariant _MatrixScanlinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// =============================================================================
// CINEMATIC APP OPENING WARP ANIMATION OVERLAY & PAINTER (CLEAN TARGET ACQUIRE)
// =============================================================================
class LaunchData {
  final String title;
  final String packageName;
  final String? activityName;
  final Offset origin;
  final Size size;
  final String? iconPath;

  LaunchData({
    required this.title,
    required this.packageName,
    this.activityName,
    required this.origin,
    required this.size,
    this.iconPath,
  });
}

class SolarisLaunchWarpPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Offset origin;
  final String appTitle;

  SolarisLaunchWarpPainter({
    required this.progress,
    required this.origin,
    required this.appTitle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01 || progress >= 0.99) return;
    final cx = origin.dx;
    final cy = origin.dy;
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    // 1. Concentric Target Lock Iris Reticles centered directly on touched icon
    final reticleRadius = 24.0 + (Curves.easeOutQuad.transform(progress) * 80.0);
    final ringPaint = Paint()
      ..color = SolarisColors.cyan.withOpacity(0.85 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(Offset(cx, cy), reticleRadius, ringPaint);

    // Inner secondary pulse ring
    final innerR = reticleRadius * 0.58;
    final innerPaint = Paint()
      ..color = SolarisColors.emerald.withOpacity(0.70 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(cx, cy), innerR, innerPaint);

    // Rotating Aim Brackets [ + ]
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(progress * math.pi * 0.4);
    final bracketLen = 10.0;
    final bracketDist = reticleRadius + 4.0;
    final bPaint = Paint()
      ..color = SolarisColors.cyan.withOpacity(0.9 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    for (int q = 0; q < 4; q++) {
      canvas.rotate(math.pi / 2);
      canvas.drawLine(Offset(bracketDist, -bracketLen), Offset(bracketDist, bracketLen), bPaint);
      canvas.drawLine(Offset(bracketDist - 5, 0), Offset(bracketDist + 5, 0), bPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SolarisLaunchWarpPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// =============================================================================
// =============================================================================
// SPACESHIP HULL PANEL (CHAMFERED AEROSPACE BEVEL CONTAINER)
// =============================================================================
class SolarisHullPanel extends StatelessWidget {
  final Widget child;
  final double cut;
  final Color? fillColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final bool chamferTopRight;
  final bool chamferBottomLeft;
  final bool chamferTopLeft;
  final bool chamferBottomRight;
  final bool accentTicks;
  final Color? conduitColor;
  final bool cornerRivets;
  final Gradient? gradientFill;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const SolarisHullPanel({
    super.key,
    required this.child,
    this.cut = 8.0,
    this.fillColor,
    this.borderColor = SolarisColors.border,
    this.borderWidth = 0.8,
    this.padding = const EdgeInsets.all(8.0),
    this.chamferTopRight = true,
    this.chamferBottomLeft = true,
    this.chamferTopLeft = false,
    this.chamferBottomRight = false,
    this.accentTicks = false,
    this.conduitColor,
    this.cornerRivets = false,
    this.gradientFill,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = CustomPaint(
      painter: _SolarisHullPainter(
        cut: cut,
        fillColor: fillColor ?? SolarisColors.cockpitGlass,
        borderColor: borderColor,
        borderWidth: borderWidth,
        chamferTopRight: chamferTopRight,
        chamferBottomLeft: chamferBottomLeft,
        chamferTopLeft: chamferTopLeft,
        chamferBottomRight: chamferBottomRight,
        accentTicks: accentTicks,
        conduitColor: conduitColor,
        cornerRivets: cornerRivets,
        gradientFill: gradientFill,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (boxShadow != null && boxShadow!.isNotEmpty) {
      content = DecoratedBox(
        decoration: BoxDecoration(boxShadow: boxShadow),
        child: content,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

class _SolarisHullPainter extends CustomPainter {
  final double cut;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final bool chamferTopRight;
  final bool chamferBottomLeft;
  final bool chamferTopLeft;
  final bool chamferBottomRight;
  final bool accentTicks;
  final Color? conduitColor;
  final bool cornerRivets;
  final Gradient? gradientFill;

  _SolarisHullPainter({
    required this.cut,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    required this.chamferTopRight,
    required this.chamferBottomLeft,
    required this.chamferTopLeft,
    required this.chamferBottomRight,
    this.accentTicks = false,
    this.conduitColor,
    this.cornerRivets = false,
    this.gradientFill,
  });

  Path _buildPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    if (chamferTopLeft) {
      path.moveTo(cut, 0);
    } else {
      path.moveTo(0, 0);
    }

    if (chamferTopRight) {
      path.lineTo(w - cut, 0);
      path.lineTo(w, cut);
    } else {
      path.lineTo(w, 0);
    }

    if (chamferBottomRight) {
      path.lineTo(w, h - cut);
      path.lineTo(w - cut, h);
    } else {
      path.lineTo(w, h);
    }

    if (chamferBottomLeft) {
      path.lineTo(cut, h);
      path.lineTo(0, h - cut);
    } else {
      path.lineTo(0, h);
    }

    if (chamferTopLeft) {
      path.lineTo(0, cut);
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);

    final fillPaint = Paint()..style = PaintingStyle.fill;
    if (gradientFill != null) {
      fillPaint.shader = gradientFill!.createShader(Offset.zero & size);
    } else {
      fillPaint.color = fillColor;
    }
    canvas.drawPath(path, fillPaint);

    if (borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(path, borderPaint);
    }

    if (conduitColor != null) {
      final conduitPaint = Paint()
        ..color = conduitColor!
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(1.5, (cut > 0 ? cut : 4) + 1),
        Offset(1.5, size.height - (cut > 0 ? cut : 4) - 1),
        conduitPaint,
      );
    }

    if (accentTicks) {
      final tickPaint = Paint()
        ..color = borderColor
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      const tLen = 6.0;
      if (!chamferTopLeft) {
        canvas.drawLine(const Offset(0, 0), const Offset(tLen, 0), tickPaint);
        canvas.drawLine(const Offset(0, 0), const Offset(0, tLen), tickPaint);
      }
      if (!chamferBottomRight) {
        canvas.drawLine(Offset(size.width, size.height), Offset(size.width - tLen, size.height), tickPaint);
        canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - tLen), tickPaint);
      }
    }

    if (cornerRivets) {
      final rivetPaint = Paint()
        ..color = borderColor.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      const rDist = 4.0;
      canvas.drawCircle(Offset(cut + rDist, rDist + 2), 1.2, rivetPaint);
      canvas.drawCircle(Offset(size.width - cut - rDist, rDist + 2), 1.2, rivetPaint);
      canvas.drawCircle(Offset(cut + rDist, size.height - rDist - 2), 1.2, rivetPaint);
      canvas.drawCircle(Offset(size.width - cut - rDist, size.height - rDist - 2), 1.2, rivetPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SolarisHullPainter oldDelegate) {
    return oldDelegate.cut != cut ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.accentTicks != accentTicks ||
        oldDelegate.conduitColor != conduitColor ||
        oldDelegate.cornerRivets != cornerRivets;
  }
}

// =============================================================================
// TACTILE COCKPIT ROCKER / HARDWARE BUTTON
// =============================================================================
class SolarisCockpitButton extends StatelessWidget {
  final Widget? child;
  final String? title;
  final String? subtitle;
  final String? tacticalTag;
  final IconData? icon;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback? onTap;
  final double cut;
  final bool showLed;
  final EdgeInsetsGeometry padding;

  const SolarisCockpitButton({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.tacticalTag,
    this.icon,
    this.isActive = false,
    this.activeColor = SolarisColors.cyan,
    this.inactiveColor = SolarisColors.borderMuted,
    this.onTap,
    this.cut = 6.0,
    this.showLed = true,
    this.padding = const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
  });

  @override
  Widget build(BuildContext context) {
    return SolarisHullPanel(
      cut: cut,
      chamferTopRight: true,
      chamferBottomLeft: true,
      chamferTopLeft: false,
      chamferBottomRight: false,
      fillColor: isActive
          ? activeColor.withOpacity(0.18)
          : const Color(0xFF0C101A),
      borderColor: isActive ? activeColor : inactiveColor,
      borderWidth: isActive ? 1.2 : 0.7,
      boxShadow: isActive
          ? [BoxShadow(color: activeColor.withOpacity(0.28), blurRadius: 8)]
          : null,
      onTap: onTap,
      padding: padding,
      child: child ??
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLed || tacticalTag != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showLed)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? activeColor
                              : SolarisColors.textMuted.withOpacity(0.4),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: activeColor,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (tacticalTag != null)
                      Text(
                        tacticalTag!,
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 6.5,
                          color: isActive
                              ? activeColor.withOpacity(0.85)
                              : SolarisColors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              if (showLed || tacticalTag != null) const SizedBox(height: 2),
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isActive ? activeColor : SolarisColors.textSecondary,
                ),
                const SizedBox(height: 2),
              ],
              if (title != null)
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: isActive ? activeColor : SolarisColors.textSecondary,
                  ),
                ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 6.5,
                    color: isActive
                        ? activeColor.withOpacity(0.85)
                        : SolarisColors.textMuted,
                  ),
                ),
            ],
          ),
    );
  }
}

// =============================================================================
// MAIN LAUNCHER VIEW — THE SPACECRAFT BRIDGE
// =============================================================================
class SolarisHomeScreen extends StatefulWidget {
  const SolarisHomeScreen({super.key});

  @override
  State<SolarisHomeScreen> createState() => _SolarisHomeScreenState();
}

class _SolarisHomeScreenState extends State<SolarisHomeScreen>
    with TickerProviderStateMixin {
  static const platform = MethodChannel('com.aetheris.control/telemetry');
  static const _compassChannel = EventChannel('com.aetheris.control/compass');
  StreamSubscription? _compassSubscription;
  double _compassHeading = 0.0;
  String _compassCardinal = 'N';

  late PageController _pageController;
  late AnimationController _starfieldController;
  late AnimationController _launchAnimController;
  late AnimationController _matrixAnimController;
  bool _isMatrixOpen = false;
  LaunchData? _activeLaunch;
  bool _isTelemetryExpanded = false;
  bool _isCapsuleExpanded = false;

  // Active Mission State
  final List<Map<String, String>> _missions = [
    {'NAME': 'WARP-VELOCITY', 'OBJ': 'VIVO V40 120HZ BURST', 'STATUS': 'ACTIVE'},
    {'NAME': 'EXPEDITION-7', 'OBJ': 'ORBITAL SURVEILLANCE', 'STATUS': 'ACTIVE'},
    {'NAME': 'DEEP MATRIX', 'OBJ': 'HIGH-BAND COMMS RELAY', 'STATUS': 'ACTIVE'},
    {'NAME': 'STANDBY VOYAGE', 'OBJ': 'LOW POWER CRYO CONSERVATION', 'STATUS': 'STANDBY'},
  ];
  int _missionIdx = 0;

  DateTime _currentTime = DateTime.now();
  Timer? _clockTimer;
  Timer? _telemetryTimer;

  // Performance Mode Governor: 'WARP', 'ORBITAL', 'CRYO'
  String _performanceMode = 'WARP';

  // Hardware controls state
  int _lightLevel = 75; // 0..100
  int _soundLevel = 60; // 0..100
  bool _isSoundMuted = false;
  bool _isWifiEnabled = true;
  String _wifiSsid = 'VIJAYANAND5G';
  bool _isBtEnabled = true;
  String _btStatus = 'ACTIVE';

  Map<String, dynamic> _telemetry = {
    'model': 'Vivo V40',
    'board': 'Snapdragon 7 Gen 3',
    'cpuPercent': 14,
    'cpuCores': 8,
    'ramPercent': 78,
    'usedRamMb': 5880,
    'totalRamMb': 7480,
    'availRamMb': 1600,
    'storagePercent': 47,
    'totalStorageGb': 222,
    'availStorageGb': 116,
    'batteryLevel': 70,
    'batteryTemp': 37.6,
    'isCharging': true,
    'refreshRate': 120,
    'ipAddress': '192.168.29.180',
    'isConnected': true,
    'sensorImu': 'ONLINE (6-AXIS)',
    'sensorMag': 'CALIBRATED',
    'sensorLight': 'ACTIVE',
    'sensorBaro': 'ONLINE',
    'sensorGps': 'LOCKED (GNSS)',
  };

  List<Map<String, dynamic>> _installedApps = [];
  final Map<String, String> _packageIconMap = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // 8-second slow star shimmer
    _starfieldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Launch Animation Controller (400ms snappy warp leap)
    _launchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Spaceship Matrix Transition Controller (250ms snappy high-tech unroll)
    _matrixAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // 1-second clock
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });

    // Initial hardware & telemetry fetch
    _fetchTelemetry();
    _fetchHardwareControls();
    _fetchInstalledApps();
    _initCompass();

    // Periodic telemetry & radio polling
    _telemetryTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        _fetchTelemetry();
        _fetchHardwareControls();
      }
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _clockTimer?.cancel();
    _telemetryTimer?.cancel();
    _pageController.dispose();
    _starfieldController.dispose();
    _launchAnimController.dispose();
    _matrixAnimController.dispose();
    super.dispose();
  }

  void _initCompass() {
    try {
      _compassSubscription = _compassChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is num && mounted) {
            final deg = event.toDouble();
            setState(() {
              _compassHeading = deg;
              _compassCardinal = _calcCardinal(deg);
            });
          }
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  String _calcCardinal(double deg) {
    final d = (deg % 360 + 360) % 360;
    if (d >= 337.5 || d < 22.5) return 'N';
    if (d >= 22.5 && d < 67.5) return 'NE';
    if (d >= 67.5 && d < 112.5) return 'E';
    if (d >= 112.5 && d < 157.5) return 'SE';
    if (d >= 157.5 && d < 202.5) return 'S';
    if (d >= 202.5 && d < 247.5) return 'SW';
    if (d >= 247.5 && d < 292.5) return 'W';
    return 'NW';
  }

  Future<void> _fetchTelemetry() async {
    try {
      final res = await platform.invokeMethod('getSystemTelemetry');
      if (res != null && mounted) {
        setState(() => _telemetry = Map<String, dynamic>.from(res));
      }
    } catch (_) {}
  }

  Future<void> _fetchHardwareControls() async {
    try {
      // Light
      final light = await platform.invokeMethod<int>('getLightLevel');
      if (light != null && mounted) {
        setState(() => _lightLevel = light);
      }

      // Audio
      final audio = await platform.invokeMethod<Map>('getAudioLevel');
      if (audio != null && mounted) {
        setState(() {
          _soundLevel = (audio['volume'] as num?)?.toInt() ?? _soundLevel;
          _isSoundMuted = audio['isMuted'] == true;
        });
      }

      // Radios (WiFi, BT)
      final radios = await platform.invokeMethod<Map>('getRadioStatus');
      if (radios != null && mounted) {
        setState(() {
          _isWifiEnabled = radios['isWifiEnabled'] == true;
          _wifiSsid = radios['wifiSsid'] as String? ?? _wifiSsid;
          _isBtEnabled = radios['isBtEnabled'] == true;
          _btStatus = radios['btStatus'] as String? ?? _btStatus;
        });
      }
    } catch (_) {}
  }

  Future<void> _setLightLevel(int level) async {
    setState(() => _lightLevel = level.clamp(5, 100));
    try {
      await platform.invokeMethod('setLightLevel', {'percent': _lightLevel});
    } catch (_) {}
  }

  Future<void> _setAudioLevel(int level) async {
    setState(() => _soundLevel = level.clamp(0, 100));
    try {
      await platform.invokeMethod('setAudioLevel', {'percent': _soundLevel});
    } catch (_) {}
  }

  Future<void> _setPerformanceMode(String mode) async {
    HapticFeedback.heavyImpact();
    setState(() => _performanceMode = mode);
    try {
      await platform.invokeMethod('setPerformanceMode', {'mode': mode});
      await _fetchTelemetry();
    } catch (_) {}
    if (mounted) {
      final modeDesc = mode == 'WARP'
          ? 'WARP OVERCLOCK // 120HZ MAX BOOST // CACHE PURGED'
          : mode == 'ORBITAL'
              ? 'ORBITAL BALANCED // 120HZ ADAPTIVE // NOMINAL'
              : 'CRYO POWER SAVER // 60HZ CONSERVE // THERMAL SHIELD';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GOVERNOR: $modeDesc',
              style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11)),
          backgroundColor: mode == 'WARP' ? SolarisColors.purple : (mode == 'ORBITAL' ? SolarisColors.cyan : SolarisColors.emerald),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _fetchInstalledApps() async {
    try {
      final res = await platform.invokeMethod('getInstalledApps');
      if (res != null && mounted) {
        final list = List<Map<String, dynamic>>.from(
          (res as List).map((e) => Map<String, dynamic>.from(e)),
        );
        for (final app in list) {
          final pkg = app['package'] as String?;
          final iconPath = app['iconPath'] as String?;
          if (pkg != null && iconPath != null && iconPath.isNotEmpty) {
            _packageIconMap[pkg] = iconPath;
            _globalPackageIconMap[pkg] = iconPath;
          }
        }
        setState(() {
          _installedApps = list;
        });
      }
    } catch (_) {}
  }

  // ===========================================================================
  // HYPER-SMOOTH CINEMATIC APP OPENING WITH WARP ANIMATION
  // ===========================================================================
  void _launchAppWithAnimation({
    required BuildContext iconContext,
    required String systemTitle,
    required String packageName,
    String? activityName,
    String? iconPath,
  }) {
    HapticFeedback.mediumImpact();
    platform.invokeMethod('playSciFiSound', {'sound': 'app_launch'}).catchError((_) {});

    final RenderBox? box = iconContext.findRenderObject() as RenderBox?;
    final Offset globalPos = (box != null && box.attached)
        ? box.localToGlobal(Offset.zero)
        : Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2);
    final Size boxSize = box?.size ?? const Size(56, 56);
    final Offset centerOrigin = Offset(
      globalPos.dx + boxSize.width / 2,
      globalPos.dy + boxSize.height / 2,
    );

    // Launch immediately via Android native hardware-accelerated scale-up animation
    platform.invokeMethod('launchApp', {
      'package': packageName,
      'activity': activityName,
      'startX': centerOrigin.dx.toInt(),
      'startY': centerOrigin.dy.toInt(),
      'width': boxSize.width.toInt(),
      'height': boxSize.height.toInt(),
    }).catchError((_) {});

    // If matrix drawer was open, close it instantly so zero background animations fight the OS
    if (_isMatrixOpen) {
      _matrixAnimController.value = 0.0;
      setState(() => _isMatrixOpen = false);
    } else {
      // Trigger subtle non-blocking target lock reticle on the homescreen icon
      setState(() {
        _activeLaunch = LaunchData(
          title: systemTitle,
          packageName: packageName,
          activityName: activityName,
          origin: centerOrigin,
          size: boxSize,
          iconPath: iconPath ?? _packageIconMap[packageName],
        );
      });

      _launchAnimController.forward(from: 0.0);

      // Reset overlay after 260ms
      Future.delayed(const Duration(milliseconds: 260), () {
        if (mounted) {
          setState(() => _activeLaunch = null);
        }
      });
    }
  }

  void _openApplicationMatrix() {
    if (_isMatrixOpen || _matrixAnimController.isAnimating) return;
    HapticFeedback.mediumImpact();
    platform.invokeMethod('playSciFiSound', {'sound': 'drawer_open'}).catchError((_) {});
    setState(() => _isMatrixOpen = true);
    _matrixAnimController.forward(from: 0.0);
  }

  void _closeApplicationMatrix() {
    if (!_isMatrixOpen) return;
    HapticFeedback.lightImpact();
    platform.invokeMethod('playSciFiSound', {'sound': 'drawer_close'}).catchError((_) {});
    _matrixAnimController.reverse().then((_) {
      if (mounted) setState(() => _isMatrixOpen = false);
    });
  }

  void _cycleMission() {
    HapticFeedback.lightImpact();
    setState(() {
      _missionIdx = (_missionIdx + 1) % _missions.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topSafe = media.padding.top;
    final bottomSafe = media.padding.bottom;

    return PopScope(
      canPop: !_isMatrixOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isMatrixOpen) {
          _closeApplicationMatrix();
        }
      },
      child: Scaffold(
        backgroundColor: SolarisColors.spaceBlack,
        body: Stack(
          children: [
            // 1. DEEP SPACE STARFIELD LAYER
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _starfieldController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: StarfieldPainter(shimmer: _starfieldController.value),
                  );
                },
              ),
            ),

            // 2. MAIN FLIGHT DECK (PAGE 0: BRIDGE CONSOLE, PAGE 1: ENGINEERING DECK)
            AnimatedBuilder(
              animation: _matrixAnimController,
              builder: (context, child) {
                final t = _matrixAnimController.value;
                final scale = 1.0 - (0.07 * t);
                final opacity = 1.0 - (0.75 * t);
                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy < -6 && !_isMatrixOpen) {
                    _openApplicationMatrix();
                  }
                },
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null && details.primaryVelocity! < -80 && !_isMatrixOpen) {
                    _openApplicationMatrix();
                  }
                },
                child: PageView(
                  controller: _pageController,
                  physics: _isMatrixOpen ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
                  children: [
                    _buildBridgePage(topSafe, bottomSafe),
                    _buildEngineeringDeckPage(topSafe, bottomSafe),
                  ],
                ),
              ),
            ),

            // 3. FULL-DECK SPACESHIP APPLICATION MATRIX VIEWPORT
            if (_isMatrixOpen)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _matrixAnimController,
                  child: _SolarisMatrixDrawerModal(
                    installedApps: _installedApps,
                    packageIconMap: _packageIconMap,
                    telemetry: _telemetry,
                    classifyApp: _classifyApp,
                    onClose: _closeApplicationMatrix,
                    onLaunchApp: (appContext, title, pkg, cls, iconPath) {
                      _launchAppWithAnimation(
                        iconContext: appContext,
                        systemTitle: title,
                        packageName: pkg,
                        activityName: cls,
                        iconPath: iconPath,
                      );
                    },
                  ),
                  builder: (context, modalChild) {
                    final t = _matrixAnimController.value;
                    final curvedT = Curves.easeOutCubic.transform(t);
                    final slideY = (1.0 - curvedT) * (media.size.height * 0.40);
                    final scale = 0.96 + (0.04 * curvedT);

                    return Stack(
                      children: [
                        // Holographic Backdrop Barrier
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: _closeApplicationMatrix,
                            behavior: HitTestBehavior.opaque,
                            child: Opacity(
                              opacity: (curvedT * 0.92).clamp(0.0, 0.95),
                              child: Container(color: SolarisColors.spaceBlack),
                            ),
                          ),
                        ),

                        // Scanline laser sweep during transition
                        if (t > 0.01 && t < 0.99)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _MatrixScanlinePainter(progress: t),
                            ),
                          ),

                        // Application Matrix Command Deck Viewport
                        Positioned.fill(
                          child: Transform.translate(
                            offset: Offset(0, slideY),
                            child: Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: curvedT.clamp(0.0, 1.0),
                                child: modalChild,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // 4. CINEMATIC SOLARIS WARP LAUNCH OVERLAY
            if (_activeLaunch != null)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _launchAnimController,
                  builder: (context, _) {
                    return Stack(
                      children: [
                        // Fullscreen painter
                        Positioned.fill(
                          child: CustomPaint(
                            painter: SolarisLaunchWarpPainter(
                              progress: _launchAnimController.value,
                              origin: _activeLaunch!.origin,
                              appTitle: _activeLaunch!.title,
                            ),
                          ),
                        ),

                        // Holographic system engagement HUD
                        Positioned(
                          top: topSafe + 60,
                          left: 24,
                          right: 24,
                          child: Opacity(
                            opacity: _launchAnimController.value.clamp(0.0, 1.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: SolarisColors.cockpitGlass,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _performanceMode == 'WARP' ? SolarisColors.purple : SolarisColors.cyan,
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_performanceMode == 'WARP' ? SolarisColors.purple : SolarisColors.cyan).withOpacity(0.3),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _performanceMode == 'WARP' ? SolarisColors.purple : SolarisColors.cyan,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'ENGAGING // ${_activeLaunch!.title.toUpperCase()} · WARP VECTOR',
                                    style: TextStyle(
                                      fontFamily: 'JetBrainsMono',
                                      color: _performanceMode == 'WARP' ? SolarisColors.purple : SolarisColors.cyan,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. PRIMARY BRIDGE PAGE (THE SPACECRAFT CONTROL CONSOLE)
  // ===========================================================================
  Widget _buildBridgePage(double topSafe, double bottomSafe) {
    final timeHoursMins =
        '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}';
    final secondsStr = _currentTime.second.toString().padLeft(2, '0');
    final dateStr =
        '${_getDayName(_currentTime.weekday)} · ${_currentTime.day} ${_getMonthName(_currentTime.month)} ${_currentTime.year}';
    final stardate = 'STARDATE ${_currentTime.year}.${(_currentTime.month * 30 + _currentTime.day)}';

    final isCharging = _telemetry['isCharging'] == true;
    final cpuVal = _telemetry['cpuPercent'] ?? 14;
    final batVal = _telemetry['batteryLevel'] ?? 70;
    final currentMission = _missions[_missionIdx];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SolarisSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),

              // 1. SOLARIS COMMAND CAPSULE (THEMED DYNAMIC ISLAND)
              _buildSolarisCommandCapsule(batVal, isCharging, cpuVal),

              const SizedBox(height: 4),

              // 2. WAYBAR-STYLE TOP HUD: WORKSPACE NODES & TELEMETRY
              _buildWaybarTopHUD(batVal, isCharging, cpuVal),

              const SizedBox(height: SolarisSpacing.sm),

              // CHRONOMETER + NAVIGATION VIEWPORT
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // LEFT: TIME, CALENDAR & STARDATE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              timeHoursMins,
                              style: const TextStyle(
                                fontFamily: 'Orbitron',
                                color: SolarisColors.textPrimary,
                                fontSize: 48,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(width: SolarisSpacing.xs),
                            Text(
                              secondsStr,
                              style: const TextStyle(
                                fontFamily: 'JetBrainsMono',
                                color: SolarisColors.cyan,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          dateStr.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Rajdhani',
                            color: SolarisColors.cyan,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Text(
                          stardate,
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            color: SolarisColors.textMuted,
                            fontSize: 9,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // RIGHT: STAR TRACKER / NAVIGATION VIEWPORT
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SolarisNavViewportWidget(
                        isExpanded: _isTelemetryExpanded,
                        heading: _compassHeading,
                        cardinal: _compassCardinal,
                        onTap: () {
                          setState(() {
                            _isTelemetryExpanded = !_isTelemetryExpanded;
                          });
                        },
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isTelemetryExpanded
                            ? 'COLLAPSE'
                            : '${_compassHeading.toInt().toString().padLeft(3, '0')}° $_compassCardinal // NAV COMPASS',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          color: _isTelemetryExpanded
                              ? SolarisColors.cyan
                              : SolarisColors.textMuted,
                          fontSize: 8,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: SolarisSpacing.sm),

              // VESSEL STATUS HUD (THE 4 SPACECRAFT PILLARS)
              _buildFlightPillarsHUD(batVal, isCharging, cpuVal),

              // EXPANDED TELEMETRY & HARDWARE SENSORS
              if (_isTelemetryExpanded) ...[
                const SizedBox(height: SolarisSpacing.xs),
                _buildExpandedSensors(),
              ],

              const SizedBox(height: 6),

              // MISSION STATUS STRIP (TAP TO CYCLE)
              GestureDetector(
                onTap: _cycleMission,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'MISSION // ${currentMission['NAME']}',
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            color: SolarisColors.cyan,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            border: Border.all(color: SolarisColors.border, width: 0.6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            currentMission['STATUS']!,
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              color: SolarisColors.emerald,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currentMission['OBJ']!,
                      style: const TextStyle(
                        fontFamily: 'Rajdhani',
                        color: SolarisColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // SOLARIS COCKPIT CONTROLS MATRIX (PERFORMANCE MODE, LIGHT, SOUND, WIFI, BT)
              _buildSolarisCockpitControlsMatrix(),

              const SizedBox(height: SolarisSpacing.sm),

              // PRIMARY SHIP SYSTEMS GRID
              Expanded(
                child: _buildShipSystemsGrid(),
              ),

              // ALL SHIP SYSTEMS AFFORDANCE
              Center(
                child: GestureDetector(
                  onTap: _openApplicationMatrix,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.keyboard_arrow_up,
                            color: SolarisColors.cyan, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'ALL SYSTEMS MATRIX [${_installedApps.length}]',
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            color: SolarisColors.textSecondary,
                            fontSize: 10,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // INTEGRATED FLIGHT DOCK
              _buildIntegratedFlightDock(),
            ],
          ),
        ),
      );
  }

  // ===========================================================================
  // 0. SOLARIS COMMAND CAPSULE (SPACESHIP THEMED DYNAMIC ISLAND)
  // ===========================================================================
  Widget _buildSolarisCommandCapsule(int batVal, bool isCharging, int cpuVal) {
    final isMusic = _telemetry['isMusicActive'] == true;
    final animVal = _starfieldController.value;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: _isCapsuleExpanded ? double.infinity : 240.0,
        margin: const EdgeInsets.only(bottom: 4),
        child: SolarisHullPanel(
          cut: _isCapsuleExpanded ? 8.0 : 6.0,
          chamferTopLeft: true,
          chamferTopRight: true,
          chamferBottomLeft: true,
          chamferBottomRight: true,
          fillColor: const Color(0xF2080D18),
          borderColor: _isCapsuleExpanded
              ? SolarisColors.cyan
              : SolarisColors.cyan.withOpacity(0.55),
          borderWidth: _isCapsuleExpanded ? 1.1 : 0.8,
          boxShadow: [
            BoxShadow(
              color: SolarisColors.cyan.withOpacity(_isCapsuleExpanded ? 0.25 : 0.12),
              blurRadius: _isCapsuleExpanded ? 14 : 8,
              offset: const Offset(0, 2),
            ),
          ],
          padding: _isCapsuleExpanded
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
              : const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _isCapsuleExpanded = !_isCapsuleExpanded;
            });
          },
          child: _isCapsuleExpanded
              ? _buildExpandedCapsuleHUD(batVal, isCharging, cpuVal, isMusic, animVal)
              : _buildCollapsedCapsuleHUD(batVal, isCharging, cpuVal, isMusic, animVal),
        ),
      ),
    );
  }

  Widget _buildCollapsedCapsuleHUD(
      int batVal, bool isCharging, int cpuVal, bool isMusic, double animVal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Reactive Dynamic Equalizer or Charging Bolt
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCharging) ...[
              const Icon(Icons.bolt, color: SolarisColors.cyan, size: 14),
              const SizedBox(width: 2),
              Text(
                '$batVal%',
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: SolarisColors.cyan,
                ),
              ),
            ] else ...[
              _buildMiniEqualizerBars(animVal),
              const SizedBox(width: 5),
              Text(
                isMusic ? 'AUDIO RELAY' : 'CORE $cpuVal%',
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: SolarisColors.emerald,
                ),
              ),
            ],
          ],
        ),

        // Center: Punch-hole camera alignment indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: SolarisColors.cyan.withOpacity(0.12),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: SolarisColors.cyan.withOpacity(0.4), width: 0.6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: SolarisColors.cyan,
                ),
              ),
              const SizedBox(width: 3),
              const Text(
                'CAPSULE',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: SolarisColors.cyan,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),

        // Right: Mode / Telemetry Pill
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _performanceMode == 'WARP' ? '120Hz WARP' : '$_soundLevel% VOL',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
                color: _performanceMode == 'WARP'
                    ? SolarisColors.purple
                    : SolarisColors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down,
              color: SolarisColors.textMuted,
              size: 13,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedCapsuleHUD(
      int batVal, bool isCharging, int cpuVal, bool isMusic, double animVal) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: SolarisColors.cyan,
                    boxShadow: [
                      BoxShadow(color: SolarisColors.cyan, blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'SOLARIS COMMAND CAPSULE // DYNAMIC HUD',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    color: SolarisColors.cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _isCapsuleExpanded = false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  border: Border.all(color: SolarisColors.borderMuted, width: 0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'COLLAPSE ✕',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 7.5,
                    color: SolarisColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // 2. Interactive Action Chips
        Row(
          children: [
            // Sound Mute Toggle
            Expanded(
              child: SolarisCockpitButton(
                title: _isSoundMuted ? 'UNMUTE' : 'MUTE AUDIO',
                subtitle: '$_soundLevel% OUTPUT',
                tacticalTag: '[SONIC]',
                isActive: !_isSoundMuted,
                activeColor: SolarisColors.emerald,
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (_isSoundMuted) {
                    _setAudioLevel(_soundLevel > 0 ? _soundLevel : 50);
                  } else {
                    _setAudioLevel(0);
                  }
                },
              ),
            ),
            const SizedBox(width: 6),

            // Performance Cycle
            Expanded(
              child: SolarisCockpitButton(
                title: 'GOVERNOR',
                subtitle: 'MODE: $_performanceMode',
                tacticalTag: '[PROPULSION]',
                isActive: true,
                activeColor: _performanceMode == 'WARP'
                    ? SolarisColors.purple
                    : (_performanceMode == 'ORBITAL' ? SolarisColors.cyan : SolarisColors.emerald),
                onTap: () {
                  HapticFeedback.lightImpact();
                  final nextMode = _performanceMode == 'WARP'
                      ? 'ORBITAL'
                      : (_performanceMode == 'ORBITAL' ? 'CRYO' : 'WARP');
                  _setPerformanceMode(nextMode);
                },
              ),
            ),
            const SizedBox(width: 6),

            // Vivo Island & Notifications
            Expanded(
              child: SolarisCockpitButton(
                title: 'VIVO ISLAND',
                subtitle: 'SYSTEM CFG',
                tacticalTag: '[SYS.ISLAND]',
                isActive: false,
                inactiveColor: SolarisColors.border,
                onTap: () {
                  HapticFeedback.lightImpact();
                  platform.invokeMethod('openIslandSettings');
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // 3. Dynamic Multi-Bar Spectrum Equalizer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isMusic ? '󰎆 SPOTIFY AUDIO FLUX STREAM' : '󰌪 AVIONICS TELEMETRY SYNC',
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 7.5,
                color: SolarisColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            _buildMultiBarEqualizer(animVal),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniEqualizerBars(double anim) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final height = 4.0 + 8.0 * ((math.sin(anim * 6.28 + i * 1.5) + 1.0) / 2.0);
        return Container(
          width: 2.5,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: SolarisColors.cyan,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  Widget _buildMultiBarEqualizer(double anim) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(14, (i) {
        final height = 3.0 + 9.0 * ((math.sin(anim * 6.28 * 1.5 + i * 0.8) + 1.0) / 2.0);
        return Container(
          width: 2,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: i % 2 == 0 ? SolarisColors.cyan : SolarisColors.emerald,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  // ===========================================================================
  // WAYBAR-STYLE TOP STATUS HUD (MATCHING SOLARIS OS LINUX RICE)
  // ===========================================================================
  Widget _buildWaybarTopHUD(int batVal, bool isCharging, int cpuVal) {
    return SolarisHullPanel(
      cut: 6.0,
      chamferTopRight: true,
      chamferBottomLeft: true,
      chamferTopLeft: false,
      chamferBottomRight: false,
      fillColor: SolarisColors.cockpitGlass,
      borderColor: SolarisColors.border,
      borderWidth: 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Waybar Workspace Nodes
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWorkspacePill('01 CMD', true),
              const SizedBox(width: 4),
              _buildWorkspacePill('02 ENG', false, onTap: () {
                _pageController.animateToPage(1,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutCubic);
              }),
              const SizedBox(width: 4),
              _buildWorkspacePill('03 SYS', false, onTap: _openApplicationMatrix),
            ],
          ),

          // Micro Telemetry Stream
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ' $cpuVal% ',
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  color: SolarisColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '󰍛 ${(_telemetry['availRamMb'] / 1024).toStringAsFixed(1)}G ',
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  color: SolarisColors.cyan,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isCharging ? '󰂄 $batVal% ⚡' : '󰁹 $batVal%',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  color: isCharging ? SolarisColors.emerald : SolarisColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspacePill(String label, bool active, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SolarisHullPanel(
        cut: 4.0,
        chamferTopRight: true,
        chamferBottomLeft: true,
        chamferTopLeft: false,
        chamferBottomRight: false,
        fillColor: active ? SolarisColors.cyan.withOpacity(0.18) : Colors.transparent,
        borderColor: active ? SolarisColors.cyan : SolarisColors.borderMuted,
        borderWidth: 0.8,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 3.5,
              height: 3.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? SolarisColors.cyan : SolarisColors.textMuted.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                color: active ? SolarisColors.cyan : SolarisColors.textMuted,
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 4 FLIGHT PILLARS HUD
  // ===========================================================================
  Widget _buildFlightPillarsHUD(int batVal, bool isCharging, int cpuVal) {
    return GestureDetector(
      onTap: () => setState(() => _isTelemetryExpanded = !_isTelemetryExpanded),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [SolarisColors.border, SolarisColors.divider, Colors.transparent],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFlightPillar(
                'POWER',
                '$batVal%',
                isCharging ? 'TRANSFER ⚡' : (batVal <= 20 ? 'RESERVE' : 'NOMINAL'),
                isCharging ? SolarisColors.cyan : (batVal <= 20 ? SolarisColors.amber : SolarisColors.emerald),
              ),
              _buildPillarDivider(),
              _buildFlightPillar(
                'CORE',
                '$cpuVal%',
                _performanceMode == 'WARP' ? 'WARP 120Hz' : (cpuVal > 50 ? 'BURST' : 'NOMINAL'),
                _performanceMode == 'WARP' ? SolarisColors.purple : SolarisColors.emerald,
              ),
              _buildPillarDivider(),
              _buildFlightPillar(
                'PROPULSION',
                cpuVal > 40 ? 'ACTIVE' : 'IDLE',
                'IMPULSE',
                cpuVal > 40 ? SolarisColors.cyan : SolarisColors.textSecondary,
              ),
              _buildPillarDivider(),
              _buildFlightPillar(
                'COMMS',
                _isWifiEnabled ? 'ONLINE' : 'OFFLINE',
                _wifiSsid.length > 8 ? _wifiSsid.substring(0, 8) : _wifiSsid,
                _isWifiEnabled ? SolarisColors.emerald : SolarisColors.amber,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [SolarisColors.border, SolarisColors.divider, Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightPillar(String title, String value, String sub, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            color: SolarisColors.textMuted,
            fontSize: 8,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            color: accent,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          sub,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            color: SolarisColors.textSecondary,
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildPillarDivider() {
    return Container(
      width: 1,
      height: 24,
      color: SolarisColors.divider,
    );
  }

  Widget _buildExpandedSensors() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: SolarisColors.cardBg,
        borderRadius: BorderRadius.circular(4),
        border: const Border(
          left: BorderSide(color: SolarisColors.cyan, width: 2.0),
        ),
      ),
      child: Column(
        children: [
          _buildExpandedTelemetryRow('PROPULSION ARCH', 'Snapdragon 7 Gen 3 (8-Core)', 'OPTICAL ARRAY', '50MP ZEISS SYSTEM READY'),
          const SizedBox(height: 4),
          _buildExpandedTelemetryRow('POWER BUS', '5,500 mAh · ${_telemetry['batteryTemp']}°C', 'MEMORY ALLOCATION', '${(_telemetry['availRamMb'] / 1024).toStringAsFixed(1)}G Free / ${(_telemetry['totalRamMb'] / 1024).toStringAsFixed(1)}G'),
          const SizedBox(height: 4),
          _buildExpandedTelemetryRow('REAL SENSOR IMU', '${_telemetry['sensorImu']}', 'COMPASS HEADING', '${_compassHeading.toInt().toString().padLeft(3, '0')}° $_compassCardinal'),
          const SizedBox(height: 4),
          _buildExpandedTelemetryRow('NAVIGATION GNSS', '${_telemetry['sensorGps']}', 'LOCAL MESH LINK', '${_telemetry['ipAddress']}'),
        ],
      ),
    );
  }

  Widget _buildExpandedTelemetryRow(String label1, String value1, String label2, String value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label1, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 7, color: SolarisColors.textMuted)),
              Text(value1, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, color: SolarisColors.textPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(label2, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 7, color: SolarisColors.textMuted)),
              Text(value2, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, color: SolarisColors.cyan, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SOLARIS COCKPIT CONTROLS MATRIX (PERFORMANCE MODE, LIGHT, SOUND, WIFI, BT)
  // ===========================================================================
  Widget _buildSolarisCockpitControlsMatrix() {
    return SolarisHullPanel(
      cut: 9.0,
      chamferTopRight: true,
      chamferBottomLeft: true,
      chamferTopLeft: false,
      chamferBottomRight: false,
      fillColor: SolarisColors.cockpitGlass,
      borderColor: SolarisColors.border,
      borderWidth: 0.8,
      accentTicks: true,
      padding: const EdgeInsets.all(SolarisSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. PERFORMANCE MODE GOVERNOR SWITCHER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text('⚡', style: TextStyle(fontSize: 11)),
                  SizedBox(width: 4),
                  Text(
                    'REACTOR GOVERNOR // AVIONICS BUS',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      color: SolarisColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Text(
                _performanceMode == 'WARP'
                    ? '120HZ BURST // MAX COMPUTE'
                    : (_performanceMode == 'ORBITAL' ? '120HZ ADAPTIVE // NOMINAL' : '60HZ CRYO // CONSERVE'),
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  color: _performanceMode == 'WARP'
                      ? SolarisColors.purple
                      : (_performanceMode == 'ORBITAL' ? SolarisColors.cyan : SolarisColors.emerald),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 3 Mode Governor Cockpit Buttons
          Row(
            children: [
              Expanded(
                child: SolarisCockpitButton(
                  title: 'WARP 120Hz',
                  subtitle: 'BURST',
                  tacticalTag: '[PWR-01]',
                  isActive: _performanceMode == 'WARP',
                  activeColor: SolarisColors.purple,
                  onTap: () => _setPerformanceMode('WARP'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SolarisCockpitButton(
                  title: 'ORBITAL',
                  subtitle: 'BALANCED',
                  tacticalTag: '[PWR-02]',
                  isActive: _performanceMode == 'ORBITAL',
                  activeColor: SolarisColors.cyan,
                  onTap: () => _setPerformanceMode('ORBITAL'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SolarisCockpitButton(
                  title: 'CRYO 60Hz',
                  subtitle: 'SAVER',
                  tacticalTag: '[PWR-03]',
                  isActive: _performanceMode == 'CRYO',
                  activeColor: SolarisColors.emerald,
                  onTap: () => _setPerformanceMode('CRYO'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 2. HARDWARE SLIDERS: OPTICAL FLUX & SONIC OUTPUT
          Row(
            children: [
              // OPTICAL FLUX / BRIGHTNESS SLIDER
              Expanded(
                child: SolarisTacticalSlider(
                  label: 'OPTICAL FLUX',
                  icon: Icons.wb_sunny_outlined,
                  value: _lightLevel,
                  accentColor: SolarisColors.cyan,
                  statusTag: '$_lightLevel% FLUX',
                  onHeaderTap: () => platform.invokeMethod('openDisplaySettings'),
                  onChanged: (val) => _setLightLevel(val),
                ),
              ),

              const SizedBox(width: 8),

              // SONIC OUTPUT / VOLUME SLIDER
              Expanded(
                child: SolarisTacticalSlider(
                  label: 'SONIC OUTPUT',
                  icon: _isSoundMuted ? Icons.volume_off : Icons.volume_up_outlined,
                  value: _soundLevel,
                  accentColor: _isSoundMuted ? SolarisColors.amber : SolarisColors.emerald,
                  statusTag: _isSoundMuted ? 'MUTED' : '$_soundLevel% PWR',
                  onHeaderTap: () => platform.invokeMethod('openSoundSettings'),
                  onChanged: (val) => _setAudioLevel(val),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 3. SUBSPACE MESH (WI-FI) & QUANTUM RELAY (BLUETOOTH) QUICK TILES
          Row(
            children: [
              // WI-FI TILE
              Expanded(
                child: SolarisHullPanel(
                  cut: 6.0,
                  chamferTopRight: true,
                  chamferBottomLeft: true,
                  chamferTopLeft: false,
                  chamferBottomRight: false,
                  fillColor: _isWifiEnabled
                      ? SolarisColors.cyan.withOpacity(0.08)
                      : SolarisColors.cardBg,
                  borderColor: _isWifiEnabled
                      ? SolarisColors.cyan
                      : SolarisColors.borderMuted,
                  borderWidth: 0.8,
                  conduitColor: _isWifiEnabled ? SolarisColors.cyan : null,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    platform.invokeMethod('openInternetPanel');
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi,
                        size: 16,
                        color: _isWifiEnabled ? SolarisColors.cyan : SolarisColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isWifiEnabled ? '[COM-01] MESH ACTIVE' : '[COM-01] MESH OFFLINE',
                              style: const TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 7.5,
                                color: SolarisColors.textMuted,
                              ),
                            ),
                            Text(
                              _isWifiEnabled ? _wifiSsid : 'DISCONNECTED',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Rajdhani',
                                fontSize: 11,
                                color: _isWifiEnabled ? SolarisColors.cyan : SolarisColors.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // BLUETOOTH TILE
              Expanded(
                child: SolarisHullPanel(
                  cut: 6.0,
                  chamferTopRight: true,
                  chamferBottomLeft: true,
                  chamferTopLeft: false,
                  chamferBottomRight: false,
                  fillColor: _isBtEnabled
                      ? SolarisColors.purple.withOpacity(0.08)
                      : SolarisColors.cardBg,
                  borderColor: _isBtEnabled
                      ? SolarisColors.purple
                      : SolarisColors.borderMuted,
                  borderWidth: 0.8,
                  conduitColor: _isBtEnabled ? SolarisColors.purple : null,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    platform.invokeMethod('openBluetoothPanel');
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.bluetooth,
                        size: 16,
                        color: _isBtEnabled ? SolarisColors.purple : SolarisColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isBtEnabled ? '[COM-02] RELAY ACTIVE' : '[COM-02] RELAY STANDBY',
                              style: const TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 7.5,
                                color: SolarisColors.textMuted,
                              ),
                            ),
                            Text(
                              _isBtEnabled ? 'ACTIVE BT 5.4' : 'OFFLINE',
                              style: TextStyle(
                                fontFamily: 'Rajdhani',
                                fontSize: 11,
                                color: _isBtEnabled ? SolarisColors.purple : SolarisColors.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PRIMARY SHIP SYSTEMS GRID
  // ===========================================================================
  Widget _buildShipSystemsGrid() {
    final systems = [
      {'name': 'INSTAGRAM', 'pkg': 'com.instagram.android', 'act': '', 'tag': 'FEED'},
      {'name': 'NAV', 'pkg': 'com.google.android.apps.maps', 'act': '', 'tag': 'MAPS'},
      {'name': 'COMMS', 'pkg': 'com.android.contacts', 'act': 'com.android.dialer.TwelveKeyDialer', 'tag': 'DIAL'},
      {'name': 'OPTICAL', 'pkg': 'com.android.camera', 'act': '', 'tag': 'ZEISS'},
      {'name': 'STORAGE', 'pkg': 'com.google.android.apps.nbu.files', 'act': '', 'tag': 'DATA'},
      {'name': 'SYSTEMS', 'pkg': 'com.android.settings', 'act': '', 'tag': 'CONF'},
      {'name': 'ENGINEERING', 'pkg': 'com.termux', 'act': '', 'tag': 'SHELL'},
      {'name': 'ACOUSTIC', 'pkg': 'com.spotify.music', 'act': '', 'tag': 'WAVE'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'SHIP SYSTEMS // PRIMARY ARRAY',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                color: SolarisColors.textMuted,
                fontSize: 9,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: SolarisSpacing.md),
            Expanded(
              child: Container(
                height: 1,
                color: SolarisColors.divider,
              ),
            ),
          ],
        ),
        const SizedBox(height: SolarisSpacing.sm),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.84,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: systems.length,
            itemBuilder: (context, idx) {
              final item = systems[idx];
              final pkg = item['pkg']!;
              final name = item['name']!;
              final tag = item['tag'] ?? 'SYS';
              final act = item['act']!.isNotEmpty ? item['act'] : null;

              return Builder(
                builder: (cellContext) {
                  return SolarisPressable(
                    pressedScale: 0.90,
                    onTap: () {
                      _launchAppWithAnimation(
                        iconContext: cellContext,
                        systemTitle: name,
                        packageName: pkg,
                        activityName: act,
                      );
                    },
                    child: SolarisHullPanel(
                      cut: 6.0,
                      chamferTopRight: true,
                      chamferBottomLeft: true,
                      chamferTopLeft: false,
                      chamferBottomRight: false,
                      fillColor: const Color(0xE0090D18),
                      borderColor: SolarisColors.borderMuted,
                      borderWidth: 0.7,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 3.5,
                                height: 3.5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: SolarisColors.cyan,
                                ),
                              ),
                              Text(
                                '[${idx + 1}] $tag',
                                style: const TextStyle(
                                  fontFamily: 'JetBrainsMono',
                                  fontSize: 6.5,
                                  color: SolarisColors.textMuted,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SolarisAppIcon(
                            packageName: pkg,
                            directIconPath: _packageIconMap[pkg],
                            size: 38,
                            fallbackLetter: name,
                          ),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Rajdhani',
                              color: SolarisColors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // INTEGRATED FLIGHT DOCK
  // ===========================================================================
  Widget _buildIntegratedFlightDock() {
    final dockSystems = [
      {'name': 'INSTAGRAM', 'pkg': 'com.instagram.android', 'act': '', 'tag': 'SOC'},
      {'name': 'COMMS', 'pkg': 'com.android.contacts', 'act': 'com.android.dialer.TwelveKeyDialer', 'tag': 'TEL'},
      {'name': 'OPTICAL', 'pkg': 'com.android.camera', 'act': '', 'tag': 'CAM'},
      {'name': 'EXT-NET', 'pkg': 'com.android.chrome', 'act': '', 'tag': 'WEB'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SolarisSpacing.lg,
        vertical: 4,
      ),
      child: SolarisHullPanel(
        cut: 8.0,
        chamferTopLeft: true,
        chamferTopRight: true,
        chamferBottomLeft: false,
        chamferBottomRight: false,
        fillColor: const Color(0xE6080C16),
        borderColor: SolarisColors.border,
        borderWidth: 0.8,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dockSystems.map((item) {
            final pkg = item['pkg']!;
            final name = item['name']!;
            final tag = item['tag'] ?? 'DOCK';
            final act = item['act']!.isNotEmpty ? item['act'] : null;

            return Builder(
              builder: (dockContext) {
                return SolarisPressable(
                  pressedScale: 0.88,
                  onTap: () {
                    _launchAppWithAnimation(
                      iconContext: dockContext,
                      systemTitle: name,
                      packageName: pkg,
                      activityName: act,
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: SolarisColors.surfaceElevated.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: SolarisColors.borderMuted,
                            width: 0.6,
                          ),
                        ),
                        child: SolarisAppIcon(
                          packageName: pkg,
                          directIconPath: _packageIconMap[pkg],
                          size: 42,
                          fallbackLetter: name,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tag,
                        style: const TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 7,
                          color: SolarisColors.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. ENGINEERING DECK (SECONDARY DIAGNOSTIC CONSOLE)
  // ===========================================================================
  Widget _buildEngineeringDeckPage(double topSafe, double bottomSafe) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SolarisSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SOLARIS ENGINEERING DECK',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: SolarisColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  child: const Text(
                    '← BRIDGE',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      color: SolarisColors.cyan,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: SolarisSpacing.md),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildDiagnosticCard('VESSEL PROPULSION & HARDWARE', [
                    {'LABEL': 'PROPULSION PLATFORM', 'VALUE': 'Snapdragon 7 Gen 3'},
                    {'LABEL': 'CORE ARRAY', 'VALUE': '${_telemetry['cpuCores']} Cores (ARMv9 2.63GHz)'},
                    {'LABEL': 'HUD REFRESH', 'VALUE': '${_telemetry['refreshRate']}Hz AMOLED 1.5K'},
                    {'LABEL': 'MEMORY BUS', 'VALUE': '${_telemetry['usedRamMb']}MB / ${_telemetry['totalRamMb']}MB'},
                    {'LABEL': 'STORAGE MATRIX', 'VALUE': '${_telemetry['availStorageGb']} GB FREE'},
                  ]),
                  const SizedBox(height: SolarisSpacing.md),
                  _buildDiagnosticCard('POWER BUS & BLUEVOLT LIFE SUPPORT', [
                    {'LABEL': 'STORAGE CELL', 'VALUE': '5,500 mAh BlueVolt'},
                    {'LABEL': 'POWER LEVEL', 'VALUE': '${_telemetry['batteryLevel']}%'},
                    {'LABEL': 'THERMAL SINK', 'VALUE': '${_telemetry['batteryTemp']} °C'},
                    {'LABEL': 'TRANSFER BUS', 'VALUE': _telemetry['isCharging'] ? 'FLASHCHARGE ACTIVE' : 'DISCHARGING NOMINAL'},
                  ]),
                  const SizedBox(height: SolarisSpacing.md),
                  _buildDiagnosticCard('ONBOARD SENSOR ARRAY (HARDWARE)', [
                    {'LABEL': 'INERTIAL MEASUREMENT (IMU)', 'VALUE': '${_telemetry['sensorImu']}'},
                    {'LABEL': 'MAGNETOMETER / COMPASS', 'VALUE': '${_compassHeading.toInt().toString().padLeft(3, '0')}° $_compassCardinal (CALIBRATED)'},
                    {'LABEL': 'AMBIENT FLUX DETECTOR', 'VALUE': '${_telemetry['sensorLight']}'},
                    {'LABEL': 'GNSS / ORBITAL TRACKING', 'VALUE': '${_telemetry['sensorGps']}'},
                    {'LABEL': 'LOCAL MESH INTERFACE', 'VALUE': '${_telemetry['ipAddress']}'},
                  ]),
                  const SizedBox(height: SolarisSpacing.md),
                  _buildDiagnosticCard('VESSEL SYSTEM ACTIONS', [], actionButtons: [
                    _buildActionButton('OPEN HOME CONTROL SETTINGS', () {
                      platform.invokeMethod('openHomeSettings');
                    }),
                    const SizedBox(height: SolarisSpacing.sm),
                    _buildActionButton('ALWAYS-ON DISPLAY (AOD) CONFIG', () {
                      platform.invokeMethod('openAODSettings');
                    }),
                    const SizedBox(height: SolarisSpacing.sm),
                    _buildActionButton('DEVELOPER & USB BRIDGE SETTINGS', () {
                      platform.invokeMethod('openDevSettings');
                    }),
                    const SizedBox(height: SolarisSpacing.sm),
                    _buildActionButton('VIVO SMART ISLAND & NOTIFICATIONS', () {
                      platform.invokeMethod('openIslandSettings');
                    }),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticCard(String title, List<Map<String, String>> items,
      {List<Widget>? actionButtons}) {
    return SolarisHullPanel(
      cut: 8.0,
      chamferTopRight: true,
      chamferBottomLeft: true,
      chamferTopLeft: false,
      chamferBottomRight: false,
      fillColor: SolarisColors.cockpitGlass,
      borderColor: SolarisColors.border,
      borderWidth: 0.8,
      accentTicks: true,
      padding: const EdgeInsets.all(SolarisSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: SolarisColors.cyan,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  color: SolarisColors.cyan,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: SolarisSpacing.sm),
          ...items.map((it) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(it['LABEL']!,
                      style: const TextStyle(
                        fontFamily: 'Rajdhani',
                        color: SolarisColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )),
                  Text(it['VALUE']!,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        color: SolarisColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            );
          }),
          if (actionButtons != null) ...actionButtons,
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SolarisHullPanel(
        cut: 6.0,
        chamferTopRight: true,
        chamferBottomLeft: true,
        chamferTopLeft: false,
        chamferBottomRight: false,
        fillColor: SolarisColors.surfaceElevated,
        borderColor: SolarisColors.border,
        borderWidth: 0.8,
        conduitColor: SolarisColors.cyan,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                color: SolarisColors.cyan,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: SolarisColors.cyan,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. APPLICATION MATRIX (SOLARIS ALIEN COMMAND MATRIX DRAWER)
  // ===========================================================================
  String _classifyApp(String pkg, String name) {
    final p = pkg.toLowerCase();
    final n = name.toLowerCase();

    if (p.contains('setting') || p.contains('system') || p.contains('security') ||
        p.contains('launcher') || p.contains('permission') || p.contains('bbk') ||
        n.contains('settings') || n.contains('system') || n.contains('security')) {
      return 'SYS';
    }
    if (p.contains('phone') || p.contains('dialer') || p.contains('contact') ||
        p.contains('message') || p.contains('sms') || p.contains('mms') ||
        p.contains('mail') || p.contains('whatsapp') || p.contains('telegram') ||
        p.contains('chat') || n.contains('whatsapp') || n.contains('phone') ||
        n.contains('messages') || n.contains('contacts')) {
      return 'COM';
    }
    if (p.contains('chrome') || p.contains('browser') || p.contains('web') ||
        p.contains('instagram') || p.contains('youtube') || p.contains('twitter') ||
        p.contains('social') || n.contains('instagram') || n.contains('youtube') ||
        n.contains('browser') || n.contains('chrome')) {
      return 'NET';
    }
    if (p.contains('music') || p.contains('spotify') || p.contains('camera') ||
        p.contains('gallery') || p.contains('photo') || p.contains('video') ||
        p.contains('media') || p.contains('audio') || n.contains('spotify') ||
        n.contains('camera') || n.contains('gallery') || n.contains('photos')) {
      return 'MEDIA';
    }
    return 'ENG';
  }

  String _getDayName(int day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[(day - 1).clamp(0, 6)];
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}

// =============================================================================
// SOLARIS MATRIX DRAWER MODAL WIDGET (STATEFUL MODAL COMPONENT)
// =============================================================================
class _AlphabetScrubData {
  final String letter;
  final String appName;
  final double y;

  const _AlphabetScrubData({
    required this.letter,
    required this.appName,
    required this.y,
  });
}

String _getAppLetterKey(String? rawName) {
  if (rawName == null) return '#';
  final trimmed = rawName.trim().toUpperCase();
  if (trimmed.isEmpty) return '#';
  final first = trimmed[0];
  return (first.codeUnitAt(0) >= 65 && first.codeUnitAt(0) <= 90) ? first : '#';
}

class _SolarisMatrixDrawerModal extends StatefulWidget {
  final List<Map<String, dynamic>> installedApps;
  final Map<String, String> packageIconMap;
  final Map<String, dynamic> telemetry;
  final String Function(String pkg, String name) classifyApp;
  final VoidCallback onClose;
  final Function(BuildContext, String, String, String?, String?) onLaunchApp;

  const _SolarisMatrixDrawerModal({
    required this.installedApps,
    required this.packageIconMap,
    required this.telemetry,
    required this.classifyApp,
    required this.onClose,
    required this.onLaunchApp,
  });

  @override
  State<_SolarisMatrixDrawerModal> createState() => _SolarisMatrixDrawerModalState();
}

class _SolarisMatrixDrawerModalState extends State<_SolarisMatrixDrawerModal> {
  static const List<String> _alphabet = [
    '#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<_AlphabetScrubData?> _scrubNotifier = ValueNotifier(null);
  final ValueNotifier<String?> _activeRailLetterNotifier = ValueNotifier(null);

  String _selectedCategory = 'ALL';
  String _searchQuery = '';
  final List<String> _categories = ['ALL', 'SYS', 'COM', 'NET', 'MEDIA', 'ENG'];

  List<Map<String, dynamic>> _allSortedApps = [];
  final Map<String, List<Map<String, dynamic>>> _categoryApps = {};
  final Map<String, int> _categoryCounts = {};
  List<Map<String, dynamic>> _filteredApps = [];
  final Map<String, int> _letterToIndex = {};

  Timer? _scrubHideTimer;
  int _lastSoundTimeMs = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didUpdateWidget(covariant _SolarisMatrixDrawerModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.installedApps != widget.installedApps) {
      _initData();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrubHideTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _scrubNotifier.dispose();
    _activeRailLetterNotifier.dispose();
    super.dispose();
  }

  void _initData() {
    _allSortedApps = List<Map<String, dynamic>>.from(widget.installedApps);
    _allSortedApps.sort((a, b) {
      final nameA = (a['name'] as String? ?? '').trim().toUpperCase();
      final nameB = (b['name'] as String? ?? '').trim().toUpperCase();
      return nameA.compareTo(nameB);
    });

    _categoryApps.clear();
    _categoryCounts.clear();
    _categoryApps['ALL'] = _allSortedApps;
    _categoryCounts['ALL'] = _allSortedApps.length;

    for (final cat in _categories) {
      if (cat == 'ALL') continue;
      final filtered = _allSortedApps.where((app) {
        final name = (app['name'] as String? ?? '').toLowerCase();
        final pkg = (app['package'] as String? ?? '').toLowerCase();
        return widget.classifyApp(pkg, name) == cat;
      }).toList();
      _categoryApps[cat] = filtered;
      _categoryCounts[cat] = filtered.length;
    }

    _recomputeFilteredApps();
  }

  void _recomputeFilteredApps() {
    final base = _categoryApps[_selectedCategory] ?? _allSortedApps;
    if (_searchQuery.trim().isEmpty) {
      _filteredApps = base;
    } else {
      final q = _searchQuery.trim().toLowerCase();
      _filteredApps = base.where((app) {
        final name = (app['name'] as String? ?? '').toLowerCase();
        final pkg = (app['package'] as String? ?? '').toLowerCase();
        return name.contains(q) || pkg.contains(q);
      }).toList();
    }
    _recomputeLetterIndices();
  }

  void _recomputeLetterIndices() {
    _letterToIndex.clear();
    for (int i = 0; i < _filteredApps.length; i++) {
      final key = _getAppLetterKey(_filteredApps[i]['name'] as String?);
      if (!_letterToIndex.containsKey(key)) {
        _letterToIndex[key] = i;
      }
    }

    int? nextTarget;
    for (int i = _alphabet.length - 1; i >= 0; i--) {
      final l = _alphabet[i];
      if (_letterToIndex.containsKey(l)) {
        nextTarget = _letterToIndex[l];
      } else if (nextTarget != null) {
        _letterToIndex[l] = nextTarget;
      }
    }
  }

  void _handleAlphabetTouch({
    required double localY,
    required double railHeight,
    required double availableHeight,
    required double rowHeight,
  }) {
    if (railHeight <= 0 || _filteredApps.isEmpty) return;
    final letterHeight = railHeight / _alphabet.length;
    final int idx = (localY / letterHeight).floor().clamp(0, _alphabet.length - 1);
    final String letter = _alphabet[idx];

    final targetIdx = _letterToIndex[letter] ?? -1;
    final appName = (targetIdx != -1 && targetIdx < _filteredApps.length)
        ? (_filteredApps[targetIdx]['name'] as String? ?? '')
        : '';

    if (_activeRailLetterNotifier.value != letter) {
      _activeRailLetterNotifier.value = letter;
      HapticFeedback.selectionClick();

      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastSoundTimeMs > 65) {
        _lastSoundTimeMs = now;
        _SolarisHomeScreenState.platform
            .invokeMethod('playSciFiSound', {'sound': 'alphabet_tick'})
            .catchError((_) {});
      }
    }

    _scrubHideTimer?.cancel();
    _scrubNotifier.value = _AlphabetScrubData(
      letter: letter,
      appName: appName,
      y: localY,
    );

    if (targetIdx != -1 && _scrollController.hasClients) {
      final int row = targetIdx ~/ 4;
      const double gridPaddingTop = SolarisSpacing.xs;
      final double rowTop = gridPaddingTop + (row * rowHeight);

      // Center the target row at ~35% of the viewport (eye level in upper-middle)
      final double targetOffset = (rowTop - (availableHeight * 0.35))
          .clamp(0.0, _scrollController.position.maxScrollExtent);

      _scrollController.jumpTo(targetOffset);
    }
  }

  void _finishAlphabetTouch() {
    _scrubHideTimer?.cancel();
    _scrubHideTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) {
        _scrubNotifier.value = null;
        _activeRailLetterNotifier.value = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topSafe = media.padding.top;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification && notification.overscroll < -18) {
          widget.onClose();
          return true;
        }
        if (notification is ScrollUpdateNotification &&
            notification.metrics.pixels <= 0 &&
            notification.scrollDelta != null &&
            notification.scrollDelta! < -22) {
          widget.onClose();
          return true;
        }
        return false;
      },
      child: Container(
        margin: EdgeInsets.only(top: topSafe + 8),
        decoration: BoxDecoration(
          color: const Color(0xF2070D18),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: SolarisColors.cyan.withOpacity(0.50), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: SolarisColors.cyan.withOpacity(0.18),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Grip Handle with swipe-down dismissal
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragEnd: (d) {
                if (d.primaryVelocity != null && d.primaryVelocity! > 180) {
                  widget.onClose();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SolarisColors.cyan.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: SolarisColors.cyan.withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // MATRIX HEADER & REPOSITORY STATUS (SWIPE DOWN DISMISSAL AS WELL)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragEnd: (d) {
                if (d.primaryVelocity != null && d.primaryVelocity! > 180) {
                  widget.onClose();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: SolarisSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text('◈', style: TextStyle(color: SolarisColors.cyan, fontSize: 13, fontWeight: FontWeight.bold)),
                            SizedBox(width: 6),
                            Text(
                              'SOLARIS // APPLICATION MATRIX',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                color: SolarisColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'SYSTEMS INDEXED: ${widget.installedApps.length} // ALL REPOSITORIES ONLINE',
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            color: SolarisColors.textMuted,
                            fontSize: 9,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: widget.onClose,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: SolarisColors.cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: SolarisColors.cyan.withOpacity(0.6), width: 0.8),
                        ),
                        child: const Icon(Icons.close, size: 14, color: SolarisColors.cyan),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: SolarisSpacing.sm),

            // HOLOGRAPHIC SEARCH BAR (CHAMFERED FRAME)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SolarisSpacing.lg),
              child: Container(
                decoration: BoxDecoration(
                  color: SolarisColors.cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SolarisColors.borderBright, width: 0.8),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                      _recomputeFilteredApps();
                    });
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(0.0);
                    }
                  },
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    color: SolarisColors.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: '⬡ SEARCH COMMAND MATRIX REPOSITORY...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Rajdhani',
                      color: SolarisColors.textMuted,
                      fontSize: 13,
                      letterSpacing: 1.0,
                    ),
                    prefixIcon: const Icon(Icons.search, color: SolarisColors.cyan, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _recomputeFilteredApps();
                              });
                            },
                            child: const Icon(Icons.clear, color: SolarisColors.cyan, size: 16),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: SolarisSpacing.xs),

            // SUBSYSTEM CATEGORY FILTER TABS
            SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: SolarisSpacing.lg),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, idx) {
                  final cat = _categories[idx];
                  final count = _categoryCounts[cat] ?? 0;
                  final isSelected = _selectedCategory == cat;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedCategory = cat;
                        _recomputeFilteredApps();
                      });
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(0.0);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? SolarisColors.cyan.withOpacity(0.18) : SolarisColors.cardBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected ? SolarisColors.cyan : SolarisColors.borderMuted,
                          width: isSelected ? 1.2 : 0.6,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cat,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              color: isSelected ? SolarisColors.cyan : SolarisColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '[$count]',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              color: isSelected ? SolarisColors.cyan : SolarisColors.textMuted,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: SolarisSpacing.xs),

            // 4-COLUMN RESPONSIVE APP MATRIX GRID WITH VIVO-STYLE ALPHABET SCROLLBAR
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  final availableWidth = constraints.maxWidth;
                  final gridWidth = (availableWidth - 36);
                  final contentWidth = gridWidth - (SolarisSpacing.md + 4);
                  final itemWidth = (contentWidth - 24) / 4.0;
                  final itemHeight = itemWidth / 0.74;
                  final rowHeight = itemHeight + 10.0;

                  return Stack(
                    children: [
                      Row(
                        children: [
                          // Main Grid
                          Expanded(
                            child: _filteredApps.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.radar, color: SolarisColors.cyan, size: 36),
                                        SizedBox(height: 10),
                                        Text(
                                          'ZERO TARGETS DETECTED IN SECTOR',
                                          style: TextStyle(
                                            fontFamily: 'JetBrainsMono',
                                            color: SolarisColors.textMuted,
                                            fontSize: 11,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : GridView.builder(
                                    controller: _scrollController,
                                    physics: const AlwaysScrollableScrollPhysics(
                                      parent: BouncingScrollPhysics(),
                                    ),
                                    padding: const EdgeInsets.only(
                                      left: SolarisSpacing.md,
                                      right: 4,
                                      top: SolarisSpacing.xs,
                                      bottom: SolarisSpacing.xl,
                                    ),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 0.74,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemCount: _filteredApps.length,
                                    itemBuilder: (cellContext, idx) {
                                      final app = _filteredApps[idx];
                                      final name = app['name'] as String? ?? 'UNKNOWN';
                                      final pkg = app['package'] as String? ?? '';
                                      final cls = app['class'] as String?;
                                      final iconPath = app['iconPath'] as String?;
                                      final catTag = widget.classifyApp(pkg, name);

                                      final letterKey = _getAppLetterKey(name);
                                      final isFirstOfLetter = (idx == 0) ||
                                          (_getAppLetterKey(_filteredApps[idx - 1]['name'] as String?) != letterKey);

                                      return RepaintBoundary(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(8),
                                            splashColor: SolarisColors.cyan.withOpacity(0.20),
                                            highlightColor: SolarisColors.cyan.withOpacity(0.08),
                                            onTap: () {
                                              HapticFeedback.lightImpact();
                                              widget.onLaunchApp(cellContext, name, pkg, cls, iconPath);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: SolarisColors.cardBg,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isFirstOfLetter
                                                      ? SolarisColors.cyan.withOpacity(0.5)
                                                      : SolarisColors.borderMuted,
                                                  width: isFirstOfLetter ? 1.0 : 0.6,
                                                ),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  // Letter Section Indicator Badge on First App of Letter
                                                  if (isFirstOfLetter)
                                                    Positioned(
                                                      top: 0,
                                                      left: 0,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                                        decoration: BoxDecoration(
                                                          color: SolarisColors.cyan.withOpacity(0.18),
                                                          borderRadius: BorderRadius.circular(3),
                                                          border: Border.all(
                                                            color: SolarisColors.cyan.withOpacity(0.6),
                                                            width: 0.6,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          letterKey,
                                                          style: const TextStyle(
                                                            fontFamily: 'Orbitron',
                                                            color: SolarisColors.cyan,
                                                            fontSize: 7.5,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                  // Card Content
                                                  Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const SizedBox(height: 2),
                                                        SolarisAppIcon(
                                                          packageName: pkg,
                                                          directIconPath: iconPath,
                                                          size: 46,
                                                          fallbackLetter: name,
                                                        ),
                                                        const SizedBox(height: 5),
                                                        Text(
                                                          name,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          textAlign: TextAlign.center,
                                                          style: const TextStyle(
                                                            fontFamily: 'Rajdhani',
                                                            color: SolarisColors.textPrimary,
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          '$catTag-${(idx + 1).toString().padLeft(2, '0')}',
                                                          style: const TextStyle(
                                                            fontFamily: 'JetBrainsMono',
                                                            color: SolarisColors.textMuted,
                                                            fontSize: 7,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),

                          // VIVO-STYLE ALPHABET SCROLLBAR RAIL
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onVerticalDragStart: (d) => _handleAlphabetTouch(
                              localY: d.localPosition.dy,
                              railHeight: availableHeight,
                              availableHeight: availableHeight,
                              rowHeight: rowHeight,
                            ),
                            onVerticalDragUpdate: (d) => _handleAlphabetTouch(
                              localY: d.localPosition.dy,
                              railHeight: availableHeight,
                              availableHeight: availableHeight,
                              rowHeight: rowHeight,
                            ),
                            onVerticalDragEnd: (_) => _finishAlphabetTouch(),
                            onVerticalDragCancel: () => _finishAlphabetTouch(),
                            onTapDown: (d) {
                              _handleAlphabetTouch(
                                localY: d.localPosition.dy,
                                railHeight: availableHeight,
                                availableHeight: availableHeight,
                                rowHeight: rowHeight,
                              );
                              _finishAlphabetTouch();
                            },
                            child: Container(
                              width: 36, // Generous touch hit area
                              margin: const EdgeInsets.only(right: 2, top: 4, bottom: 8),
                              alignment: Alignment.center,
                              child: Container(
                                width: 18, // Sleek visual column
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0x77080F1D),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: SolarisColors.cyan.withOpacity(0.4),
                                    width: 0.8,
                                  ),
                                ),
                                child: ValueListenableBuilder<String?>(
                                  valueListenable: _activeRailLetterNotifier,
                                  builder: (context, activeLetter, _) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: _alphabet.map((letter) {
                                        final isActive = activeLetter == letter;
                                        return Text(
                                          letter,
                                          style: TextStyle(
                                            fontFamily: 'Orbitron',
                                            fontSize: isActive ? 9.5 : 7.5,
                                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                            color: isActive
                                                ? SolarisColors.cyan
                                                : SolarisColors.textMuted.withOpacity(0.7),
                                            shadows: isActive
                                                ? [
                                                    Shadow(
                                                      color: SolarisColors.cyan.withOpacity(0.8),
                                                      blurRadius: 6,
                                                    )
                                                  ]
                                                : null,
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // FLOATING HOLOGRAPHIC RETICLE BUBBLE
                      ValueListenableBuilder<_AlphabetScrubData?>(
                        valueListenable: _scrubNotifier,
                        builder: (context, data, _) {
                          if (data == null) return const SizedBox.shrink();

                          final bubbleTop = (data.y - 30).clamp(10.0, availableHeight - 74.0);

                          return Positioned(
                            right: 42,
                            top: bubbleTop,
                            child: IgnorePointer(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xF2070D18),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: SolarisColors.cyan, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: SolarisColors.cyan.withOpacity(0.4),
                                      blurRadius: 18,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      data.letter,
                                      style: const TextStyle(
                                        fontFamily: 'Orbitron',
                                        color: SolarisColors.cyan,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (data.appName.isNotEmpty) ...[
                                      const SizedBox(width: 10),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 130),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'TARGET ACQUIRED',
                                              style: TextStyle(
                                                fontFamily: 'JetBrainsMono',
                                                color: SolarisColors.emerald,
                                                fontSize: 7,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                            Text(
                                              data.appName.toUpperCase(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontFamily: 'Rajdhani',
                                                color: SolarisColors.textPrimary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
