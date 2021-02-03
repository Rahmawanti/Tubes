import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubes_skype/models/call.dart';
import 'package:tubes_skype/provider/user_provider.dart';
import 'package:tubes_skype/resources/call_methods.dart';
import 'package:tubes_skype/screens/callscreens/pickup/pickup_screen.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    @required this.scaffold,
  });

  @override
  Widget build(BuildContext context) {

    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return (userProvider != null && userProvider.getUsersData != null)
    ? StreamBuilder<DocumentSnapshot>(
      stream: callMethods.callStream(uid: userProvider.getUsersData.uid),
      builder: (context, snapshot){
        if (snapshot.hasData && snapshot.data.data() != null){
          Call call = Call.fromMap(snapshot.data.data());

          if (!call.hasDialled){
            return PickupScreen(call: call);
          }

          return PickupScreen(call: call);
        }
        return scaffold;
      },
    ) : Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
