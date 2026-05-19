import 'package:flutter/material.dart';
import 'package:umg_activo_colaborador/screens/partidas_screen.dart';
import 'package:umg_activo_colaborador/screens/screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryPink = Color(0xFF8B1A4A);
    const deepRose = Color(0xFF5C0F30);
    const accentPurple = Color(0xFF9C27B0);
    const softPurple = Color(0xFFCE93D8);
    const surfaceColor = Color(0xFF1A0A12);
    const backgroundDark = Color(0xFF120008);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Activos Colaboradores',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: primaryPink,
          onPrimary: Colors.white,
          primaryContainer: deepRose,
          onPrimaryContainer: softPurple,
          secondary: accentPurple,
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFF4A0E5C),
          onSecondaryContainer: softPurple,
          surface: surfaceColor,
          onSurface: Color(0xFFF3E5F5),
          surfaceContainerHighest: Color(0xFF2A1020),
          outline: Color(0xFF6D3B5A),
          error: Color(0xFFCF6679),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: deepRose,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          surfaceTintColor: Colors.transparent,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: backgroundDark,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryPink,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0x888B1A4A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: softPurple),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A1020),
          labelStyle: const TextStyle(color: softPurple),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIconColor: softPurple,
          suffixIconColor: softPurple,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6D3B5A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6D3B5A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryPink, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCF6679)),
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF2A1020),
          elevation: 4,
          shadowColor: const Color(0x558B1A4A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF3D1A2E), width: 0.5),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: softPurple,
          textColor: Color(0xFFF3E5F5),
          selectedColor: primaryPink,
          selectedTileColor: Color(0xFF3D1A2E),
        ),
        iconTheme: const IconThemeData(color: softPurple),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF3D1A2E),
          thickness: 0.5,
        ),
        scaffoldBackgroundColor: backgroundDark,
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          displayMedium:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          headlineMedium:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3),
          titleMedium: TextStyle(color: Color(0xFFF3E5F5), letterSpacing: 0.2),
          bodyLarge: TextStyle(color: Color(0xFFF3E5F5)),
          bodyMedium: TextStyle(color: Color(0xFFD4A8C0)),
          labelLarge: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5),
        ),
      ),
      home: const LoguinScreen(),
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        ColaboradoresScreen.routeName: (context) => const ColaboradoresScreen(),
        ActivosScreen.routeName: (context) => const ActivosScreen(),
        AsignacionesScreen.routeName: (context) => const AsignacionesScreen(),
        ProveedoresScreen.routeName: (context) => const ProveedoresScreen(),
        DepartamentosScreen.routeName: (context) => const DepartamentosScreen(),
        PartidasScreen.routeName: (context) => const PartidasScreen(),
      },
    );
  }
}
