import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static Future<String?> uploadImage(File imageFile) async {
    try {
      Reference storageReference = FirebaseStorage.instance.ref().child('images');
      UploadTask uploadTask = storageReference.child('image1.jpg').putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
