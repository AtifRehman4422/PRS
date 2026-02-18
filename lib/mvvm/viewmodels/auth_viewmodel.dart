import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:propertyrent/data/models/auth_user_model.dart';
import 'package:propertyrent/data/repository/auth_repository.dart';
import 'package:propertyrent/data/repository/email_verification_repository.dart';

/// ViewModel layer: exposes auth state and actions via Riverpod.

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final emailVerificationRepositoryProvider = Provider<EmailVerificationRepository>((ref) {
  return EmailVerificationRepository();
});

/// Stream of current auth user. Null when logged out.
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Current user (nullable). Convenience for one-off read.
final currentAuthUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});
