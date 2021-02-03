import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:tubes_skype/models/users_data.dart';
import 'package:tubes_skype/provider/image_upload_provider.dart';
import 'package:tubes_skype/resources/chat_methods.dart';

class StorageMethods{
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Reference _storageReference;

  //User class
  UsersData user = UsersData();

  Future<String> uploadImageToStorage(File image) async{
    try{
      _storageReference = FirebaseStorage.instance.ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');

      UploadTask _storageUploadTask = _storageReference.putFile(image);

      var url = await (await _storageUploadTask).ref.getDownloadURL();

      return url;
    }catch (e){
      print (e);
      return null;
    }
  }

  void uploadImage({
    @required File image,
    @required String receiverId,
    @required String senderId,
    @required ImageUploadProvider imageUploadProvider}) async{

    final ChatMethods chatMethods = ChatMethods();

    // Set some loading value to db and show it to user
    imageUploadProvider.setToLoading();

    // Get url from the image bucket
    String url = await uploadImageToStorage(image);

    // Hide loading
    imageUploadProvider.setToIdle();

    chatMethods.setImageMsg(url, receiverId, senderId);
  }
}