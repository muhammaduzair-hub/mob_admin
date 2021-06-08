import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mob_admin_panel/classes/db_devices.dart';
import 'package:http/http.dart'as http;
import 'dart:convert' as con;
import 'package:mob_admin_panel/components/colors.dart';
import 'package:mob_admin_panel/components/curvedbar.dart';
import 'package:mob_admin_panel/components/toast.dart';
import 'package:mob_admin_panel/components/urlstring.dart';

class DevicesList extends StatefulWidget {
  static String title = "Devices";
  @override
  _DevicesListState createState() => _DevicesListState();
}

class _DevicesListState extends State<DevicesList> {
  List<DB_Devices> deviceslist ;//new List<DB_Devices>();


  Widget listview(){
    return deviceslist.length==0
        ?
    Center(child: Text(
      "NO Devices",
      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
    ),)
        :
    ListView.builder(
      itemCount: deviceslist.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, i) => new Column(
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
              deviceslist[i].dname,
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              deviceslist[i].flag.toString(),
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
            onTap: deviceslist[i].flag == 1
                ?
                ()=>showDialog(
                    context: context,
                    builder: (_)=>AlertDialog(
                      title: Text("Dispose Device", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20, color: Colors.white),),
                      content: Text("You want to dispose this device", style: TextStyle(fontSize: 16, color: Colors.white)),
                      backgroundColor: Colors.blue,
                      elevation: 2.0,
                      buttonPadding: EdgeInsets.symmetric(horizontal: 15),
                      actions: [
                        ElevatedButton(
                          child: Text('Yes', style: TextStyle(fontSize: 16, color: Colors.white)),
                          onPressed: (){
                            disposeDeviece(deviceslist[i].did);
                            getDevices();
                            Navigator.pop(context);
                          },
                        ),
                        ElevatedButton(
                          child: Text('No', style: TextStyle(fontSize: 16, color: Colors.white)),
                          onPressed: (){
                            //Navigator.of(context).pop();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  barrierDismissible: false,
                )
                :
            ()=>MyToast.showToast("You can't dispose it\nDevice is assign with a mob!"),

          ),
          new Divider(
            height: 15.0,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }


  getDevices() async {
    var res =await http.get(
        Uri.parse(UrlString.url+"Devices/getall"));
    if(res.statusCode == 200){
      setState(() {
        print(res.body);
        Iterable list = con.json.decode(res.body);
        print(list);
        deviceslist = list.map((e) => DB_Devices.fromJson(e)).toList();
        print("Status code is 200& ${deviceslist.length}");
      });
    }
    else {
      setState(() {
        deviceslist = null;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: deviceslist == null?
          Center(child: CircularProgressIndicator(),)
          :listview(),
      bottomNavigationBar: CurvedBar(),
      appBar: AppBar(
        leading: Icon(Icons.add, color: Colors.transparent,),
        title: Text("Devices"),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: Colors.white,),
              onPressed: ()=>getDevices(),
            iconSize: 20,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        setState(() {

          MyColors.myForeColor = Colors.blue;
          MyColors.myBackColor = Colors.white;
          MyColors.myButtonColor = Colors.green;

          });
          Navigator.pushNamed(context, 'add_device');
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

  disposeDeviece(int zid) async{
    var res = await http.delete(Uri.parse(UrlString.url+'/Devices/delete?$zid'));
    if(res.statusCode == 200)
      MyToast.showToast("Device dispose successfully");
    else
      MyToast.showToast(res.body);
  }
}
