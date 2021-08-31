import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mob_admin_panel/classes/db_mob.dart';
import 'package:mob_admin_panel/components/colors.dart';
import 'package:mob_admin_panel/components/curvedbar.dart';
import 'package:mob_admin_panel/components/urlstring.dart';
import 'package:mob_admin_panel/pageviews/mob/historymob.dart';
import 'package:mob_admin_panel/pageviews/mob/pendingmob.dart';

import 'activemob.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as con;

class Mob extends StatefulWidget {

  @override
  _MobState createState() => _MobState();
}

class _MobState extends State<Mob> with SingleTickerProviderStateMixin
{
  TabController _listcontroller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedBar(),
      appBar: AppBar(
        leading: Icon(Icons.add, color: Colors.transparent,),
        title: Text('MOb'), centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white,),
            iconSize: 20,
            onPressed: (){
              gethistorymob();
              getmob();
            },
          ),
        ],
        bottom: new TabBar(
          controller: _listcontroller,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              icon: FaIcon(FontAwesomeIcons.peopleArrows),
              text: 'Mobs',
            ),
            Tab(
              icon: FaIcon(FontAwesomeIcons.history),
              text: 'History',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _listcontroller,
        children: [
          ActiveMob(),
          HistoryMob()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            MyColors.myForeColor = Colors.blue;
            MyColors.myBackColor = Colors.white;
          });
          Navigator.pushNamed(context, 'add_mob');
        },
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listcontroller = new TabController(length: 2, vsync:this,  initialIndex: 0);

    getmob();

    gethistorymob();
  }

  getmob() async {
    var response =await http.get(Uri.parse(UrlString.url+'Mob/getactive'));
    if(response.statusCode == 200)
    {
      setState(() {
        Iterable list = con.json.decode(response.body);
        ActiveMob.moblist = list.map((e) => DB_Mob.fromJson(e)).toList();
      });
    }
    else
    {
      setState(() {
        ActiveMob.moblist = null;
      });
    }
  }

  getpending() async {
    var response =await http.get(Uri.parse(UrlString.url+'Mob/getpending'));
    if(response.statusCode == 200)
    {
      setState(() {
        Iterable list = con.json.decode(response.body);
        PendingMob.moblist = list.map((e) => DB_Mob.fromJson(e)).toList();
      });
    }
    else
    {
      setState(() {
        PendingMob.moblist = null;
      });
    }
  }

  gethistorymob() async {
    var response =await http.get(Uri.parse(UrlString.url+'Mob/gethistory'));
    if(response.statusCode == 200)
    {
      setState(() {
        Iterable list = con.json.decode(response.body);
        HistoryMob.hostory_moblist = list.map((e) => DB_Mob.fromJson(e)).toList();
      });
    }
    else
    {
      setState(() {
        HistoryMob.hostory_moblist = null;
      });
    }
  }


}
