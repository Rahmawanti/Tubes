import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tubes_skype/enum/user_state.dart';
import 'package:tubes_skype/models/users_data.dart';
import 'package:tubes_skype/resources/auth_methods.dart';
import 'package:tubes_skype/utils/utilities.dart';

class OnlineDotIndikator extends StatelessWidget {
  final String uid;
  final AuthMethods _authMethods = AuthMethods();

  OnlineDotIndikator({
    @required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    getColor(int state) {
      switch (Utils.numToState(state)) {
        case UserState.Offline:
          return Colors.red;
        case UserState.Offline:
          return Colors.green;
        default:
          return Colors.orange;
      }
    }

    return Align(
      alignment: Alignment.topRight,
      child: StreamBuilder<DocumentSnapshot>(
        stream: _authMethods.getUserStream(
          uid: uid,
        ),
        builder: (context, snapshot) {
          UsersData usersData;

          if (snapshot.hasData && snapshot.data.data != null) {
            usersData = UsersData.fromMap(snapshot.data.data());
          }

          return Container(
            height: 10,
            width: 10,
            margin: EdgeInsets.only(right: 8, top: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getColor(usersData?.state),
            ),
          );
        },
      ),
    );
  }
}
