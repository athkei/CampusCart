FIRESTORE RULES (Firebase console > Firestore > Rules)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Menu: readable by any signed-in student, not writable from the app
    match /menu/{doc} {
      allow read: if request.auth != null;
    }
    // Orders: each student only sees/creates their own
    match /orders/{orderId} {
      allow create: if request.auth != null && request.resource.data.uid == request.auth.uid;
      allow read, update: if request.auth != null && resource.data.uid == request.auth.uid;
    }
  }
}

STORAGE RULES (Firebase console > Storage > Rules)
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_photos/{userId}.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /food_images/{allPaths=**} {
      allow read: if request.auth != null;
    }
  }
}

PUBSPEC DEPENDENCIES
  firebase_core, firebase_auth, cloud_firestore, firebase_storage, image_picker

ANDROID: AndroidManifest.xml
  <uses-permission android:name="android.permission.CAMERA"/>
iOS: Info.plist
  NSCameraUsageDescription, NSPhotoLibraryUsageDescription
