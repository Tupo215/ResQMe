import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─── Base URL ─────────────────────────────────────────────────────────────────
const String _baseUrl = 'https://resq-app-741m.onrender.com';

// ─── API Response wrapper ─────────────────────────────────────────────────────
class ApiResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const ApiResult({
    required this.success,
    required this.message,
    this.data,
  });
}

// ─── Token Storage Keys ───────────────────────────────────────────────────────
const _kAccessToken  = 'access_token';
const _kRefreshToken = 'refresh_token';
const _kUserId       = 'user_id';

// ─── ResQ API Service ─────────────────────────────────────────────────────────
class ResQApiService {

  // ── 1. SIGN UP ──────────────────────────────────────────────────────────────
  // POST /auth/sign-up
  static Future<ApiResult> signUp({
    required String email,
    required String password,
    required String fullname,
    required String birthDate,       // YYYY-MM-DD
    required String deviceIdentifier, // UUID v4
    String role = 'user',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/sign-up'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email':            email,
          'password':         password,
          'fullname':         fullname,
          'birthDate':        birthDate,
          'deviceIdentifier': deviceIdentifier,
          'role':             role,
        }),
      ).timeout(const Duration(seconds: 30));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        // Save userId so the verify-email screen can use it
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kUserId, body['userId'] ?? '');

        return ApiResult(
          success: true,
          message: body['message'] ??
              'Registered successfully. Please verify your email.',
          data: body,
        );
      }

      // Error body may use 'message' or 'reason'
      final errorMsg = body['message'] ?? body['reason'] ?? 'Sign up failed';
      return ApiResult(success: false, message: errorMsg);

    } catch (e) {
      return ApiResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ── 2. RESEND EMAIL VERIFICATION LINK ───────────────────────────────────────
  // POST /auth/resend-email-verification-link
  static Future<ApiResult> resendVerificationLink({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/resend-email-verification-link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 30));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        return ApiResult(
          success: true,
          message: body['message'] ?? 'Verification link sent successfully.',
        );
      }

      final errorMsg = body['message'] ?? body['reason'] ?? 'Failed to resend link';
      return ApiResult(success: false, message: errorMsg);

    } catch (e) {
      return ApiResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ── 3. LOG IN ────────────────────────────────────────────────────────────────
  // POST /auth/log-in
  static Future<ApiResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/log-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'logInVia': 'email',
          'email':    email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['accessToken'] != null) {
        // Persist both tokens securely
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kAccessToken,  body['accessToken']);
        await prefs.setString(_kRefreshToken, body['refreshToken']);

        return ApiResult(
          success: true,
          message: 'Login successful.',
          data: body,
        );
      }

      // Map known backend error reasons to user-friendly messages
      final reason = body['reason'] ?? body['message'] ?? 'Login failed';
      String userMsg;
      switch (reason) {
        case "User doesn't exist":
          userMsg = 'No account found with this email.';
          break;
        case 'Invalid credentials':
          userMsg = 'Incorrect password. Please try again.';
          break;
        case 'Email not verified':
          userMsg = 'Please verify your email before logging in.';
          break;
        default:
          userMsg = reason;
      }

      return ApiResult(success: false, message: userMsg, data: {'reason': reason});

    } catch (e) {
      return ApiResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ── Token helpers ────────────────────────────────────────────────────────────

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccessToken);
  }

  static Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserId);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessToken);
    await prefs.remove(_kRefreshToken);
    await prefs.remove(_kUserId);
  }
}
