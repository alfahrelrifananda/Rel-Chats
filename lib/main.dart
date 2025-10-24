import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = prefs.getBool('isDarkMode') ?? false);
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = !_isDarkMode);
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        const fallbackSeed = Color(0xFF6366F1);

        final lightScheme =
            lightDynamic ??
            ColorScheme.fromSeed(
              seedColor: fallbackSeed,
              brightness: Brightness.light,
            );

        final darkScheme =
            darkDynamic ??
            ColorScheme.fromSeed(
              seedColor: fallbackSeed,
              brightness: Brightness.dark,
            );

        ThemeData buildTheme(ColorScheme scheme) => ThemeData(
          fontFamily: 'Poppins',
          colorScheme: scheme,
          useMaterial3: true,
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
            ),
            displayMedium: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            headlineLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
            titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            ),
          ),
        );

        return MaterialApp(
          title: 'Rel Chats',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(lightScheme),
          darkTheme: buildTheme(darkScheme),
          themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: WelcomePage(
            isDarkMode: _isDarkMode,
            onThemeToggle: _toggleTheme,
          ),
        );
      },
    );
  }
}
