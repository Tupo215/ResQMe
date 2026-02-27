import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Deep link scheme:  resqme://verification-success?accessToken=...&refreshToken=...
// The backend sends this after the user clicks their verification email.
// We intercept it here, save the tokens, then push the user to Dashboard.
// ─────────────────────────────────────────────────────────────────────────────

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

class ResQMissionApp extends StatefulWidget {
  final bool startLoggedIn;
  const ResQMissionApp({super.key, required this.startLoggedIn});

  @override
  State<ResQMissionApp> createState() => _ResQMissionAppState();
}

class _ResQMissionAppState extends State<ResQMissionApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle cold-start deep link (app was closed when link was tapped)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (_) {}

    // Handle warm/hot deep links (app already open or in background)
    _appLinks.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (_) {},
    );
  }

  /// Parses resqme://verification-success?accessToken=X&refreshToken=Y
  /// Saves tokens and navigates the user to Dashboard.
  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.scheme == 'resqme' && uri.host == 'verification-success') {
      final accessToken  = uri.queryParameters['accessToken'];
      final refreshToken = uri.queryParameters['refreshToken'];

      if (accessToken != null && accessToken.isNotEmpty &&
          refreshToken != null && refreshToken.isNotEmpty) {
        // Save tokens using the same keys used throughout the app
        await ResQApiService.saveTokensFromDeepLink(accessToken, refreshToken);

        // Navigate to Dashboard, clearing the entire back stack
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQMission',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEFEFF1),
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF000080),
          secondary: Color(0xFF9999CC),
        ),
      ),
      home: widget.startLoggedIn
          ? const DashboardScreen()
          : const OnboardingScreen(),
    );
  }
}
