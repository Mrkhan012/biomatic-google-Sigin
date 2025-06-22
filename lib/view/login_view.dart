import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigi/provider/auth_provider.dart';
import 'package:sigi/provider/login_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkRemembered();
  }

  Future<void> _checkRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('remember_me') ?? false) {
      await ref.read(authProvider.notifier).signInWithGoogle(context);
    }
  }

  Future<void> _onGoogleSignIn() async {
    await ref.read(authProvider.notifier).signInWithGoogle(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', rememberMe);
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(loginViewModelProvider);
    final vmNotifier = ref.read(loginViewModelProvider.notifier);
    final user = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    vm.isAuthenticated || user != null ? "Welcome!" : "Secure Login",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    vm.isAuthenticated
                        ? "You're successfully logged in."
                        : user != null
                            ? "Signed in as ${user.displayName}"
                            : "Use fingerprint, PIN or Google to login",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Biometric Authentication
                  if (!vm.isAuthenticated && !vm.showPasswordFallback) ...[
                    InkWell(
                      onTap: () => vmNotifier.authenticate(
                        allowDeviceFallback: true,
                        context,
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.indigo.shade50,
                        child: Icon(
                          Icons.fingerprint,
                          size: 50,
                          color: Colors.indigo.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      vm.biometricType == BiometricType.face
                          ? 'Tap to Login with Face'
                          : 'Tap to Login with Fingerprint',
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Google Sign-In Button
                  if (user == null) ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.login, color: Colors.white),
                      label: const Text("Sign in with Google"),
                      onPressed: _onGoogleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) =>
                              setState(() => rememberMe = value!),
                          activeColor: Colors.deepPurple,
                        ),
                        Text(
                          "Remember me",
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  ],

                  // PIN Fallback
                  if (vm.showPasswordFallback && !vm.isAuthenticated) ...[
                    TextField(
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter 4-digit PIN',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 4,
                      onChanged: vmNotifier.setPassword,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: vm.password.length == 4
                          ? () => vmNotifier.loginWithPassword(context)
                          : null,
                      child: const Text('Login'),
                    ),
                  ],
                 SizedBox(height: 8,),
                  if (!vm.isAuthenticated && !vm.showPasswordFallback) ...[
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: vmNotifier.showPinFallback,
                        child: Text(
                          'Use PIN instead',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Logout (if logged in via biometrics or Google)
                  if (vm.isAuthenticated || user != null) ...[
                    const SizedBox(height: 40),
                    const Icon(Icons.check_circle, color: Colors.green, size: 80),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('remember_me');
                        await ref.read(loginViewModelProvider.notifier).logout();
                        await ref.read(authProvider.notifier).signOut(context);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
