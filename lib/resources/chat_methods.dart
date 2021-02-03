import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubes_skype/constants/strings.dart';
import 'package:tubes_skype/models/message.dart';
import 'package:tubes_skype/models/users_data.dart';
import 'package:tubes_skype/models/contact.dart';
import 'package:flutter/material.dart';

class ChatMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _messageCollection =
      _firestore.collection(MESSAGES_COLLECTION);

  final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);

  Future<void> addMessageToDb(
      Message message, UsersData sender, UsersData receiver) async {
    var map = message.toMap();

    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId)
        .add(map);

    addToContacts(senderId: message.senderId, receiverId: message.receiverId);

    return await _messageCollection
        .doc(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }

  DocumentReference getContactsDocument({String of, String forContact}) =>
      _userCollection.doc(of).collection(CONTACTS_COLLECTION).doc(forContact);

  addToContacts({String senderId, String receiverId}) async {
    Timestamp currentTime = Timestamp.now();

    await addToSendersContact(senderId, receiverId, currentTime);
    await addToReceiverContacts(senderId, receiverId, currentTime);
  }

  Future<void> addToSendersContact(
      String senderId, String receiverId, currentTime) async {
    DocumentSnapshot receiverSnapshot =
        await getContactsDocument(of: receiverId, forContact: senderId).get();

    if (!receiverSnapshot.exists) {
      //does not exist
      Contact senderContact = Contact(
        uid: senderId,
        addedOn: currentTime,
      );

      var senderMap = senderContact.toMap(senderContact);

      await getContactsDocument(of: receiverId, forContact: senderId)
          .set(senderMap);
    }
  }

  Future<void> addToReceiverContacts(
      String senderId, String receiverId, currentTime) async {
    DocumentSnapshot senderSnapshot =
        await getContactsDocument(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      //does not exist
      Contact receiverContact = Contact(
        uid: receiverId,
        addedOn: currentTime,
      );

      var receiverMap = receiverContact.toMap(receiverContact);

      await getContactsDocument(of: senderId, forContact: receiverId)
          .set(receiverMap);
    }
  }

  void setImageMsg(String url, String receiverId, String senderId) async {
    Message _message;

    _message = Message.imageMessage(
      message: "IMAGE",
      receiverId: receiverId,
      senderId: senderId,
      photoUrl: url,
      timestamp: Timestamp.now(),
      type: 'image',
    );

    var map = _message.toImageMap();

    //set the data to database
    await _messageCollection
        .doc(_message.senderId)
        .collection(_message.receiverId)
        .add(map);

    _messageCollection
        .doc(_message.receiverId)
        .collection(_message.senderId)
        .add(map);
  }

  Stream<QuerySnapshot> fetchContacts({String userId}) =>
      _userCollection.doc(userId).collection(CONTACTS_COLLECTION).snapshots();

  Stream<QuerySnapshot> fetchLastMessageBetween({
    @required String senderId,
    @required String receiverId,
  }) =>
      _messageCollection
          .doc(senderId)
          .collection(receiverId)
          .orderBy("timestamp")
          .snapshots();
}
