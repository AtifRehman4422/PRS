import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:propertyrent/core/constants/api_config.dart';
import 'package:propertyrent/data/models/auth_user_model.dart';

const Duration _kRequestTimeout = Duration(seconds: 25);

class AuthApi {
  static Future<Map<String, String>> _headers({String? token}) async {
    final m = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) m['Authorization'] = 'Bearer $token';
    return m;
  }

  static Future<AuthProfile?> getProfile(String token) async {
    final uri = Uri.parse(authUrl('/profile'));
    final r = await http.get(uri, headers: await _headers(token: token));
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body) as Map<String, dynamic>?;
    if (j == null) return null;
    return AuthProfile(
      id: (j['id'] as num?)?.toInt(),
      username: j['username'] as String?,
      email: j['email'] as String?,
      contact: j['contact'] as String?,
      profileImage: j['profile_image'] as String?,
      isVerified: j['is_verified'] == true,
    );
  }

  static Future<AuthApiResult> login(String email, String password) async {
    final uri = Uri.parse(authUrl('/login'));
    final r = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );
    final j = r.statusCode == 200 ? jsonDecode(r.body) as Map<String, dynamic>? : null;
    final token = j?['token'] as String?;
    if (token != null && token.isNotEmpty) {
      return AuthApiResult(success: true, token: token, message: j?['message'] as String?);
    }
    final err = j != null ? (j['message'] as String?) : _errorBody(r.body);
    return AuthApiResult(success: false, message: err ?? 'Login failed');
  }

  static Future<AuthApiResult> googleLogin(String idToken) async {
    final uri = Uri.parse(authUrl('/google'));
    final r = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({'id_token': idToken}),
    );
    final j = r.statusCode == 200 ? jsonDecode(r.body) as Map<String, dynamic>? : null;
    final token = j?['token'] as String?;
    if (token != null && token.isNotEmpty) {
      return AuthApiResult(success: true, token: token, message: j?['message'] as String?);
    }
    final err = j != null ? (j['message'] as String?) : _errorBody(r.body);
    return AuthApiResult(success: false, message: err ?? 'Google login failed');
  }

  static Future<AuthApiResult> signup({
    required String username,
    required String email,
    required String contact,
    required String password,
    required String confirmPassword,
    required String profileImagePath,
  }) async {
    final uri = Uri.parse(authUrl('/signup'));
    final request = http.MultipartRequest('POST', uri);
    request.fields['username'] = username.trim();
    request.fields['email'] = email.trim().toLowerCase();
    request.fields['contact'] = contact.trim();
    request.fields['password'] = password;
    request.fields['confirm_password'] = confirmPassword;
    try {
      request.files.add(await http.MultipartFile.fromPath('profile_image', profileImagePath));
    } catch (e) {
      return AuthApiResult(success: false, message: 'Invalid profile image: $e');
    }
    try {
      final streamed = await request.send().timeout(
        _kRequestTimeout,
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );
      final response = await http.Response.fromStream(streamed).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Response timeout'),
      );
      if (response.statusCode == 200) {
        final j = _tryJson(response.body);
        return AuthApiResult(success: true, message: j?['message'] as String? ?? 'OTP sent');
      }
      final j = _tryJson(response.body);
      return AuthApiResult(
        success: false,
        message: j?['message'] as String? ?? _errorBody(response.body) ?? 'Signup failed (${response.statusCode})',
      );
    } on SocketException catch (_) {
      return AuthApiResult(
        success: false,
        message: 'Server unreachable. Start backend (npm start in pr-backend) and check API URL in api_config.dart.',
      );
    } on TimeoutException catch (_) {
      return AuthApiResult(success: false, message: 'Request timed out. Check internet and backend.');
    } on Exception catch (e) {
      return AuthApiResult(success: false, message: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Map<String, dynamic>? _tryJson(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  static Future<AuthApiResult> verifyOtp(String email, String otp) async {
    final uri = Uri.parse(authUrl('/verify-otp'));
    final r = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({'email': email.trim().toLowerCase(), 'otp': otp.trim()}),
    );
    final j = r.statusCode == 200 ? jsonDecode(r.body) as Map<String, dynamic>? : null;
    final token = j?['token'] as String?;
    if (token != null && token.isNotEmpty) {
      return AuthApiResult(success: true, token: token, message: j?['message'] as String?);
    }
    final err = j != null ? (j['message'] as String?) : _errorBody(r.body);
    return AuthApiResult(success: false, message: err ?? 'Verification failed');
  }

  static Future<AuthApiResult> forgotPassword(String email) async {
    final uri = Uri.parse(authUrl('/forgot-password'));
    final r = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({'email': email.trim().toLowerCase()}),
    );
    final j = r.statusCode == 200 ? jsonDecode(r.body) as Map<String, dynamic>? : null;
    if (r.statusCode == 200) {
      return AuthApiResult(success: true, message: j?['message'] as String? ?? 'Reset code sent');
    }
    return AuthApiResult(success: false, message: j?['message'] as String? ?? _errorBody(r.body));
  }

  static Future<AuthApiResult> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse(authUrl('/reset-password'));
    final r = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      }),
    );
    final j = r.statusCode == 200 ? jsonDecode(r.body) as Map<String, dynamic>? : null;
    if (r.statusCode == 200) {
      return AuthApiResult(success: true, message: j?['message'] as String?);
    }
    return AuthApiResult(success: false, message: j?['message'] as String? ?? _errorBody(r.body));
  }

  static String? _errorBody(String body) {
    try {
      final j = jsonDecode(body) as Map<String, dynamic>?;
      return j?['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}

class AuthApiResult {
  final bool success;
  final String? token;
  final String? message;
  AuthApiResult({required this.success, this.token, this.message});
}

class AuthProfile {
  final int? id;
  final String? username;
  final String? email;
  final String? contact;
  final String? profileImage;
  final bool isVerified;
  AuthProfile({
    this.id,
    this.username,
    this.email,
    this.contact,
    this.profileImage,
    this.isVerified = false,
  });
  AuthUser toAuthUser() => AuthUser(
        uid: id?.toString() ?? email ?? '',
        displayName: username,
        email: email,
        photoURL: profileImage,
        phoneNumber: contact,
      );
}
