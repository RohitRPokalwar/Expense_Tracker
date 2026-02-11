import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System Tokens as a ThemeExtension for easy access app-wide.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final Color background;
  final Color primaryAccent; // Yellow balance card
  final Color cardBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color accentRed;
  final Color accentGreen;
  final Color iconColor;
  final Color onDark; // text/icons on dark tiles
  final List<Color> chartPalette;

  const AppTokens({
    required this.background,
    required this.primaryAccent,
    required this.cardBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.accentRed,
    required this.accentGreen,
    required this.iconColor,
    required this.onDark,
    required this.chartPalette,
  });

  @override
  AppTokens copyWith({
    Color? background,
    Color? primaryAccent,
    Color? cardBackground,
    Color? primaryText,
    Color? secondaryText,
    Color? accentRed,
    Color? accentGreen,
    Color? iconColor,
    Color? onDark,
    List<Color>? chartPalette,
  }) {
    return AppTokens(
      background: background ?? this.background,
      primaryAccent: primaryAccent ?? this.primaryAccent,
      cardBackground: cardBackground ?? this.cardBackground,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      accentRed: accentRed ?? this.accentRed,
      accentGreen: accentGreen ?? this.accentGreen,
      iconColor: iconColor ?? this.iconColor,
      onDark: onDark ?? this.onDark,
      chartPalette: chartPalette ?? this.chartPalette,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      background: Color.lerp(background, other.background, t) ?? background,
      primaryAccent:
          Color.lerp(primaryAccent, other.primaryAccent, t) ?? primaryAccent,
      cardBackground:
          Color.lerp(cardBackground, other.cardBackground, t) ?? cardBackground,
      primaryText: Color.lerp(primaryText, other.primaryText, t) ?? primaryText,
      secondaryText:
          Color.lerp(secondaryText, other.secondaryText, t) ?? secondaryText,
      accentRed: Color.lerp(accentRed, other.accentRed, t) ?? accentRed,
      accentGreen: Color.lerp(accentGreen, other.accentGreen, t) ?? accentGreen,
      iconColor: Color.lerp(iconColor, other.iconColor, t) ?? iconColor,
      onDark: Color.lerp(onDark, other.onDark, t) ?? onDark,
      chartPalette: other.chartPalette,
    );
  }
}

/// Subtle, reusable shadows for cards and floating elements.
@immutable
class AppShadows extends ThemeExtension<AppShadows> {
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> floatingShadow;
  final List<BoxShadow> cardShadowElevated; // ✅ Added elevated shadow

  const AppShadows({
    required this.cardShadow,
    required this.floatingShadow,
    required this.cardShadowElevated,
  });

  factory AppShadows.light() => AppShadows(
    cardShadow: [
      BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.06),
        blurRadius: 16,
        spreadRadius: 0,
        offset: const Offset(0, 6),
      ),
    ],
    floatingShadow: [
      BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.10),
        blurRadius: 24,
        spreadRadius: 0,
        offset: const Offset(0, 10),
      ),
    ],
    cardShadowElevated: [
      // ✅ Stronger shadow for elevated cards
      BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.12),
        blurRadius: 28,
        spreadRadius: 0,
        offset: const Offset(0, 12),
      ),
    ],
  );

  @override
  AppShadows copyWith({
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? floatingShadow,
    List<BoxShadow>? cardShadowElevated,
  }) {
    return AppShadows(
      cardShadow: cardShadow ?? this.cardShadow,
      floatingShadow: floatingShadow ?? this.floatingShadow,
      cardShadowElevated: cardShadowElevated ?? this.cardShadowElevated,
    );
  }

  @override
  AppShadows lerp(ThemeExtension<AppShadows>? other, double t) {
    if (other is! AppShadows) return this;
    return other;
  }
}

/// Global Fade transitions for a smoother, elegant feel.
class FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
    return FadeTransition(opacity: curved, child: child);
  }
}

class AppTheme {
  // Design System Colors
  static const _background = Color(0xFFF7F9F9);
  static const _primaryAccent = Color.fromRGBO(218, 196, 147, 1); // soft yellow
  static const _cardBackground = Colors.white;
  static const _primaryText = Color(0xFF1E1E1E);
  static const _secondaryText = Color(0xFF8A8A8E);
  static const _accentRed = Color(0xFFFF6B6B);
  static const _accentGreen = Color(0xFF009688);
  static const _iconColor = Color(0xFF5A5A5A);

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _background,
      colorScheme: ColorScheme.light(
        primary: _primaryAccent,
        surface: _cardBackground,
        onPrimary: _primaryText,
        onSurface: _primaryText,
        secondary: _accentGreen,
        error: _accentRed,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadePageTransitionsBuilder(),
          TargetPlatform.iOS: FadePageTransitionsBuilder(),
          TargetPlatform.linux: FadePageTransitionsBuilder(),
          TargetPlatform.macOS: FadePageTransitionsBuilder(),
          TargetPlatform.windows: FadePageTransitionsBuilder(),
        },
      ),
    );

    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: _primaryText,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _primaryText,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _primaryText,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _secondaryText,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _primaryText,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _primaryText,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _primaryText,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: _background,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: _iconColor),
      ),
      cardTheme: CardThemeData(
        color: _cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: textTheme.bodyMedium,
        labelStyle: textTheme.bodyMedium?.copyWith(color: _secondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: _primaryText.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: _primaryText.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primaryAccent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryAccent,
          foregroundColor: _primaryText,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryText,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          side: BorderSide(color: _primaryText.withValues(alpha: 0.10)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _primaryText,
        contentTextStyle: textTheme.bodyLarge?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppTokens(
          background: _background,
          primaryAccent: _primaryAccent,
          cardBackground: _cardBackground,
          primaryText: _primaryText,
          secondaryText: _secondaryText,
          accentRed: _accentRed,
          accentGreen: _accentGreen,
          iconColor: _iconColor,
          onDark: Colors.white,
          chartPalette: [
            _primaryAccent,
            _accentGreen,
            _accentRed,
            const Color(0xFF7C8DB5),
            const Color(0xFF23B6E6),
            const Color(0xFF00D5A3),
          ],
        ),
        AppShadows.light(),
      ],
    );
  }
}
