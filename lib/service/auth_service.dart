import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

 Future<bool> authenticateWithBiometrics({bool allowDeviceFallback = false}) async {
  try {
    final isAvailable = await auth.canCheckBiometrics;
    final isDeviceSupported = await auth.isDeviceSupported();

    if (!isAvailable || !isDeviceSupported) return false;

    final didAuthenticate = await auth.authenticate(
      localizedReason: 'Please authenticate to login',
      options: AuthenticationOptions(
        biometricOnly: !allowDeviceFallback,
        stickyAuth: true,
      ),
    );

    if (didAuthenticate) {
      await secureStorage.write(key: 'auth_token', value: 'secure_token_123');
    }

    return didAuthenticate;
  } on PlatformException catch (e) {
    print('Authentication error: $e');
    return false;
  }
}


  Future<void> saveLoginToken() async {
    await secureStorage.write(key: 'auth_token', value: 'secure_token_123');
  }

  Future<void> clearLoginToken() async {
    await secureStorage.delete(key: 'auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await secureStorage.read(key: 'auth_token');
    return token != null;
  }
  Future<List<BiometricType>> getAvailableBiometricTypes() async {
  try {
    return await auth.getAvailableBiometrics();
  } catch (e) {
    print('Error checking biometrics: $e');
    return [];
  }
}

}
