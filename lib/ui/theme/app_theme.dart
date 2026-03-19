import 'package:flutter/material.dart';

class AppTheme {
  // ── Bento palette — warm organic ──────────────────────────────────────
  static const Color bg        = Color(0xFFF2EDE4);
  static const Color black     = Color(0xFF1A1A14);
  static const Color white     = Color(0xFFFFF8F0);

  static const Color forest    = Color(0xFF2D4A3E);
  static const Color rust      = Color(0xFFBF4B2E);
  static const Color mustard   = Color(0xFFD4A017);
  static const Color sage      = Color(0xFF8AAF8A);
  static const Color clay      = Color(0xFFB8785A);
  static const Color mint      = Color(0xFFB8D4C8);
  static const Color cream2    = Color(0xFFEADFC8);
  static const Color olive     = Color(0xFF5C6B3A);

  static const Color onDark    = Color(0xFFF2EDE4);
  static const Color onLight   = Color(0xFF1A1A14);

  static const Color lineColor = Color(0xFFDDD5C8);
  static const Color grey5     = Color(0xFF8A8275);
  static const Color orange    = Color(0xFFBF4B2E);
  static const Color green     = Color(0xFF2D4A3E);

  static double hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 900) return w * 0.12;
    if (w > 600) return w * 0.06;
    return 16.0;
  }

  static const TextStyle display = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w900,
    color: black,
    letterSpacing: -1.5,
    height: 0.95,
  );

  static const TextStyle tileHero = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: onDark,
    letterSpacing: -2.0,
    height: 0.9,
  );

  static const TextStyle tileLabel = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: onDark,
    letterSpacing: 1.8,
  );

  static const TextStyle tileLabelDark = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: onLight,
    letterSpacing: 1.8,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: black,
    letterSpacing: -0.6,
    height: 1.1,
  );

  static const TextStyle projectTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: black,
    letterSpacing: -0.2,
  );

  static const TextStyle metaLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Color(0xFF8A8275),
    letterSpacing: 0.2,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A4540),
    height: 1.6,
  );

  static const TextStyle infoKey = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: black,
    letterSpacing: -0.2,
  );

  static const TextStyle infoVal = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF8A8275),
  );

  static const TextStyle navLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: Color(0xFF8A8275),
    letterSpacing: 0.3,
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: black,
    letterSpacing: -0.3,
  );

  static Widget line({double? indent, double? endIndent, BuildContext? context, Color? color}) {
    return Divider(
      height: 1, thickness: 1,
      color: color ?? lineColor,
      indent: indent ?? 0,
      endIndent: endIndent ?? 0,
    );
  }

  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: bg,
    primaryColor: forest,
    colorScheme: const ColorScheme.light(
      primary: forest,
      secondary: rust,
      surface: bg,
      background: bg,
    ),
  );
}