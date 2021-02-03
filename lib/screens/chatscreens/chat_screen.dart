import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tubes_skype/constants/strings.dart';
import 'package:tubes_skype/enum/view_state.dart';
import 'package:tubes_skype/models/message.dart';
import 'package:tubes_skype/models/users_data.dart';
import 'package:tubes_skype/provider/image_upload_provider.dart';
import 'package:tubes_skype/resources/auth_methods.dart';
import 'package:tubes_skype/resources/chat_methods.dart';
import 'package:tubes_skype/resources/storage_methods.dart';
import 'package:tubes_skype/screens/callscreens/pickup/pickup_layout.dart';
import 'package:tubes_skype/screens/chatscreens/widgets/cached_image.dart';
import 'package:tubes_skype/utils/call_utilities.dart';
import 'package:tubes_skype/utils/permissions.dart';
import 'package:tubes_skype/utils/universal_variables.dart';
import 'package:tubes_skype/utils/utilities.dart';
import 'package:tubes_skype/widgets/appbar.dart';
import 'package:tubes_skype/widgets/custom_tile.dart';



class ChatScreen extends StatefulWidget {
  final UsersData receiver;

  ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textFieldController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();

  final StorageMethods _storageMethods = StorageMethods();
  final ChatMethods _chatMethods = ChatMethods();
  final AuthMethods _authMethods = AuthMethods();

  ScrollController _listScrollController = ScrollController();

  UsersData sender;

  String _currentUserId;

  bool isWriting = false;

  bool showEmojiPicker = false;

  ImageUploadProvider _imageUploadProvider;

