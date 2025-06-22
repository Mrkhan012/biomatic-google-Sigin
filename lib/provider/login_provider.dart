import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sigi/service/auth_service.dart';

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>(
  (ref) => LoginViewModel(ref),
);

class LoginViewModel extends StateNotifier<LoginState> {
  final Ref ref;

  LoginViewModel(this.ref) : super(LoginState()) {
    detectBiometricType(); 
  }

  void setPassword(String value) {
    state = state.copyWith(password: value);
  }

  Future<void> authenticate(BuildContext context,
      {bool allowDeviceFallback = false}) async {
    final result = await ref
        .read(authServiceProvider)
        .authenticateWithBiometrics(allowDeviceFallback: allowDeviceFallback);

    state = state.copyWith(isAuthenticated: result);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result
            ? 'Login Successful'
            : 'Biometric Authentication Failed'),
      ),
    );
  }

  void loginWithPassword(BuildContext context) {
    if (state.password == '1234') {
      state = state.copyWith(isAuthenticated: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid PIN')),
      );
    }
  }

  void showPinFallback() {
    state = state.copyWith(showPasswordFallback: true);
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).clearLoginToken();
    state = LoginState(); // reset
  }

  Future<void> detectBiometricType() async {
    final types =
        await ref.read(authServiceProvider).getAvailableBiometricTypes();
    if (types.contains(BiometricType.face)) {
      state = state.copyWith(biometricType: BiometricType.face);
    } else if (types.contains(BiometricType.fingerprint)) {
      state = state.copyWith(biometricType: BiometricType.fingerprint);
    }
  }
}

class LoginState {
  final bool isAuthenticated;
  final bool showPasswordFallback;
  final String password;
  final BiometricType? biometricType;

  LoginState({
    this.isAuthenticated = false,
    this.showPasswordFallback = false,
    this.password = '',
    this.biometricType,
  });

  LoginState copyWith({
    bool? isAuthenticated,
    bool? showPasswordFallback,
    String? password,
    BiometricType? biometricType,
  }) {
    return LoginState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      showPasswordFallback: showPasswordFallback ?? this.showPasswordFallback,
      password: password ?? this.password,
      biometricType: biometricType ?? this.biometricType,
    );
  }
}
