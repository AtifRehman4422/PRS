import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:propertyrent/data/models/auth_user_model.dart';

/// Auth data layer: Firebase Auth + Google Sign-In + Phone. No UI or Riverpod here.
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

  /// Sign up with email and password. Returns [AuthUser] on success.
  Future<AuthUser?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _userToAuthUser(userCredential.user);
  }

  /// Send verification email to current user (e.g. after signup). OTP/link goes to email.
  Future<void> sendEmailVerification() async {
    await _firebaseAuth.currentUser?.sendEmailVerification();
  }

  /// Sign in with email and password. Returns [AuthUser] on success.
  Future<AuthUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _userToAuthUser(userCredential.user);
  }

  /// Send OTP to [phoneNumber] (e.g. +923001234567). Callbacks for result.
  void verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException e) onVerificationFailed,
    void Function(PhoneAuthCredential credential)? onVerificationCompleted,
    void Function(String verificationId)? onCodeAutoRetrievalTimeout,
  }) {
    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted ?? (_) {},
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout ?? (_) {},
    );
  }

  /// Complete phone sign-in with OTP. Returns [AuthUser] on success.
  Future<AuthUser?> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    return _userToAuthUser(userCredential.user);
  }

  static AuthUser? _userToAuthUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoURL: user.photoURL,
      phoneNumber: user.phoneNumber,
    );
  }
}
