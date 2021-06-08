import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mob_admin_panel/classes/db_devices.dart';
import 'package:http/http.dart'as http;
import 'dart:convert' as convert;
import 'package:mob_admin_panel/components/colors.dart';
import 'package:mob_admin_panel/components/curvedbar.dart';
import 'package:mob_admin_panel/components/urlstring.dart';

class AddDevices extends StatefulWidget {
  static String title = "Devices";
  @override
  _AddDevicesState createState() => _AddDevicesState();
}

class _AddDevicesState extends State<AddDevices> {

  TextEditingController con = TextEditingController();

  postMob() async {
    var res = await http.post(
        Uri.parse(UrlString.url+'Devices/postdevice'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, dynamic>{
          "dname": con.text
        })
    );
  }

  Widget addDevices(){
    return ListView(
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
              SizedBox(height: 100,),
              TextField(
                controller: con,
                style: TextStyle(
                  color: Colors.white,//Color.fromRGBO(66, 165, 255, 1),
                ),
                decoration: InputDecoration(
                  labelText: "Device Name",
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
                    Icons.devices , color: Colors.white,
                    //size: 12,
                  ),
                ),

              ),
              SizedBox(height: 50,),
              Container(
                width: 120,
                child: ElevatedButton(
                  child: Text("Add Device",
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
                    postMob();
                    setState(() {
                      MyColors.myForeColor = Colors.white;
                      MyColors.myBackColor = Colors.blue;
                    });
                    Navigator.pop(context);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:addDevices(),
      bottomNavigationBar: CurvedBar(),
      appBar: AppBar(
        title: Text("Add Devices"),
        centerTitle: true,
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: (){
            setState(() {
              MyColors.myForeColor = Colors.white;
              MyColors.myBackColor = Colors.blue;
            });
            Navigator.pop(context);
            },
        ),
      ),
    );
  }

}
