import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mob_admin_panel/classes/db_emp.dart';
import 'package:mob_admin_panel/pages/login.dart';
import 'package:mob_admin_panel/pageviews/devices/adddevices.dart';
import 'package:mob_admin_panel/pageviews/devices/devicelist.dart';
import 'package:mob_admin_panel/pageviews/home/emplist.dart';
import 'package:mob_admin_panel/pageviews/home/homeview.dart';
import 'package:mob_admin_panel/pageviews/home/loginperson.dart';
import 'package:mob_admin_panel/pageviews/home/signup.dart';
import 'package:mob_admin_panel/pageviews/mob/addmob.dart';
import 'package:mob_admin_panel/pageviews/mob/mob.dart';
import 'package:mob_admin_panel/pageviews/mob/mobdetail.dart';
import 'package:mob_admin_panel/pageviews/zone/showmap.dart';
import 'package:mob_admin_panel/pageviews/zone/zonelist.dart';
import 'package:splashscreen/splashscreen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(
          backgroundColor: Colors.white,
          image: Image.asset("asset/images/2.png"),
          photoSize: 200,
          loaderColor: Colors.blue,
          seconds: 3,
          navigateAfterSeconds: Login(),
        ),//HomeView(loginuser: DB_Emp(ename: "Uzair", email: "Uzairhere@admin", edesg: "Admin", epass: "abc123", eflag: true),),
      routes: {
          'login':(context)=>Login(),
        'home' : (context)=>HomeView(loginuser: LoginPerson.loginuser),//DB_Emp(ename: "Uzair", email: "Uzairhere@admin", edesg: "Admin", epass: "abc123", eflag: true),),
        'emplist':(context)=>EmpList(),
        'signup':(context)=>Signup(),
        'mob':(context)=>Mob(),
        'add_mob':(context)=>AddMob(),
        //'mob_detail':(context)=>MobDetail(),
        'device':(context)=>DevicesList(),
        'add_device':(context)=>AddDevices(),
        'zone':(context)=>ZoneList(),
        'add_zone':(context)=>ShowMap(),
      },
    );
  }
}
