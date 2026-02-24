import 'package:propertyrent/data/datasource/auth_api.dart';

/// Email OTP is sent by backend during signup (POST /api/auth/signup).
/// Verification is POST /api/auth/verify-otp. This repo is kept for compatibility;
/// signup flow uses AuthApi.signup and AuthApi.verifyOtp directly.
class EmailVerificationRepository {
  /// Requesting code is done via AuthApi.signup in SignupView.
  /// Use AuthApi.verifyOtp(email, code) for verification.
  Future<String?> requestVerificationCode(String email) async {
    throw UnimplementedError(
      'Use AuthApi.signup in SignupView to send OTP. OTP is sent when signup is submitted with all fields + image.',
    );
  }

  Future<bool> verifyCode(String email, String code) async {
    final result = await AuthApi.verifyOtp(email, code);
    return result.success;
  }
}
