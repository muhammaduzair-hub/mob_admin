import 'package:flutter/material.dart';
import 'package:mob_admin_panel/classes/db_devices.dart';
import 'package:mob_admin_panel/classes/db_mob.dart';
import 'package:mob_admin_panel/components/urlstring.dart';
import 'package:mob_admin_panel/pageviews/mob/mob.dart';
import 'package:mob_admin_panel/pageviews/mob/mobdetail.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as con;

class ActiveMob extends StatefulWidget {
  static List<DB_Mob> moblist ;
  @override
  _ActiveMobState createState() => _ActiveMobState();
}

class _ActiveMobState extends State<ActiveMob> {

  List<DB_Devices> deviceslist ;
  List<DB_Devices> mobdevices ;
  String selectdevice;

  getAvailableDevices() async{
    var response = await http.get(Uri.parse(UrlString.url+'Devices/getavailable'));
    if(response.statusCode == 200) {
      setState(() {
        Iterable list = con.json.decode(response.body);
        deviceslist = list.map((e) => DB_Devices.fromJson(e)).toList();
        print("${deviceslist.length}");

      });
    }
  }

  getDevicesWithMob() async{
    var response = await http.get(Uri.parse(UrlString.url+'Devices/getdeviceswithmob'));
    if(response.statusCode == 200) {
      setState(() {
        Iterable list = con.json.decode(response.body);
        mobdevices = list.map((e) => DB_Devices.fromJson(e)).toList();
        print("${mobdevices.length}");

      });
    }
  }

  updatemobdevice(DB_Mob selectedmob) async{

    int selectedindex;
    for(int i=0; i<deviceslist.length; i++){
      if(deviceslist[i].dname == selectdevice) {
        selectedindex = deviceslist[i].did;
        break;
      }
    }
    var res = await http.put(
        Uri.parse(UrlString.url+'Mob/updatemob'),
        headers: <String, String>{
          'Content-Type':
          'application/json; charset=UTF-8',
        },
        body: con.jsonEncode(<String, dynamic>{
          "mid": selectedmob.mid,
          "mdevice": selectedindex
        })
    );
    if(res.statusCode == 200) {
        getAvailableDevices();
        getDevicesWithMob();
        setState(() {
          selectdevice = null;
        });
      }
    else
      print("Some issue");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAvailableDevices();
    getDevicesWithMob();
  }



  bottomsheet(context, DB_Mob selectedmob){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext c){
          return Wrap(
            children: [

              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                          color: Colors.white,
                          width: 2
                      )
                  ),
                  padding: EdgeInsets.only(top: 5,left: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.devices, color: Colors.white,),
                      Padding(padding: EdgeInsets.only(left: 15),),
                      DropdownButton(
                        //isExpanded: true,
                        value: selectdevice,
                        //isExpanded: true,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        focusColor: Colors.blue,
                        dropdownColor: Colors.blue,
                        iconSize: 20,
                        hint: Text("Select device for Mob                    ",
                          style: TextStyle(color: Colors.white),
                        ),
                        onChanged: (v){
                          setState(() {
                            selectdevice = v;
                          });
                        },
                        icon:  Icon(Icons.arrow_drop_down, color: Colors.white,),
                        items: deviceslist.length!=0 ? deviceslist.map((va){
                          return DropdownMenuItem(
                            value: va.dname,
                            child: Text(va.dname),
                          );
                        }
                        ).toList(): null,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(40, 0, 40, 20),
                child: Center(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: ElevatedButton(
                          child: Text("Update", style: TextStyle(color: Colors.white),),
                          onPressed: (){
                            updatemobdevice(selectedmob);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(20)),
                      ElevatedButton(
                          child: Text("View Detail", style: TextStyle(color: Colors.white),),
                          // onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => ShowDetail(selectedzone: selectedzone,),)),
                          onPressed: (){
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MobDetail(selectedmob: selectedmob,),));
                          }
                      ),
                    ],
                  ),
                ),

              )
            ],
          );
        }
    );
  }

  Widget getdevicenamefromlist(int did){
    for(int i=0; i<mobdevices.length; i++){
      if(mobdevices[i].did == did)
        return Text(mobdevices[i].dname, style: TextStyle(color: Colors.blue),);
    }
  }

  @override
  Widget build(BuildContext context) {

    return ActiveMob.moblist== null && mobdevices == null?
        Center(child: CircularProgressIndicator(),)
        :
    ListView.builder(
      itemCount: ActiveMob.moblist.length,
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
              ActiveMob.moblist[i].mname,
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              bottomsheet(context, ActiveMob.moblist[i]);
            },
            subtitle: getdevicenamefromlist(ActiveMob.moblist[i].did),
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
