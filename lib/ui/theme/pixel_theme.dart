import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎮 Retro Pixel UI Theme System
class PixelTheme {
  
  // ══════════════════════════════════════════════════════════════════════
  //  RETRO PIXEL PALETTE
  // ══════════════════════════════════════════════════════════════════════
  
  static const Color bg = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color border = Color(0xFF2A2A3A);
  static const Color accent = Color(0xFFF5C542);
  static const Color accent2 = Color(0xFFFF6B6B);
  static const Color accent3 = Color(0xFF6BCF7F);
  static const Color textPrimary = Color(0xFFE8E8E8);
  static const Color textSecondary = Color(0xFF666680);
  static const Color navBg = Color(0xFF0D0D15);
  static const Color shadow = Color(0xFF000000);
  
  // ══════════════════════════════════════════════════════════════════════
  //  PIXEL FONT
  // ══════════════════════════════════════════════════════════════════════
  
  static TextStyle pixelFont({
    double size = 14,
    Color color = textPrimary,
    FontWeight weight = FontWeight.normal,
    double letterSpacing = 0.1,
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      shadows: [
        Shadow(
          offset: const Offset(2, 2),
          color: shadow.withOpacity(0.8),
        ),
      ],
    );
  }
  
  // ══════════════════════════════════════════════════════════════════════
  //  THEME DATA
  // ══════════════════════════════════════════════════════════════════════
  
  static ThemeData get theme {
    return ThemeData(
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
      textTheme: TextTheme(
        displayLarge: pixelFont(size: 24, weight: FontWeight.bold),
        displayMedium: pixelFont(size: 20, weight: FontWeight.bold),
        displaySmall: pixelFont(size: 18, weight: FontWeight.bold),
        headlineMedium: pixelFont(size: 16, weight: FontWeight.bold),
        titleLarge: pixelFont(size: 14, weight: FontWeight.bold),
        bodyLarge: pixelFont(size: 13),
        bodyMedium: pixelFont(size: 12),
        labelLarge: pixelFont(size: 11, weight: FontWeight.bold, color: textSecondary),
      ),
    );
  }
}

/// 🎨 Pixel UI Widgets

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fillColor ?? PixelTheme.surface,
          border: Border.all(
            color: borderColor ?? (selected ? PixelTheme.accent : PixelTheme.border),
            width: selected ? 6 : 4,
          ),
          // Sharp corners for pixel aesthetic
          borderRadius: BorderRadius.zero,
        ),
        child: child,
      ),
    );
  }
}

class PixelButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool enabled;
  
  const PixelButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.color,
    this.enabled = true,
  }) : super(key: key);
  
  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _pressed = false;
  
  @override
  Widget build(BuildContext context) {
    final color = widget.enabled 
        ? (widget.color ?? PixelTheme.accent) 
        : PixelTheme.border;
    
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        margin: EdgeInsets.only(
          bottom: _pressed ? 2 : 4,
          top: _pressed ? 4 : 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: PixelTheme.shadow, width: 3),
          borderRadius: BorderRadius.zero,
          boxShadow: _pressed ? [] : [
            BoxShadow(
              color: PixelTheme.shadow,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          widget.label.toUpperCase(),
          style: PixelTheme.pixelFont(
            size: 14,
            weight: FontWeight.bold,
            color: PixelTheme.bg,
            letterSpacing: 0.15,
          ).copyWith(shadows: []),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class PixelDivider extends StatelessWidget {
  const PixelDivider({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      margin: const EdgeInsets.symmetric(vertical: 16),
      color: PixelTheme.border,
    );
  }
}

class PixelSectionLabel extends StatelessWidget {
  final String text;
  
  const PixelSectionLabel(this.text, {Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: PixelTheme.pixelFont(
        size: 11,
        weight: FontWeight.bold,
        color: PixelTheme.textSecondary,
        letterSpacing: 0.25,
      ),
    );
  }
}

class PixelBigValue extends StatelessWidget {
  final String text;
  final Color? color;
  
  const PixelBigValue(this.text, {this.color, Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: PixelTheme.pixelFont(
        size: 28,
        weight: FontWeight.bold,
        color: color ?? PixelTheme.accent,
        letterSpacing: 0.15,
      ),
    );
  }
}

class PixelCheckbox extends StatelessWidget {
  final bool checked;
  final VoidCallback? onTap;
  
  const PixelCheckbox({
    Key? key,
    required this.checked,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        checked ? '■' : '□',
        style: PixelTheme.pixelFont(
          size: 28,
          weight: FontWeight.bold,
          color: checked ? PixelTheme.accent : PixelTheme.border,
        ).copyWith(shadows: []),
      ),
    );
  }
}

class PixelProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  
  const PixelProgressBar({
    Key? key,
    required this.progress,
    this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(color: PixelTheme.border, width: 4),
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        children: [
          Expanded(
            flex: (progress * 100).toInt(),
            child: Container(color: color ?? PixelTheme.accent),
          ),
          Expanded(
            flex: ((1 - progress) * 100).toInt(),
            child: Container(color: PixelTheme.surface),
          ),
        ],
      ),
    );
  }
}