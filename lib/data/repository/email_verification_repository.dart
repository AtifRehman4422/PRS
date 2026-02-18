import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Sends verification code to email (via Cloud Function) and verifies code.
/// Falls back to in-memory mock if Cloud Functions are not deployed.
class EmailVerificationRepository {
  EmailVerificationRepository({
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  static const String _codesCollection = 'email_verification_codes';
  /// Collection used by Firebase "Trigger Email" extension to send code to user's email.
  static const String _mailCollection = 'mail';
  static const int _codeExpiryMinutes = 10;
  static const int _codeLength = 6;

  /// Request a 6-digit verification code. Code is sent to the [email] the user entered.
  /// If Cloud Function is deployed, code is sent to that email and returns null.
  /// If fallback (Firestore) is used, returns the code so UI can show it for testing.
  Future<String?> requestVerificationCode(String email) async {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty) throw ArgumentError('Email required');

    try {
      final callable = _functions.httpsCallable('requestEmailVerificationCode');
      await callable.call({'email': trimmed});
      return null;
    } catch (_) {
      return _requestVerificationCodeFallback(trimmed);
    }
  }

  /// Fallback: generate code, store in Firestore, send code to user's email (Trigger Email),
  /// then return code for dev popup if needed.
  Future<String> _requestVerificationCodeFallback(String email) async {
    final code = _generateCode();
    final expiry = DateTime.now().add(Duration(minutes: _codeExpiryMinutes));
    await _firestore.collection(_codesCollection).doc(_sanitizeDocId(email)).set({
      'email': email,
      'code': code,
      'expiry': Timestamp.fromDate(expiry),
    });
    // Send code to the email user entered on signup (Trigger Email extension).
    // FROM = propertyrent48@gmail.com (set in extension). TO = user signup email.
    try {
      await _firestore.collection(_mailCollection).add({
        'to': [email],
        'message': {
          'subject': 'Your verification code',
          'text':
              'Your verification code is: $code. It expires in $_codeExpiryMinutes minutes.',
        },
      });
    } catch (_) {
      // Extension may not be installed; code still returned for popup.
    }
    return code;
  }

  static String _sanitizeDocId(String email) =>
      email.replaceAll(RegExp(r'[^a-z0-9]'), '_');

  String _generateCode() {
    final r = Random();
    return List.generate(_codeLength, (_) => r.nextInt(10)).join();
  }

  /// Verify [code] for [email]. Returns true if valid.
  Future<bool> verifyCode(String email, String code) async {
    final trimmed = email.trim().toLowerCase();
    final codeDigits = code.trim().replaceAll(RegExp(r'\D'), '');
    if (trimmed.isEmpty || codeDigits.length != _codeLength) return false;

    try {
      final callable = _functions.httpsCallable('verifyEmailVerificationCode');
      final result = await callable.call({'email': trimmed, 'code': codeDigits});
      final data = result.data as Map<String, dynamic>?;
      return data?['valid'] == true;
    } catch (_) {
      return await _verifyCodeFallback(trimmed, codeDigits);
    }
  }

  /// Fallback: read code from Firestore and check.
  Future<bool> _verifyCodeFallback(String email, String code) async {
    final ref = _firestore.collection(_codesCollection).doc(_sanitizeDocId(email));
    final snap = await ref.get();
    if (!snap.exists) return false;
    final data = snap.data()!;
    final stored = data['code'] as String?;
    final expiry = (data['expiry'] as Timestamp?)?.toDate();
    if (stored == null || expiry == null) return false;
    if (DateTime.now().isAfter(expiry)) return false;
    final valid = stored == code;
    if (valid) await ref.delete();
    return valid;
  }
}
