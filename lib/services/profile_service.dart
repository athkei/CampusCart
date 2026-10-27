import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Handles the optional profile photo: pick -> upload to Storage -> save URL
/// in the Realtime Database at users/{uid}/photoUrl.
class ProfileService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  DatabaseReference get _userRef => _db.ref('users/$_uid');

  /// Live user profile (firstName, lastName, email, photoUrl).
  Stream<DatabaseEvent> userStream() => _userRef.onValue;

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

  /// Uploads to profile_photos/{uid}.jpg and saves the download URL.
  Future<String> uploadProfilePhoto(File file) async {
    final ref = _storage.ref().child('profile_photos/$_uid.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();
    await _userRef.update({'photoUrl': url});
    return url;
  }

  /// Removes the photo and goes back to the default avatar.
  Future<void> removeProfilePhoto() async {
    try {
      await _storage.ref().child('profile_photos/$_uid.jpg').delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
    await _userRef.child('photoUrl').remove();
  }
}
