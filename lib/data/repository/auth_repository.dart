import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:propertyrent/data/models/auth_user_model.dart';

/// Auth data layer: Firebase Auth + Google Sign-In. No UI or Riverpod here.
class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// Stream of auth state. Maps Firebase [User] to [AuthUser]; null when logged out.
  Stream<AuthUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_userToAuthUser);

  /// Sign in with Google. Returns [AuthUser] on success, null if user cancelled.
  Future<AuthUser?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return _userToAuthUser(userCredential.user);
  }

  /// Sign out from Firebase and Google.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  static AuthUser? _userToAuthUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoURL: user.photoURL,
    );
  }
}
