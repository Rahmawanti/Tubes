import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubes_skype/models/contact.dart';
import 'package:tubes_skype/models/users_data.dart';
import 'package:tubes_skype/provider/user_provider.dart';
import 'package:tubes_skype/resources/auth_methods.dart';
import 'package:tubes_skype/resources/chat_methods.dart';
import 'package:tubes_skype/screens/chatscreens/chat_screen.dart';
import 'package:tubes_skype/screens/chatscreens/widgets/cached_image.dart';
import 'package:tubes_skype/screens/pageviews/widgets/online_dot_indicator.dart';
import 'package:tubes_skype/utils/universal_variables.dart';
import 'package:tubes_skype/widgets/custom_tile.dart';

import 'last_message_container.dart';

class ContactView extends StatelessWidget {
  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  ContactView(this.contact);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UsersData>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UsersData user = snapshot.data;

          return ViewLayout(
            contact: user,
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final UsersData contact;
  final ChatMethods _chatMethods = ChatMethods();

  ViewLayout({
    @required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return CustomTile(
      mini: false,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiver: contact,
            ),
          )),
      title: Text(
        contact?.name ?? "..",
        style:
            TextStyle(color: Colors.white, fontFamily: "Arial", fontSize: 19),
      ),
      subtitle: LastMessageContainer(
        stream: _chatMethods.fetchLastMessageBetween(
            senderId: userProvider.getUsersData.uid, receiverId: contact.uid),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: <Widget>[
            CachedImage(
              contact.profilePhoto,
              radius: 80,
              isRound: true,
            ),
            OnlineDotIndikator(
              uid: contact.uid,
            ),
          ],
        ),
      ),
    );
  }
}
