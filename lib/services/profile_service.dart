import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
/// Handles the optional profile photo: pick -> encode as base64 -> save in
/// Firestore at users/{uid}.photoUrl (no Firebase Storage needed).
class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _userRef =>
      _db.collection('users').doc(_uid);

  /// Live user profile (firstName, lastName, email, photoUrl).
  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() =>
      _userRef.snapshots();

  /// Opens the camera or the gallery. Returns null if the user cancels.
  Future<File?> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    return picked == null ? null : File(picked.path);
  }

  /// Saves the photo as a base64 string at users/{uid}.photoUrl.
  Future<String> uploadProfilePhoto(File file) async {
    final bytes = await file.readAsBytes();
    final b64 = base64Encode(bytes);
    await _userRef.set({'photoUrl': b64}, SetOptions(merge: true));
    return b64;
  }

  /// Removes the photo and goes back to the default avatar.
  Future<void> removeProfilePhoto() async {
    await _userRef.set({'photoUrl': null}, SetOptions(merge: true));
  }
}
