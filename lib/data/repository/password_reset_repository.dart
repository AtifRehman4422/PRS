import 'package:propertyrent/data/datasource/auth_api.dart';

/// Password reset via PRS backend (no Firebase).
class PasswordResetRepository {
  Future<void> requestPasswordReset(String email) async {
    final result = await AuthApi.forgotPassword(email);
    if (!result.success) throw Exception(result.message ?? 'Failed to send reset code');
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final result = await AuthApi.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    if (!result.success) throw Exception(result.message ?? 'Failed to reset password');
  }
}
