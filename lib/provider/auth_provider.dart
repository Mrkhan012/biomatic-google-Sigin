import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final googleSignInProvider = Provider((ref) => GoogleSignIn());

final authProvider = StateNotifierProvider<AuthController, User?>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<User?> {
  final Ref ref;
  AuthController(this.ref) : super(null);

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final googleUser = await ref.read(googleSignInProvider).signIn();
      if (googleUser == null) {
        _showSnackBar(context, "Google sign-in cancelled");
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await ref.read(firebaseAuthProvider).signInWithCredential(credential);

      state = userCredential.user;

      _showSnackBar(context, "Signed in as ${state?.displayName ?? 'User'} 🎉");
    } catch (e) {
      _showSnackBar(context, "Sign-in failed: ${e.toString()}");
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await ref.read(firebaseAuthProvider).signOut();
      await ref.read(googleSignInProvider).signOut();
      state = null;
      _showSnackBar(context, "Signed out successfully 👋");
    } catch (e) {
      _showSnackBar(context, "Sign-out failed: ${e.toString()}");
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.deepPurple,
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
