import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mob_admin_panel/classes/db_devices.dart';
import 'package:mob_admin_panel/components/colors.dart';
import 'package:mob_admin_panel/components/curvedbar.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as con;

import 'package:mob_admin_panel/components/toast.dart';
import 'package:mob_admin_panel/components/urlstring.dart';
import 'package:mob_admin_panel/pageviews/mob/activemob.dart';

class AddMob extends StatefulWidget {
  @override
  _AddMobState createState() => _AddMobState();
}

class _AddMobState extends State<AddMob> {

  List<DB_Devices> deviceslist ;
  String selectdevice;
  int selectedindex;
  TextEditingController title_con = TextEditingController();

  getAvailableDevices() async{
    var response = await http.get(Uri.parse(UrlString.url+'Devices/getavailable'));
    if(response.statusCode == 200) {
      setState(() {
        Iterable list = con.json.decode(response.body);
        deviceslist = list.map((e) => DB_Devices.fromJson(e)).toList();
        print("${deviceslist.length}");

      });
      if(deviceslist.length == 0) {
        setState(() {
          MyToast.showToast("No Device is Available");
          MyColors.myForeColor = Colors.white;
          MyColors.myBackColor = Colors.blue;
        });
        Navigator.pop(context);
      }
    }
    else {
      setState(() {
        MyToast.showToast("No Device is Available");
        MyColors.myForeColor = Colors.white;
        MyColors.myBackColor = Colors.blue;
      });
      Navigator.pop(context);
    }
  }

  postMob() async {

    for(int i=0; i<deviceslist.length; i++){
      if(deviceslist[i].dname == selectdevice) {
        selectedindex = deviceslist[i].did;
        break;
      }
    }

    print('${selectedindex}');
    var res = await http.post(
        Uri.parse(UrlString.url+'Mob/postMOb'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: con.jsonEncode(<String, dynamic>{
          "mname": title_con.text,
          "ms_time": null,
          "me_time": null,
          "mdesc": null,
          "mflag": 0,
          "mdevice": selectedindex,
        })
    );
  }

  Widget addMob(){
    return deviceslist == null?
        Center(child: CircularProgressIndicator(),)
    :
    ListView(
      children: [
        SizedBox(height: 50,),
        Padding(
          padding: EdgeInsets.all(30),
          child: Image(
            height: 200,
            image: AssetImage('asset/images/2.png'),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius:  BorderRadius.only(
              topLeft: Radius.circular(60),
              topRight: Radius.circular(60),
            ),
          ),
          height: 500,
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              SizedBox(height: 80,),
              TextField(
                controller: title_con,
                style: TextStyle(
                  color: Colors.white,//Color.fromRGBO(66, 165, 255, 1),
                ),
                decoration: InputDecoration(
                  labelText: "Mob title",
                  labelStyle: TextStyle(
                    color: Colors.white,//Color.fromRGBO(66, 165, 255, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 42,vertical: 20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                        color: Colors.white,//Color.fromRGBO(66, 165, 255, 1),
                        width: 2
                    ),
                  ),
                  focusedBorder:  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  prefixIcon: Icon(
                    Icons.people_alt_outlined , color: Colors.white,
                    //size: 12,
                  ),
                ),

              ),
              SizedBox(height: 20,),
              //===================drop down======================
              Container(
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
                      items: deviceslist.map((va){
                        return DropdownMenuItem(
                          value: va.dname,
                          child: Text(va.dname),
                        );
                      }
                      ).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50,),
              Container(
                width: 120,
                child: ElevatedButton(
                  child: Text("Add MOB",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)
                      ),
                      primary: Colors.white,
                      onPrimary: Colors.white
                  ),
                  onPressed: (){
                    for(int i = 0; i<deviceslist.length; i++)
                    {
                      if(deviceslist[i].dname == selectdevice)
                        setState(() {
                          selectedindex = i;
                        });
                    }
                    print('${selectedindex}');
                    postMob();
                    setState(() {
                      MyColors.myForeColor = Colors.white;
                      MyColors.myBackColor = Colors.blue;
                    });
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'mob');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAvailableDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Add MOB"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white,),
          onPressed: (){
            setState(() {
              MyColors.myForeColor = Colors.white;
              MyColors.myBackColor = Colors.blue;
            });
            Navigator.pop(context);
          },
        ),
      ),
      bottomNavigationBar: CurvedBar(),
      body: addMob(),
    );
  }
}
