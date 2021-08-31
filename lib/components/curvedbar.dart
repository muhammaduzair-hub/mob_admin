import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:mob_admin_panel/components/colors.dart';
// import 'package:mob_admin_panel/pageviews/home/homeview.dart';
// import 'package:mob_admin_panel/pageviews/mob/mob.dart';
// import 'package:mob_admin_panel/pageviews/devices/devices.dart';
// import 'package:mob_admin_panel/pageviews/zone/zone.dart';

class CurvedBar extends StatefulWidget {
  @override
  _CurvedBarState createState() => _CurvedBarState();
}

class _CurvedBarState extends State<CurvedBar> {
  static int _page=0;
  GlobalKey _bottomNavigationKey = GlobalKey();

  changePage(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pop();
        Navigator.pushNamed(context, 'home');
        break;
      case 1:
        Navigator.of(context).pop();
        Navigator.pushNamed(context, 'mob');
        break;
      case 2:
        Navigator.of(context).pop();
        Navigator.pushNamed(context, 'device');
        break;
      case 3:
        Navigator.of(context).pop();
        Navigator.pushNamed(context, 'zone');
        break;
      default:
        Navigator.pushNamed(context, 'home');
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      key: _bottomNavigationKey,
      index: _page,
      height: 50.0,
      items: <Widget>[
        Icon(
          Icons.home,
          size: 30,
          color: MyColors.myForeColor,
        ),
        Icon(
          Icons.people,
          size: 30,
          color: MyColors.myForeColor,
        ),
        Icon(
          Icons.devices,
          size: 30,
          color: MyColors.myForeColor,
        ),
        Icon(
          Icons.location_off_sharp,
          size: 30,
          color: MyColors.myForeColor,
        ),
      ],
      color: MyColors.myBackColor,
      buttonBackgroundColor: MyColors.myBackColor,
      backgroundColor: MyColors.myForeColor,
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 1000),
      onTap: (index) {
        setState(() {
          _page = index;
          setState(() {
            MyColors.myForeColor = Colors.white;
            MyColors.myBackColor = Colors.blue;
          });
          changePage(index);
        });
      },
      letIndexChange: (index) => true,
    );
  }
}
