import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DEPENDENCIES NEEDED IN pubspec.yaml:
//   http: ^1.2.0
//   image_picker: ^1.0.7
//   shared_preferences: ^2.0.0
// ─────────────────────────────────────────────────────────────────────────────

const String _baseUrl    = 'https://resq-app-741m.onrender.com';
const _kAccessToken      = 'access_token';
const _kRefreshToken     = 'refresh_token';
const _kUserId           = 'user_id';
const _kUserName         = 'user_name';
const _kUserProfile      = 'user_profile';

// ─── API Response wrapper ─────────────────────────────────────────────────────
class ApiResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final List<dynamic>? list;
  const ApiResult({required this.success, required this.message,
      this.data, this.list});
}

// =============================================================================
// ResQ API Service
// =============================================================================
class ResQApiService {

  // ── Token storage helpers ─────────────────────────────────────────────────

  static Future<String?> getAccessToken() async =>
      (await SharedPreferences.getInstance()).getString(_kAccessToken);

  static Future<String?> _getRefreshToken() async =>
      (await SharedPreferences.getInstance()).getString(_kRefreshToken);

  static Future<void> _saveTokens(String access, String refresh) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAccessToken, access);
    await p.setString(_kRefreshToken, refresh);
  }

  static Future<String?> getUserName() async =>
      (await SharedPreferences.getInstance()).getString(_kUserName);

  static Future<String?> getSavedUserId() async =>
      (await SharedPreferences.getInstance()).getString(_kUserId);

  static Future<Map<String, dynamic>?> getCachedProfile() async {
    final s = (await SharedPreferences.getInstance()).getString(_kUserProfile);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  // ── Auth headers ──────────────────────────────────────────────────────────

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      'authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> _authHeadersRaw() async {
    final token = await getAccessToken();
    return {'authorization': 'Bearer $token'};
  }

  // ── Token Refresh ──────────────────────────────────────────────────────────
  // POST /token/generate-access-token
  // Automatically called when server returns 403

  static Future<bool> _refreshTokens() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;
      final response = await http.post(
        Uri.parse('$_baseUrl/token/generate-access-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final a = body['accessToken']  as String?;
        final r = body['refreshToken'] as String?;
        if (a != null && r != null) { await _saveTokens(a, r); return true; }
      }
      return false;
    } catch (_) { return false; }
  }

  // ── Authenticated request helpers ─────────────────────────────────────────

  static Future<http.Response> _authGet(String path) async {
    var res = await http.get(Uri.parse('$_baseUrl$path'),
        headers: await _authHeaders()).timeout(const Duration(seconds: 30));
    if (res.statusCode == 403 && await _refreshTokens()) {
      res = await http.get(Uri.parse('$_baseUrl$path'),
          headers: await _authHeaders()).timeout(const Duration(seconds: 30));
    }
    return res;
  }

  static Future<http.Response> _authPost(
      String path, Map<String, dynamic> body) async {
    var res = await http.post(Uri.parse('$_baseUrl$path'),
        headers: await _authHeaders(),
        body: jsonEncode(body)).timeout(const Duration(seconds: 30));
    if (res.statusCode == 403 && await _refreshTokens()) {
      res = await http.post(Uri.parse('$_baseUrl$path'),
          headers: await _authHeaders(),
          body: jsonEncode(body)).timeout(const Duration(seconds: 30));
    }
    return res;
  }

  static Future<http.StreamedResponse> _authMultipart(
      String path,
      http.MultipartRequest Function() build) async {
    http.MultipartRequest req = build();
    req.headers.addAll(await _authHeadersRaw());
    var res = await req.send().timeout(const Duration(seconds: 60));
    if (res.statusCode == 403 && await _refreshTokens()) {
      req = build();
      req.headers.addAll(await _authHeadersRaw());
      res = await req.send().timeout(const Duration(seconds: 60));
    }
    return res;
  }

  // =============================================================================
  // 1. SIGN UP   POST /auth/sign-up
  // =============================================================================
  static Future<ApiResult> signUp({
    required String email,
    required String password,
    required String fullname,
    required String birthDate,
    required String deviceIdentifier,
    String role = 'user',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/sign-up'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password,
          'fullname': fullname, 'birthDate': birthDate,
          'deviceIdentifier': deviceIdentifier, 'role': role}),
      ).timeout(const Duration(seconds: 30));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['success'] == true) {
        final p = await SharedPreferences.getInstance();
        await p.setString(_kUserId, body['userId'] ?? '');
        await p.setString(_kUserName, fullname);
        return ApiResult(success: true,
            message: body['message'] ?? 'Registered. Please verify your email.',
            data: body);
      }
      return ApiResult(success: false,
          message: body['message'] ?? body['reason'] ?? 'Sign up failed');
    } catch (e) {
      return ApiResult(success: false,
          message: 'Network error. Please check your connection.');
    }
  }

  // =============================================================================
  // 2. RESEND VERIFICATION   POST /auth/resend-email-verification-link
  // =============================================================================
  static Future<ApiResult> resendVerificationLink({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/resend-email-verification-link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 30));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['success'] == true) {
        return ApiResult(success: true,
            message: body['message'] ?? 'Verification link sent.');
      }
      return ApiResult(success: false,
          message: body['message'] ?? body['reason'] ?? 'Failed to resend');
    } catch (e) {
      return ApiResult(success: false,
          message: 'Network error. Please check your connection.');
    }
  }

  // =============================================================================
  // 3. LOG IN   POST /auth/log-in
  // Response: { accessToken, refreshToken,
  //             profile: { gender, allergies, health_state, fullname } }
  // =============================================================================
  static Future<ApiResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/log-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'logInVia': 'email', 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['accessToken'] != null) {
        final p = await SharedPreferences.getInstance();
        await p.setString(_kAccessToken,  body['accessToken']);
        await p.setString(_kRefreshToken, body['refreshToken'] ?? '');

        // Cache profile from login response
        final profile = body['profile'] as Map<String, dynamic>?;
        if (profile != null) {
          await p.setString(_kUserName, profile['fullname'] ?? '');
          await p.setString(_kUserProfile, jsonEncode(profile));
        }

        return ApiResult(success: true, message: 'Login successful.', data: body);
      }

      final reason = body['reason'] ?? body['message'] ?? 'Login failed';
      final userMsg = {
        "User doesn't exist": 'No account found with this email.',
        'Invalid credentials':  'Incorrect password. Please try again.',
        'Email not verified':   'Please verify your email before logging in.',
      }[reason] ?? reason;

      return ApiResult(success: false, message: userMsg,
          data: {'reason': reason});
    } catch (e) {
      return ApiResult(success: false,
          message: 'Network error. Please check your connection.');
    }
  }

  // =============================================================================
  // 4. CREATE / UPDATE PROFILE
  // POST /profile/create-my-profile   multipart/form-data
  //
  // Fields: fullname, gender, age, phone, country, city, address,
  //         emergencyKeyPhrase, bloodType, allergies, medications,
  //         chronicConditions, profilePicture (file)
  // =============================================================================
  static Future<ApiResult> createProfile({
    required String gender,
    // allergies as JSON string e.g. '{ "cake" : "severe" }'
    String? allergies,
    // healthState as JSON string e.g. '{"hypertension" : "30" }'
    String? healthState,
    File?   profilePic,
  }) async {
    try {
      final streamed = await _authMultipart('/profile/create-my-profile', () {
        final req = http.MultipartRequest(
            'POST', Uri.parse('$_baseUrl/profile/create-my-profile'));

        // Exact field names from backend (image 3)
        req.fields['gender'] = gender;
        if (allergies?.isNotEmpty == true)
          req.fields['allergies'] = allergies!;
        if (healthState?.isNotEmpty == true)
          req.fields['healthState'] = healthState!;

        // Profile picture — key is "profilePic" (image 3)
        if (profilePic != null) {
          req.files.add(http.MultipartFile.fromBytes(
            'profilePic',
            profilePic.readAsBytesSync(),
            filename: profilePic.path.split(Platform.pathSeparator).last,
          ));
        }
        return req;
      });

      if (streamed.statusCode == 200) {
        return ApiResult(success: true, message: 'Profile saved successfully.');
      }
      final rb     = await streamed.stream.bytesToString();
      final parsed = _tryDecode(rb);
      return ApiResult(success: false,
          message: parsed?['message'] ?? 'Failed to save profile');
    } catch (e) {
      return ApiResult(success: false,
          message: 'Network error. Please check your connection.');
    }
  }

  // =============================================================================
  // 5. CREATE EMERGENCY CONTACTS
  // POST /profile/create-emergency-contacts   multipart/form-data
  //
  // Up to 5 contacts using prefixed keys:
  //   {prefix}EmergName, {prefix}EmergEmail, {prefix}EmergRelation,
  //   {prefix}-emergency (file)
  // prefixes: first, second, third, fourth, fifth
  // =============================================================================
  static const _emergPrefixes = ['first', 'second', 'third', 'fourth', 'fifth'];

  static Future<ApiResult> createEmergencyContacts(
      List<EmergencyContactInput> contacts) async {
    if (contacts.isEmpty)
      return ApiResult(success: false, message: 'At least one contact required');
    if (contacts.length > 5)
      return ApiResult(success: false,
          message: 'Maximum 5 emergency contacts allowed');

    try {
      final streamed = await _authMultipart(
          '/profile/create-emergency-contacts', () {
        final req = http.MultipartRequest(
            'POST',
            Uri.parse('$_baseUrl/profile/create-emergency-contacts'));
        for (int i = 0; i < contacts.length; i++) {
          final pfx = _emergPrefixes[i];
          final c   = contacts[i];
          req.fields['${pfx}EmergName']  = c.name;
          req.fields['${pfx}EmergEmail'] = c.email;
          // Backend expects relation as JSON array string: ["sister"]  (image 1)
          req.fields['${pfx}EmergRelation'] =
              '["${c.relationship.toLowerCase()}"]';
          if (c.photo != null) {
            req.files.add(http.MultipartFile.fromBytes(
              '$pfx-emergency',
              c.photo!.readAsBytesSync(),
              filename: c.photo!.path.split(Platform.pathSeparator).last,
            ));
          }
        }
        return req;
      });

      if (streamed.statusCode == 200) {
        return ApiResult(
            success: true, message: 'Emergency contacts saved successfully.');
      }
      final rb     = await streamed.stream.bytesToString();
      final parsed = _tryDecode(rb);
      return ApiResult(success: false,
          message: parsed?['message'] ?? 'Failed to save emergency contacts');
    } catch (e) {
      return ApiResult(success: false,
          message: 'Network error. Please check your connection.');
    }
  }

  // =============================================================================
  // 6. GET EMERGENCY CONTACTS
  // GET /profile/emergency-contacts-profile
  // Response: [ { id, name, email, relationship, imageurl } ]
  // =============================================================================
  static Future<ApiResult> getEmergencyContacts() async {
    try {
      final response = await _authGet('/profile/emergency-contacts-profile');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final list = body is List
            ? body
            : (body is Map && body['contacts'] is List
                ? body['contacts'] as List
                : []);
        return ApiResult(success: true, message: 'Contacts loaded.', list: list);
      }
      final parsed = _tryDecode(response.body);
      return ApiResult(success: false,
          message: parsed?['message'] ?? 'Failed to load contacts');
    } catch (e) {
      return ApiResult(success: false,
          message: 'Network error. Please check your connection.');
    }
  }

  // =============================================================================
  // 7. REPORT EMERGENCY
  // POST /reports/emergency   multipart/form-data
  //
  // Fields: emergencyType, reportingFor, latitude, longitude,
  //         address, description, victimsCount, victimCondition,
  //         voiceNote (file), photo (file)
  // Response: { "message": "Successful request" }
  // =============================================================================
  static Future<ApiResult> reportEmergency({
    // Confirmed fields from backend (image 2):
    required double latitude,    // e.g. 9.0405080
    required double longitude,   // e.g. 38.7627340
    File? voiceNote,              // key: "voiceNote", file e.g. ResQ.m4a
    // Additional fields — send if available
    String? emergencyType,
    String? reportingFor,
    String? description,
    File?   photo,
  }) async {
    try {
      final streamed = await _authMultipart('/reports/emergency', () {
        final req = http.MultipartRequest(
            'POST', Uri.parse('$_baseUrl/reports/emergency'));

        // Confirmed required fields (image 2)
        req.fields['latitude']  = latitude.toString();
        req.fields['longitude'] = longitude.toString();

        // Optional extra context
        if (emergencyType?.isNotEmpty == true)
          req.fields['emergencyType'] = emergencyType!;
        if (reportingFor?.isNotEmpty == true)
          req.fields['reportingFor'] = reportingFor!;
        if (description?.isNotEmpty == true)
          req.fields['description'] = description!;

        // Voice note file — key is "voiceNote" (image 2)
        if (voiceNote != null) {
          req.files.add(http.MultipartFile.fromBytes(
            'voiceNote',
            voiceNote.readAsBytesSync(),
            filename: voiceNote.path.split(Platform.pathSeparator).last,
          ));
        }
        if (photo != null) {
          req.files.add(http.MultipartFile.fromBytes(
            'photo',
            photo.readAsBytesSync(),
            filename: photo.path.split(Platform.pathSeparator).last,
          ));
        }
        return req;
      });

      if (streamed.statusCode == 200) {
        return ApiResult(
            success: true, message: 'Emergency reported successfully.');
      }
      final rb     = await streamed.stream.bytesToString();
      final parsed = _tryDecode(rb);
      return ApiResult(success: false,
          message: parsed?['message'] ?? 'Failed to report emergency');
    } catch (e) {
      return ApiResult(success: false,
          message: 'Network error. Please check your connection.');
    }
  }

  // =============================================================================
  // 8. LOGOUT — clears all local tokens
  // =============================================================================
  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kAccessToken);
    await p.remove(_kRefreshToken);
    await p.remove(_kUserId);
    await p.remove(_kUserName);
    await p.remove(_kUserProfile);
  }

  // ── Utility ───────────────────────────────────────────────────────────────
  static Map<String, dynamic>? _tryDecode(String body) {
    try { return jsonDecode(body) as Map<String, dynamic>?; }
    catch (_) { return null; }
  }
}

