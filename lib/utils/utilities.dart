import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tubes_skype/enum/user_state.dart';

class Utils {
  static String getUsername(String email) {
    return "live:${email.split('@')[0]}";
  }

  static String getInitials(String name) {
    List<String> nameSplit = name.split(" ");
    String firstNameInitials = nameSplit[0][0];
    String lastNameInitials = nameSplit[1][0];
    return firstNameInitials + lastNameInitials;
  }

  static Future<File> pickImage({@required ImageSource source}) async {
    PickedFile selectedImage = await ImagePicker().getImage(source: source);
    File selected = File(selectedImage.path);
    return compressImage(selected);
  }

  static Future<File> compressImage(File imageToCompress) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int random = Random().nextInt(1000);

    Im.Image image = Im.decodeImage(imageToCompress.readAsBytesSync());
    Im.copyResize(image, width: 500, height: 500);

    return new File('$path/img_$random.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));
  }

  static int stateToNum(UserState userState) {
    switch (userState) {
      case UserState.Offline:
        return 0;

      case UserState.Online:
        return 1;

      default:
        return 2;
    }
  }

  static UserState numToState(int number) {
    switch (number) {
      case 0:
        return UserState.Offline;

      case 1:
        return UserState.Online;

      default:
        return UserState.Waiting;
    }
  }
}
