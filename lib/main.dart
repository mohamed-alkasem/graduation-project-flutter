// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/ogrenci/ogrenci_login.dart';
import 'screens/auth/ogrenci/ogrenci_register.dart';
import 'screens/auth/sirket/sirket_login.dart';
import 'screens/auth/sirket/sirket_register.dart';
import 'screens/ogrenci/ogrenci_dashboard.dart';
import 'screens/sirket/sirket_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yetenek Keşif Platformu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2C3E50),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C3E50),
          elevation: 0,
        ),
      ),
      // خليت بس routes واحذفت home
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/ogrenci/login': (context) => const OgrenciLogin(),
        '/ogrenci/register': (context) => const OgrenciRegister(),
        '/ogrenci/dashboard': (context) => const OgrenciDashboard(email: ''),
        '/sirket/login': (context) => const SirketLogin(),
        '/sirket/register': (context) => const SirketRegister(),
        '/sirket/dashboard': (context) => const SirketDashboard(email: ''),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          return MaterialPageRoute(
            builder: (context) => const OgrenciLogin(),
          );
        }
        return null;
      },
    );
  }
}