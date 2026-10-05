import 'package:app_filmes/view/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AppFilmes());
}

class AppFilmes extends StatelessWidget {
  const AppFilmes({super.key});

  @override
  Widget build(BuildContext context) {
    const corPrimaria = Color(0xFFE50914); // vermelho Netflix
    const corFundo = Color(0xFF141414);
    const corSuperficie = Color(0xFF181818);

    return MaterialApp(
      title: 'Meus Filmes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: corFundo,
        colorScheme: const ColorScheme.dark(
          primary: corPrimaria,
          onPrimary: Colors.white,
          surface: corSuperficie,
          error: Color(0xFFB3251F),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: corFundo,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: corPrimaria,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: corSuperficie,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFF2B2B2B)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: corPrimaria,
          foregroundColor: Colors.white,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF2B2B2B),
          selectedColor: corPrimaria,
          labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
          side: BorderSide.none,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
