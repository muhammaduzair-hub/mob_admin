import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'colors.dart';

class MyToast extends StatefulWidget {
  @override
  _MyToastState createState() => _MyToastState();

  static showToast(String msg){
    Fluttertoast.showToast(
      msg: msg,//"This is Center Short Toast",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: MyColors.myForeColor,
      textColor: MyColors.myBackColor,
      fontSize: 18.0,
    );
  }
}

class _MyToastState extends State<MyToast> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

