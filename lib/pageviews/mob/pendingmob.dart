import 'package:flutter/material.dart';
import 'package:mob_admin_panel/classes/db_mob.dart';

import 'mobdetail.dart';

class PendingMob extends StatefulWidget {
  static List<DB_Mob> moblist ;
  @override
  _PendingMobState createState() => _PendingMobState();
}

class _PendingMobState extends State<PendingMob> {
  @override
  Widget build(BuildContext context) {

  return PendingMob.moblist== null?
    Center(child: CircularProgressIndicator(),)
      :
    ListView.builder(
      itemCount: PendingMob.moblist.length,
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
            PendingMob.moblist[i].mname,
            style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold),
          ),
          onTap: () {
            DB_Mob a;
            setState(() {
            a = PendingMob.moblist[i];
            });

            print("${a.mname}");
            Navigator.push(context, MaterialPageRoute(builder: (context) => MobDetail(selectedmob: a,),));
          }
        ),

        Divider(
          color: Colors.blue,
          height: 15,
          ),
      ],
    ) ,
  );}
}
