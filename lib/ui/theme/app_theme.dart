import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sticker-cartoon theme: warm cream ground, ink outlines, hard offset shadows.
class AppTheme {
  // Ink + neutrals
  static const Color ink = Color(0xFF201E1D);
  static const Color bg = Color(0xFFF5EAD8);
  static const Color surface = Color(0xFFEBDDC5);
  static const Color paper = Color(0xFFF9F4ED);
  static const Color n300 = Color(0xFFDCD3C4);
  static const Color n500 = Color(0xFFA19786);
  static const Color n600 = Color(0xFF82796A);
  static const Color n700 = Color(0xFF645C50);

  // Terracotta
  static const Color accent = Color(0xFFC67139);
  static const Color accent200 = Color(0xFFFFE1D0);
  static const Color accent300 = Color(0xFFFFC6A5);
  static const Color accent400 = Color(0xFFF6A06B);
  static const Color accent600 = Color(0xFFB2622D);
  static const Color accent800 = Color(0xFF643312);

  // Sage
  static const Color sage200 = Color(0xFFE1EECC);
  static const Color sage300 = Color(0xFFCCDBB2);
  static const Color sage400 = Color(0xFFAEBF92);
  static const Color sage500 = Color(0xFF8FA073);
  static const Color sage800 = Color(0xFF3D472B);

  // Legacy aliases (kept so older code still compiles)
  static const Color black = ink;
  static const Color white = paper;
  static const Color lineColor = n300;

  static const double border = 3;

  static double hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 900) return 24;
    if (w > 600) return 20;
    return 18;
  }

  static TextStyle display(double size, {Color color = ink}) =>
      GoogleFonts.caprasimo(fontSize: size, color: color, height: 1.1);

  static TextStyle body({double size = 15, FontWeight weight = FontWeight.w500, Color color = ink}) =>
      GoogleFonts.figtree(fontSize: size, fontWeight: weight, color: color, height: 1.35);

  /// Tiny all-caps label. Pass already-uppercased text.
  static TextStyle kicker({Color color = n700}) => GoogleFonts.figtree(
      fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: color);

  static ThemeData get theme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: bg,
        primaryColor: accent600,
        colorScheme: const ColorScheme.light(primary: accent600, secondary: sage500, surface: bg),
        textTheme: GoogleFonts.figtreeTextTheme(),
        textSelectionTheme: const TextSelectionThemeData(cursorColor: accent600),
      );
}
