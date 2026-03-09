import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:propertyrent/data/datasource/auth_api.dart';
import 'package:propertyrent/data/models/auth_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _tokenKey = 'auth_token';

/// Auth via PRS backend only (no Firebase). JWT stored in SharedPreferences.
/// Google Sign-In used only to get id_token, sent to backend; user is stored in DB.
class AuthRepository {
  AuthRepository({
    SharedPreferences? prefs,
    GoogleSignIn? googleSignIn,
  })  : _prefs = prefs,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final SharedPreferences? _prefs;
  final GoogleSignIn _googleSignIn;
  final _authStateController = StreamController<AuthUser?>.broadcast();

  static Future<SharedPreferences> _getPrefs(SharedPreferences? p) async {
    return p ?? await SharedPreferences.getInstance();
  }

  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  Future<String?> _getToken() async {
    final prefs = await _getPrefs(_prefs);
    return prefs.getString(_tokenKey);
  }

  Future<void> _setToken(String? token) async {
    final prefs = await _getPrefs(_prefs);
    if (token == null) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  /// Call on app start to restore auth state from stored token.
  Future<void> restoreAuthState() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      _authStateController.add(null);
      return;
    }
    final profile = await AuthApi.getProfile(token);
    if (profile != null) {
      _authStateController.add(profile.toAuthUser());
    } else {
      await _setToken(null);
      _authStateController.add(null);
    }
  }

  Future<AuthUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final result = await AuthApi.login(email, password);
    if (!result.success || result.token == null) {
      throw Exception(result.message ?? 'Login failed');
    }
    await _setToken(result.token);
    final profile = await AuthApi.getProfile(result.token!);
    final user = profile?.toAuthUser();
    if (user != null) _authStateController.add(user);
    return user;
  }

  /// Phone auth was removed. Kept as stub so existing callers compile.
  Future<AuthUser?> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    throw UnimplementedError(
      'Phone auth is not supported. Use email signup or Google login.',
    );
  }

  /// Google: get id_token from Google, send to backend; backend creates/updates user in DB and returns JWT.
  Future<AuthUser?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final auth = await googleUser.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) return null;
    final result = await AuthApi.googleLogin(idToken);
    if (!result.success || result.token == null) {
      throw Exception(result.message ?? 'Google login failed');
    }
    await _setToken(result.token);
    final profile = await AuthApi.getProfile(result.token!);
    final user = profile?.toAuthUser();
    if (user != null) _authStateController.add(user);
    return user;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _setToken(null);
    _authStateController.add(null);
  }

  Future<AuthUser?> getCurrentUser() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return null;
    final profile = await AuthApi.getProfile(token);
    return profile?.toAuthUser();
  }

  /// After signup OTP verification, set token and emit user so UI updates.
  Future<void> setTokenAndEmitUser(String token) async {
    await _setToken(token);
    final profile = await AuthApi.getProfile(token);
    if (profile != null) _authStateController.add(profile.toAuthUser());
  }

  /// Re-fetch profile and emit updated user so whole app (drawer, profile page) shows new name/photo.
  Future<void> refreshUser() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;
    final profile = await AuthApi.getProfile(token);
    if (profile != null) _authStateController.add(profile.toAuthUser());
  }

  /// Expose token for other API calls (e.g. listings).
  Future<String?> getAuthToken() => _getToken();
}
