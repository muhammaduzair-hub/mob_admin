import 'package:flutter/material.dart';
import 'package:mob_admin_panel/classes/db_mob.dart';
import 'mobdetail.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as con;

class HistoryMob extends StatefulWidget {
  static List<DB_Mob> hostory_moblist ;

  @override
  _HistoryMobState createState() => _HistoryMobState();
}

class _HistoryMobState extends State<HistoryMob> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return HistoryMob.hostory_moblist ==null?
        Center(child: CircularProgressIndicator(value: 100,),)
    :
    ListView.builder(
      itemCount: HistoryMob.hostory_moblist.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, i) =>Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                (i + 1).toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              HistoryMob.hostory_moblist[i].mname,
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
            onTap: (){
              DB_Mob a;
              setState(() {
                a = HistoryMob.hostory_moblist[i];
              });
              Navigator.push(context, MaterialPageRoute(builder: (context) => MobDetail(selectedmob: a,),));
            }

          ),
          Divider(
            color: Colors.blue,
            height: 15,
          ),
        ],
      ) ,
    );
  }
}
