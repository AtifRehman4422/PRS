/// App-level auth user model. Used by ViewModel/View; mapping from Firebase is in repository.
class AuthUser {
  const AuthUser({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.phoneNumber,
  });

  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;
  final String? phoneNumber;

  String get displayLabel =>
      displayName ?? email ?? phoneNumber ?? 'User';

  bool get hasPhoto => photoURL != null && photoURL!.isNotEmpty;
}
