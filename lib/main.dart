// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Theme
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';

// Auth
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/ogrenci/ogrenci_login.dart';
import 'screens/auth/ogrenci/ogrenci_register.dart';
import 'screens/auth/sirket/sirket_login.dart';
import 'screens/auth/sirket/sirket_register.dart';

// Dashboards
import 'screens/ogrenci/ogrenci_dashboard.dart';
import 'screens/sirket/sirket_dashboard.dart';

// Profiles
import 'screens/ogrenci/ogrenci_profile_screen.dart';
import 'screens/sirket/sirket_profile.dart';

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
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Yetenek Keşif Platformu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            initialRoute: '/',
            routes: {
              '/': (context) => const WelcomeScreen(),

              // Öğrenci
              '/ogrenci/login': (context) => const OgrenciLogin(),
              '/ogrenci/register': (context) => const OgrenciRegister(),

              // ✅ بدون email
              '/ogrenci/dashboard': (context) => const OgrenciDashboard(),

              // ✅ بروفايل الطالب الصحيح
              '/ogrenci/profile': (context) => const OgrenciProfileScreen(),

              // Şirket
              '/sirket/login': (context) => const SirketLogin(),
              '/sirket/register': (context) => const SirketRegister(),

              // ✅ بدون email
              '/sirket/dashboard': (context) => const SirketDashboard(),
            },

            onGenerateRoute: (settings) {
              if (settings.name == '/login') {
                return MaterialPageRoute(builder: (context) => const OgrenciLogin());
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