  @override
  void initState() {
    super.initState();
    _authMethods.getCurrentUser().then((user) {
      _currentUserId = user.uid;

      setState(() {
        sender = UsersData(
          uid: user.uid,
          name: user.displayName,
          profilePhoto: user.photoURL,
        );
      });
    });
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer(){
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer(){
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: customAppBar(context),
        body: Column(
          children: <Widget>[
            Flexible(
              child: messageList(),
            ), // Flexible
            _imageUploadProvider.getViewState == ViewState.LOADING
                ? Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 15),
                  child: CircularProgressIndicator(),)
                : Container(),
            chatControls(),
            showEmojiPicker ? Container(child: emojiContainer()) : Container(),
          ], // <Widget>[]
        ), // Column
      ),
    ); // Scaffold
  }

  emojiContainer(){
    return EmojiPicker(
      bgColor: UniversalVariables.separatorColor,
      indicatorColor: UniversalVariables.blueColor,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category){
        setState(() {
          isWriting = true;
        });
        textFieldController.text = textFieldController.text + emoji.emoji;
      },
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(_currentUserId)
          .collection(widget.receiver.uid)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        // SchedulerBinding.instance.addPostFrameCallback((_) {
        //   _listScrollController.animateTo(
        //     _listScrollController.position.minScrollExtent,
        //   duration: Duration(milliseconds: 150),
        //   curve: Curves.easeInOut);
        // });

        return ListView.builder(
          padding: EdgeInsets.all(10),
          controller: _listScrollController,
          reverse: true,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            // mention the arrow syntax if you get the time
            return chatMessageItem(snapshot.data.docs[index]);
          },
        );
      },
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data());
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: _message.senderId == _currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == _currentUserId
            ? senderLayout(_message)
            : receiverLayout(_message),
      ), // Container
    ); // Container
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.senderColor,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ), // BorderRadius.only
      ), // Box Decoration
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ), // Padding
    ); // Container
  }

  getMessage(Message message) {
    return message.type != MESSAGE_TYPE_IMAGE
        ? Text(
      message.message,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0
      ),
    ): message.photoUrl != null
        ?CachedImage(
        message.photoUrl,
        height: 250,
        width: 250,
        radius: 10,)
        :Text("URL was null");
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.receiverColor,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ), // BorderRadius.only
      ), // Box Decoration
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ), // Padding
    ); // Container
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    addMediaModal(context) {
      showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: UniversalVariables.blackColor,
          builder: (context) {
            return Column(children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Icon(
                        Icons.close,
                      ), // Icon
                      onPressed: () => Navigator.maybePop(context),
                    ), // Flat Button
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Context and Tools",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold), // Text Style
                          ), // Text
                        ), // Align
                      ), // Align
                    ) // Expanded
                  ], // <Widget>[]
                ), // Row
              ), // Container
              Flexible(
                child: ListView(
                  children: <Widget>[
                    ModalTile(
                        title: "Media",
                        subtitle: "Share Photos and Videos",
                        icon: Icons.image,
                        onTap: () => pickImage(source: ImageSource.gallery)),
                    ModalTile(
                        title: "File",
                        subtitle: "Share Files",
                        icon: Icons.tab),
                    ModalTile(
                        title: "Contact",
                        subtitle: "Share Contacts",
                        icon: Icons.contacts),
                    ModalTile(
                        title: "Location",
                        subtitle: "Share a Location",
                        icon: Icons.add_location),
                    ModalTile(
                        title: "Schedule Call",
                        subtitle: "Arrange a skype call and get reminders",
                        icon: Icons.schedule),
                    ModalTile(
                        title: "Create poll",
                        subtitle: "Share polls",
                        icon: Icons.poll),
                  ], // <Widget> []
                ), // ListView
              ), //Flexible
            ] // <Widget>[]
                ); // Column
          });
    }

    return Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () => addMediaModal(context),
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: UniversalVariables.fabGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                  controller: textFieldController,
                  focusNode: textFieldFocus,
                  onTap: ()=> hideEmojiContainer(),
                  style: TextStyle(
                    color:  Colors.white,
                  ),
                  onChanged: (val){
                    (val.length > 0 && val.trim() != "")
                        ? setWritingTo(true)
                        : setWritingTo(false);
                  },
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(
                      color: UniversalVariables.greyColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(50.0),
                      ),
                      borderSide: BorderSide.none
                    ),
                    contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: UniversalVariables.separatorColor,
                  ),
                ),
                  IconButton(
                    splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: (){
                          if(!showEmojiPicker){
                            // keyboard is visible
                            hideKeyboard();
                            showEmojiContainer();
                          }else{
                            // keyboard is hidden
                            showKeyboard();
                            hideEmojiContainer();
                          }
                        },
                        icon: Icon(Icons.face),
                  ),
                ],
              ),
            ),
            isWriting
                ? Container()
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.record_voice_over),
                  ),
            isWriting
                ? Container()
                : GestureDetector(
                    onTap: () => pickImage(source: ImageSource.camera),
                    child: Icon(Icons.camera_alt)),
            isWriting
                ? Container(
                    margin: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                        gradient: UniversalVariables.fabGradient,
                        shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        size: 15,
                      ),
                      onPressed: () => sendMessage(),
                    ),
                  )
                : Container()
          ],
        )); // <Widget>[]
  }

  sendMessage() {
    var text = textFieldController.text;

    Message _message = Message(
      receiverId: widget.receiver.uid,
      senderId: sender.uid,
      message: text,
      timestamp: Timestamp.now(),
      type: 'text',
    );

    setState(() {
      isWriting = false;
    });

    textFieldController.text = "";

    _chatMethods.addMessageToDb(_message, sender, widget.receiver);
  }

  void pickImage({@required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    _storageMethods.uploadImage(
      image: selectedImage,
      receiverId: widget.receiver.uid,
      senderId: _currentUserId,
      imageUploadProvider: _imageUploadProvider,
    );
  }

  CustomAppBar customAppBar(context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
        ), // Icon
        onPressed: () {
          Navigator.pop(context);
        },
      ), // Icon Button
      centerTitle: false,
      title: Text(
        widget.receiver.name,
      ), // Text
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.video_call,
          ), // Icon
          onPressed: () async =>
          await Permissions.cameraAndMicrophonePermissionsGranted()
          ? CallUtils.dial(
            from: sender,
            to: widget.receiver,
            context: context
          ): {},
        ), // Icon Button
        IconButton(
          icon: Icon(
            Icons.phone,
          ),
          onPressed: () {}, // Icon
        ) // Icon Button
      ], // <Widget> []
    ); // Custom AppBar
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  const ModalTile({
    @required this.title,
    @required this.subtitle,
    @required this.icon,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: CustomTile(
            mini: false,
            onTap: onTap,
            leading: Container(
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: UniversalVariables.receiverColor,
              ), // Box Decoration
              padding: EdgeInsets.all(10),
              child: Icon(
                icon,
                color: UniversalVariables.greyColor,
                size: 38,
              ), // Icon
            ), // Container
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: UniversalVariables.greyColor,
                fontSize: 14,
              ), // Text Style
            ), // Text
            title: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ))
        )
    );
  }
}
