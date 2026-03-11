import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelTheme {
  // ── Palette ───────────────────────────────────────────────────────────
  static const Color bg           = Color(0xFF07070F);
  static const Color bgDark       = Color(0xFF030308);
  static const Color surface      = Color(0xFF0F0F1A);
  static const Color surfaceHi    = Color(0xFF161624);
  static const Color border       = Color(0xFF2A2A42);
  static const Color borderDim    = Color(0xFF181828);
  static const Color borderBright = Color(0xFF42426A);
  static const Color accent       = Color(0xFFFFD700);
  static const Color accentDim    = Color(0xFF887200);
  static const Color accent2      = Color(0xFFFF4466);
  static const Color accent3      = Color(0xFF3EE87A);
  static const Color accent4      = Color(0xFF3AACFF);
  static const Color accent5      = Color(0xFFFF8833);
  static const Color textPrimary  = Color(0xFFDDDDEE);
  static const Color textSec      = Color(0xFF58587A);
  static const Color textDim      = Color(0xFF2E2E4A);
  static const Color navBg        = Color(0xFF09090F);

  // ── Font (cached — call GoogleFonts once, copyWith everywhere else) ───
  static final TextStyle _base = GoogleFonts.pressStart2p();

  static TextStyle pixelFont({
    double size = 11,
    Color color = textPrimary,
    FontWeight weight = FontWeight.normal,
    double letterSpacing = 0.4,
    List<Shadow>? shadows,
  }) =>
      _base.copyWith(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        shadows: shadows ??
            const [Shadow(offset: Offset(2, 2), color: Colors.black)],
      );

  static TextStyle titleFont({double size = 13}) => _base.copyWith(
        fontSize: size,
        color: accent,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        shadows: const [
          Shadow(
              offset: Offset(0, 0),
              color: Color(0x99FFD700),
              blurRadius: 6),
          Shadow(offset: Offset(2, 2), color: Colors.black),
        ],
      );

  // Pre-baked styles used in lists ─────────────────────────────────────
  static final TextStyle t7sec =
      pixelFont(size: 7, color: textSec, shadows: []);
  static final TextStyle t8sec =
      pixelFont(size: 8, color: textSec, shadows: []);
  static final TextStyle t9sec =
      pixelFont(size: 9, color: textSec, shadows: []);
  static final TextStyle t9pri =
      pixelFont(size: 9, color: textPrimary, weight: FontWeight.bold, shadows: []);
  static final TextStyle t9acc =
      pixelFont(size: 9, color: accent, weight: FontWeight.bold, shadows: []);

  // ── ThemeData ─────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        primaryColor: accent,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accent2,
          surface: surface,
          background: bg,
          error: accent2,
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL CARD  — Container-only, zero CustomPainter
// ═══════════════════════════════════════════════════════════════════════════
class PixelCard extends StatelessWidget {
  final Widget child;
  final Color? fillColor;
  final Color? borderColor;
  final bool selected;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const PixelCard({
    Key? key,
    required this.child,
    this.fillColor,
    this.borderColor,
    this.selected = false,
    this.onTap,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bc =
        borderColor ?? (selected ? PixelTheme.accent : PixelTheme.border);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fillColor ?? PixelTheme.surface,
          border: Border.all(color: bc, width: selected ? 2.5 : 2),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(3, 3)),
          ],
        ),
        child: child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL BUTTON
// ═══════════════════════════════════════════════════════════════════════════
class PixelButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool enabled;
  final double fontSize;

  const PixelButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.color,
    this.enabled = true,
    this.fontSize = 10,
  }) : super(key: key);

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color =
        widget.enabled ? (widget.color ?? PixelTheme.accent) : PixelTheme.border;
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel:
          widget.enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onPressed : null,
      child: Transform.translate(
        offset: _pressed ? const Offset(3, 3) : Offset.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: _pressed
                ? null
                : const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: PixelTheme.pixelFont(
              size: widget.fontSize,
              weight: FontWeight.bold,
              color: PixelTheme.bg,
              shadows: [],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL SECTION LABEL
// ═══════════════════════════════════════════════════════════════════════════
class PixelSectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const PixelSectionLabel(this.text, {this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = color ?? PixelTheme.accent;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 3, height: 9, color: c),
        const SizedBox(width: 7),
        Text(
          text.toUpperCase(),
          style: PixelTheme.pixelFont(
              size: 8,
              weight: FontWeight.bold,
              color: c,
              letterSpacing: 0.5,
              shadows: []),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL BIG VALUE
// ═══════════════════════════════════════════════════════════════════════════
class PixelBigValue extends StatelessWidget {
  final String text;
  final Color? color;
  const PixelBigValue(this.text, {this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: PixelTheme.pixelFont(
          size: 20,
          weight: FontWeight.bold,
          color: color ?? PixelTheme.accent,
          shadows: const [Shadow(offset: Offset(3, 3), color: Colors.black)],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL DIVIDER
// ═══════════════════════════════════════════════════════════════════════════
class PixelDivider extends StatelessWidget {
  const PixelDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(height: 2, color: PixelTheme.border),
          const SizedBox(height: 2),
          Container(height: 1, color: PixelTheme.borderDim),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL CHECKBOX
// ═══════════════════════════════════════════════════════════════════════════
class PixelCheckbox extends StatelessWidget {
  final bool checked;
  final VoidCallback? onTap;
  const PixelCheckbox({Key? key, required this.checked, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: checked ? PixelTheme.accent : PixelTheme.bgDark,
            border: Border.all(
              color: checked ? PixelTheme.accentDim : PixelTheme.border,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(2, 2))
            ],
          ),
          child: checked
              ? const Icon(Icons.check, size: 13, color: Colors.black)
              : null,
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL TOGGLE
// ═══════════════════════════════════════════════════════════════════════════
class PixelToggle extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  const PixelToggle({Key? key, required this.value, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = value ? PixelTheme.accent3 : PixelTheme.border;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
              color: value ? PixelTheme.accent3 : PixelTheme.borderBright,
              width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(3, 3))
          ],
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Text(
          value ? 'ON' : 'OFF',
          style: PixelTheme.pixelFont(
            size: 7,
            color: value ? PixelTheme.bg : PixelTheme.textSec,
            weight: FontWeight.bold,
            shadows: [],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL TITLE BAR  — Future-based blink (no AnimationController)
// ═══════════════════════════════════════════════════════════════════════════
class PixelTitleBar extends StatefulWidget {
  final String title;
  final Widget? trailing;
  final double topPadding;
  const PixelTitleBar({
    Key? key,
    required this.title,
    this.trailing,
    this.topPadding = 0,
  }) : super(key: key);

  @override
  State<PixelTitleBar> createState() => _PixelTitleBarState();
}

class _PixelTitleBarState extends State<PixelTitleBar> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _blink();
  }

  void _blink() {
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() => _visible = !_visible);
        _blink();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PixelTheme.bg,
      padding: EdgeInsets.only(
          top: widget.topPadding + 12,
          left: 14,
          right: 14,
          bottom: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Container(
              width: 5,
              height: 16,
              color: PixelTheme.accent,
              margin: const EdgeInsets.only(right: 9)),
          Expanded(
            child: Row(children: [
              Text(widget.title, style: PixelTheme.titleFont(size: 12)),
              const SizedBox(width: 5),
              Visibility(
                visible: _visible,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child:
                    Container(width: 8, height: 12, color: PixelTheme.accent),
              ),
            ]),
          ),
          if (widget.trailing != null) widget.trailing!,
        ]),
        const SizedBox(height: 10),
        Container(height: 3, color: PixelTheme.accent),
        const SizedBox(height: 2),
        Container(height: 1, color: PixelTheme.accentDim),
        const SizedBox(height: 8),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PIXEL PROGRESS BAR
// ═══════════════════════════════════════════════════════════════════════════
class PixelProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;
  const PixelProgressBar({Key? key, required this.progress, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        height: 16,
        decoration: BoxDecoration(
          color: PixelTheme.bgDark,
          border: Border.all(color: PixelTheme.border, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(2, 2))
          ],
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(color: color ?? PixelTheme.accent3),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
//  CRT + DITHER — passthroughs (effects removed for perf, style kept via palette)
// ═══════════════════════════════════════════════════════════════════════════
class CRTScreen extends StatelessWidget {
  final Widget child;
  const CRTScreen({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) => child;
}

class DitherBackground extends StatelessWidget {
  final Widget child;
  const DitherBackground({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: PixelTheme.bg, child: child);
}