import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../common.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

/// Placeholder home screen for the auth + profile part.
/// The group can replace the body with the food menu and keep the
/// profile avatar / sign out in the AppBar.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _profile = ProfileService();
  final _auth = AuthService();
  bool _uploading = false;

  Future<void> _changePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final File? file = await _profile.pickImage(source);
      if (file == null) return;
      setState(() => _uploading = true);
      await _profile.uploadProfilePhoto(file);
      if (mounted) showMsg(context, 'Profile photo updated.');
    } catch (e) {
      if (mounted) showMsg(context, 'Could not upload photo: $e');
    }
    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _removePhoto() async {
    try {
      setState(() => _uploading = true);
      await _profile.removeProfilePhoto();
      if (mounted) showMsg(context, 'Profile photo removed.');
    } catch (e) {
      if (mounted) showMsg(context, 'Could not remove photo: $e');
    }
    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign out', style: TextStyle(color: red))),
        ],
      ),
    );
    if (ok == true) await _auth.logout(); // AuthGate returns to LoginPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: StreamBuilder<DatabaseEvent>(
            stream: _profile.userStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Could not load profile.',
                    style: TextStyle(color: red));
              }
              if (!snapshot.hasData) {
                return const CircularProgressIndicator(color: blue);
              }
              final raw = snapshot.data!.snapshot.value;
              final Map<String, dynamic>? data =
                  raw is Map ? Map<String, dynamic>.from(raw) : null;
              var name = data == null
                  ? ''
                  : '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                      .trim();
              if (name.isEmpty) name = 'Student';
              final email = data?['email'] ?? _auth.currentUser?.email ?? '';
              final String? photoUrl = data?['photoUrl'];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: skyBlue,
                          backgroundImage:
                              photoUrl != null ? NetworkImage(photoUrl) : null,
                          child: photoUrl == null
                              ? const Icon(Icons.person, size: 56, color: oceanBlue)
                              : null,
                        ),
                        if (_uploading)
                          const Positioned.fill(
                            child: CircularProgressIndicator(color: blue),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _uploading ? null : _changePhoto,
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundColor: persimmon,
                              child: Icon(Icons.camera_alt,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(name,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: ink)),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(color: grey)),
                    if (photoUrl != null)
                      TextButton(
                        onPressed: _uploading ? null : _removePhoto,
                        child: const Text('Remove photo',
                            style: TextStyle(color: grey)),
                      ),
                    const SizedBox(height: 28),
                    AppButton(text: 'Sign out', onPressed: _confirmLogout),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
