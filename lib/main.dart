import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'common.dart';
import 'services/auth_service.dart';
import 'screens/login_page.dart';
import 'screens/menu_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusCart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: oceanBlue,
          primary: oceanBlue,
          secondary: apricot,
          tertiary: persimmon,
          error: persimmon,
          surface: warmWhite,
        ),
        scaffoldBackgroundColor: warmWhite,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: textColor,
          displayColor: textColor,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

/// Decides which screen to show based on the Firebase login state.
/// Logged in  -> MenuPage (stays logged in after the app is restarted)
/// Logged out -> LoginPage
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: blue)),
          );
        }
        if (snapshot.hasData) return const MenuPage();
        return const LoginPage();
      },
    );
  }
}