// =============================================================================
// Models
// =============================================================================

/// Input model for creating an emergency contact
class EmergencyContactInput {
  final String name;
  final String email;
  final String relationship;
  final File?  photo;
  const EmergencyContactInput({
    required this.name,
    required this.email,
    required this.relationship,
    this.photo,
  });
}

/// Response model from GET /profile/emergency-contacts-profile
class EmergencyContactProfile {
  final String        id;
  final String        name;
  final String        email;
  final List<String>  relationship;
  final String?       imageUrl;

  const EmergencyContactProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.relationship,
    this.imageUrl,
  });

  // name/email come back with extra quotes e.g. '"John"' — strip them
  static String _clean(String? s) =>
      (s ?? '').replaceAll('"', '').trim();

  factory EmergencyContactProfile.fromJson(Map<String, dynamic> json) {
    final rel = json['relationship'];
    final relList = rel is List
        ? rel.map((e) => e.toString()).toList()
        : [rel?.toString() ?? ''];
    return EmergencyContactProfile(
      id:           json['id'] ?? '',
      name:         _clean(json['name']),
      email:        _clean(json['email']),
      relationship: relList,
      imageUrl:     _clean(json['imageurl']),
    );
  }

  static List<EmergencyContactProfile> fromJsonList(List<dynamic> list) =>
      list.map((e) =>
          EmergencyContactProfile.fromJson(e as Map<String, dynamic>)).toList();
}
