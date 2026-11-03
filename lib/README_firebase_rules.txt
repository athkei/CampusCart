FIRESTORE RULES (Firebase console > Firestore > Rules)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Menu: readable by any signed-in student, not writable from the app.
    match /menu/{doc} {
      allow read: if request.auth != null;
    }
    // Students may create orders for themselves and read only their own.
    // Status changes are intentionally not allowed from the student client;
    // use an authorized admin/backend process or Firebase Console.
    match /orders/{orderId} {
      allow create: if request.auth != null
                    && request.resource.data.uid == request.auth.uid;
      allow read: if request.auth != null
                  && resource.data.uid == request.auth.uid;
      allow update, delete: if false;
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

NOTE: Update the Firestore rules in Firebase Console > Firestore Database > Rules.
This file documents the rules; it does not deploy them. Students' My Orders query
filters by uid and sorts by timestamp to satisfy owner-only reads and display
newest orders first.

PUBSPEC DEPENDENCIES
  firebase_core, firebase_auth, firebase_database, cloud_firestore, firebase_storage, image_picker

ANDROID: AndroidManifest.xml
  <uses-permission android:name="android.permission.CAMERA"/>
iOS: Info.plist
  NSCameraUsageDescription, NSPhotoLibraryUsageDescription

SEEDING THE MENU (one time)
  1. Firestore > Rules: temporarily allow signed-in writes inside match /menu/{doc}.
  2. Run the app, log in, tap the menu upload icon if enabled.
  3. Remove the temporary write permission and publish the rules again.
