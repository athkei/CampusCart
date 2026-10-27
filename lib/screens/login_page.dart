import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../common.dart';
import '../services/auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _hide = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // No manual navigation needed: AuthGate switches to HomePage automatically.
      await _auth.login(email: _email.text.trim(), password: _password.text);
    } on FirebaseAuthException catch (e) {
      if (mounted) showMsg(context, AuthService.errorMessage(e));
    } catch (e) {
      if (mounted) showMsg(context, 'Error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _forgot() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      showMsg(context, 'Enter your email first.');
      return;
    }
    try {
      await _auth.sendPasswordReset(email);
      if (mounted) showMsg(context, 'Password reset email sent.');
    } on FirebaseAuthException catch (e) {
      if (mounted) showMsg(context, AuthService.errorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackdrop(child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(),
                  const SizedBox(height: 20),
                  const Text('Welcome to CampusCart',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: ink)),
                  const SizedBox(height: 6),
                  const Text(
                      'Sign in to pre-order food from campus stalls.',
                      style: TextStyle(color: grey, fontSize: 14)),
                  const SizedBox(height: 32),
                  const Text('Email',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: ink, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: softField('name@email.com'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter your email';
                      }
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(v.trim())) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Password',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: ink,
                              fontSize: 14)),
                      GestureDetector(
                        onTap: _forgot,
                        child: const Text('Forgot password?',
                            style: TextStyle(
                                color: blue,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _password,
                    obscureText: _hide,
                    decoration: softField('••••••••').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                            _hide ? Icons.visibility_off : Icons.visibility,
                            color: grey),
                        onPressed: () => setState(() => _hide = !_hide),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your password' : null,
                  ),
                  const SizedBox(height: 22),
                  _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: blue))
                      : AppButton(text: 'Sign in', onPressed: _login),
                  const SizedBox(height: 18),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Don't have an account? ",
                            style: TextStyle(color: ink)),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterPage()),
                          ),
                          child: const Text('Sign up',
                              style: TextStyle(
                                  color: blue, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }
}
