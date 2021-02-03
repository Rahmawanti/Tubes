import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:tubes_skype/models/users_data.dart';
import 'package:tubes_skype/resources/auth_methods.dart';
import 'package:tubes_skype/screens/chatscreens/chat_screen.dart';
import 'package:tubes_skype/utils/universal_variables.dart';
import 'package:tubes_skype/widgets/custom_tile.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AuthMethods _authMethods = AuthMethods();

  List<UsersData> userList;
  String query = "";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _authMethods.getCurrentUser().then((User user) {
      _authMethods.fetchAllUsers(user).then((List<UsersData> list) {
        setState(() {
          userList = list;
        });
      });
    });
  }

  searchAppBar(BuildContext context) {
    return GradientAppBar(
      backgroundColorStart: UniversalVariables.gradientColorStart,
      backgroundColorEnd: UniversalVariables.gradientColorEnd,

      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ), // IconButton
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: TextField(
            controller: searchController,
            onChanged: (val) {
              setState(() {
                query = val;
              });
            },
            cursorColor: UniversalVariables.blackColor,
            autofocus: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 35,
            ), // Text Style
            decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => searchController.clear);
                  },
                ), // Icon Button
                border: InputBorder.none,
                hintText: "Search",
                hintStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                  color: Color(0x88ffffff),
                ) // Text Style
                ), // Input Decoration
          ), // TextField
        ), // Padding
      ), // PreferredSize
    ); // GradientAppBar
  }

  buildSuggestions(String query) {
    final List<UsersData> suggestionList = query.isEmpty
        ? []
        : userList != null
        ? userList.where((UsersData user) {
          String _getUsername = user.username.toLowerCase();
          String _query = query.toLowerCase();
          String _getName = user.name.toLowerCase();
          bool matchesUsername = _getUsername.contains(_query);
          bool matchesName = _getName.contains(_query);

      return (matchesUsername || matchesName);

      // (User user) => (user.username.toLowerCase().contains(query.toLowerCase()) ||
      //     (user.name.toLowerCase().contains(query.toLowerCase()))),
    }).toList()
        : [];

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: ((context, index) {
        UsersData searchedUser = UsersData(
            uid: suggestionList[index].uid,
            profilePhoto: suggestionList[index].profilePhoto,
            name: suggestionList[index].name,
            username: suggestionList[index].username); // User

        return CustomTile(
          mini: false,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          receiver: searchedUser,
                        ))); // MaterialPageRoute
          },
          leading: CircleAvatar(
            backgroundImage: NetworkImage(searchedUser.profilePhoto),
            backgroundColor: Colors.grey,
          ), // CircleAvatar
          title: Text(
            searchedUser.username,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ), // Text Style
          ), // Text
          subtitle: Text(
            searchedUser.name,
            style: TextStyle(color: UniversalVariables.greyColor),
          ), // Texts
        ); // CustomFile
      }),
    ); // ListView.builder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: searchAppBar(context),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: buildSuggestions(query),
        ));
  }
}
