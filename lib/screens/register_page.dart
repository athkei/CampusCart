import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../common.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _hide = true;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.register(
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      // The user is now signed in, so AuthGate swaps to HomePage.
      // Pop this screen so it does not stay on top of the navigator.
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    } on FirebaseAuthException catch (e) {
      if (mounted) showMsg(context, AuthService.errorMessage(e));
    } catch (e) {
      if (mounted) showMsg(context, 'Error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final eye = IconButton(
      icon: Icon(_hide ? Icons.visibility_off : Icons.visibility,
          color: ink, size: 20),
      onPressed: () => setState(() => _hide = !_hide),
    );

    return Scaffold(
      body: AuthBackdrop(child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                          const Icon(Icons.chevron_left, color: ink, size: 30),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Register',
                              style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: ink)),
                          Text('complete your information to register',
                              style: TextStyle(fontSize: 12, color: ink)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _first,
                        decoration: boldField('First Name'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _last,
                        decoration: boldField('Last Name'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: boldField('Email'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter your email';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(v.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: _hide,
                  decoration: boldField('Password', suffix: eye),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter your password';
                    if (v.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirm,
                  obscureText: _hide,
                  decoration: boldField('Confirm Password'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirm your password';
                    if (v != _password.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                    'You can add a profile photo after signing up.',
                    style: TextStyle(color: grey, fontSize: 12)),
                const SizedBox(height: 18),
                _loading
                    ? const Center(child: CircularProgressIndicator(color: blue))
                    : AppButton(text: 'Sign Up', onPressed: _register),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
