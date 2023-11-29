import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:signin_signup/model/model.dart';

class DatabaseServices {
  static Future<void> addUserToDatabase({
    required String? id,
    required String? image,
    required String? about,
    required String? name,
    required String? email,
  }) async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('Users');
      await users.doc(id).set({
        'id': id,
        'image': image,
        'about': about,
        'name': name,
        'email': email,
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<MyUser> getUser(String id) async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('Users');
      final snapshot = await users.doc(id).get();
      final data = snapshot.data() as Map<String, dynamic>;

      return MyUser.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Stream<MyUser> getCurrentUser() async* {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      Stream<DocumentSnapshot<Map<String, dynamic>>> snapshot =
          FirebaseFirestore.instance
              .collection('Users')
              .doc(user?.uid)
              .snapshots();

      yield* snapshot.map((event) => MyUser.fromJson(event.data()));
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<void> updateProfilePicture(File file, String? userId) async {
    final ext = file.path.split('.').last;
    final Reference storageReference =
        FirebaseStorage.instance.ref().child('profile_pictures/$userId.$ext');

    try {
      await storageReference.putFile(file);
      final url = await storageReference.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'image': url});
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateProfile({
    required String? userId,
    required String? name,
    required String? about,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'name': name, 'about': about});
    } catch (e) {
      rethrow;
    }
  }
}
