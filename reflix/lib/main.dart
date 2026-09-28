import 'package:flutter/material.dart';
import 'package:reflix/view/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //cores principais do app
    const corPrimaria = Color(0xFFE50914); 
    const corFundo = Color(0xFF141414);

    return MaterialApp(
      title: 'Meus Filmes',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
        colorScheme: const ColorScheme.dark(
          primary: Color.fromARGB(218, 247, 3, 11),  //cor icones
          error: Color(0xFFB3251F),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
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
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color.fromARGB(255, 145, 13, 13)),
          ),
        ),
        //+
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 229, 9, 9),
          foregroundColor: Color.fromARGB(255, 5, 3, 3),
        ),
        // tipos
        chipTheme: ChipThemeData(
          backgroundColor: const Color.fromARGB(255, 43, 43, 43),
          selectedColor: corPrimaria,
          labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
          side: BorderSide.none,
        ),
      ),
      home: const HomeScreen(),
    );
    
  }
}
