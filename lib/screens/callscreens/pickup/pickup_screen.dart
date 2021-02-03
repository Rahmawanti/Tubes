import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tubes_skype/models/call.dart';
import 'package:tubes_skype/resources/call_methods.dart';
import 'package:tubes_skype/screens/callscreens/call_screen.dart';
import 'package:tubes_skype/screens/chatscreens/widgets/cached_image.dart';
import 'package:tubes_skype/utils/permissions.dart';

class PickupScreen extends StatelessWidget {

  final Call call;
  final CallMethods callMethods = CallMethods();

  PickupScreen({
    @required this.call,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Incoming...",
            style: TextStyle(
              fontSize: 30,
              ),
            ),
            SizedBox(height: 50),
            CachedImage(
              call.callerPic,
              isRound: true,
              radius: 180,
            ),
            SizedBox(height: 15),
            Text(
              call.callerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async{
                    await callMethods.endCall(call: call);
                  },
                ),
                SizedBox(width: 25),
                IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.green,
                  onPressed: () async => await Permissions.cameraAndMicrophonePermissionsGranted()
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CallScreen(call: call)
                      ),
                  ) : {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
