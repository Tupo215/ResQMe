import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Check if user is already logged in
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  final isLoggedIn = token != null && token.isNotEmpty;

  runApp(ResQMissionApp(startLoggedIn: isLoggedIn));
}

class ResQMissionApp extends StatelessWidget {
  final bool startLoggedIn;
  const ResQMissionApp({super.key, required this.startLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQMission',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEFEFF1),
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF000080),
          secondary: Color(0xFF9999CC),
        ),
      ),
      home: startLoggedIn ? const DashboardScreen() : const OnboardingScreen(),
    );
  }
}
