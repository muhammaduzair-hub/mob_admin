import 'dart:async';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:mob_admin_panel/classes/db_emp.dart';
import 'package:mob_admin_panel/classes/db_zone.dart';
import 'package:mob_admin_panel/components/curvedbar.dart';
import 'package:mob_admin_panel/components/toast.dart';
import 'package:mob_admin_panel/components/urlstring.dart';
import 'package:mob_admin_panel/pageviews/zone/showdetail.dart';
import 'file:///G:/FYP/mob_admin_panel/lib/pageviews/zone/showmap.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as con;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ZoneList extends StatefulWidget {
  @override
  _ZoneListState createState() => _ZoneListState();
}

class _ZoneListState extends State<ZoneList> {
  //================================================bottom sheet===================================================
  bool ifsliderratingchange = false;
  String selectedEmp ;
  List<DB_Emp> emplist;
  bool checkupdatezone; //when we update zone we check status code through this
  int sliderRating=null ;//, zoneRating=1;


  bottomsheet(context, DB_Zone selectedzone){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext){
          return Wrap(
            children: [

// ====================================slider chuss==================
//             Padding(
//               padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
//               child: Row(
//                 children: [
//                   Text("Sensitive Area:"+sliderRating.toString()),
//                   IconButton(
//                       icon: Icon(Icons.add),
//                       onPressed: (){
//                         setState(() {
//                           if(sliderRating<5)
//                             sliderRating += 1;
//                         });
//                       }
//                   ),
//                   IconButton(
//                       icon: Icon(Icons.minimize),
//                       onPressed: (){
//                         setState(() {
//                           if(sliderRating>1)
//                             sliderRating -= 1;
//                         });
//                       }
//                   ),
//                 ],
//               ),
//             ),
//=====================================slider========================
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                child: Slider(
                    value: sliderRating==null?1:sliderRating.toDouble(),
                    onChanged: (n){
                      setState(() {
                        sliderRating = n.toInt();
                        //ifsliderratingchange = true;
                        print("$sliderRating");
                      });
                    },
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: "${sliderRating.toString()} km",
                ),
              ),
//======================================dropdown=====================
              Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 30),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: EdgeInsets.only(left: 5),
                  child: DropdownButton(
                    value: selectedEmp,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white,),
                    hint: Text("Select Employee for zone                ", style: TextStyle(color: Colors.white),),
                    items: emplist.length!=0?
                        emplist.map((e){
                          return DropdownMenuItem(
                            value: e.email,
                            child: Text(e.email),
                          );
                        }).toList()
                    :
                        null,
                    onChanged: (v){
                      setState(() {
                        selectedEmp = v;
                        print("${selectedEmp}");
                      });
                    },
                  ),
                ) ,
              ),
//=======================================buttons=====================
              Padding(
                padding: EdgeInsets.fromLTRB(40, 0, 40, 10),
                child: Center(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: ElevatedButton(
                          child: Text("Update", style: TextStyle(color: Colors.white),),
                          onPressed: (){
                            setState(() {
                              //sliderRating = selectedzone.km;
                            });
                            updatezone(selectedzone);
                          },
                        ),
                      ),

                      Padding(padding: EdgeInsets.all(20)),

                      ElevatedButton(
                          child: Text("View Detail", style: TextStyle(color: Colors.white),),
                          // onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => ShowDetail(selectedzone: selectedzone,),)),
                          onPressed: (){
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ShowDetail(selectedzone: selectedzone,),));
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

  getemp() async {
    var res =await  http.get(Uri.parse(UrlString.url+'Employee/getemp'));
    if(res.statusCode == 200)
    {
      setState(() {
        Iterable list = con.json.decode(res.body);
        emplist = list.map((e) => DB_Emp.fromJson(e)).toList();
        print(emplist);
      });
    }
    else{
      setState(() {
        //emplist = null;
      });
    }
  }

  updatezone(DB_Zone selectedzone) async{
    print('slider rating:${sliderRating.toString()}');
    var res = await http.put(Uri.parse(UrlString.url+'Zones/updatezone'),
    headers: <String, String>{
      'Content-Type':
      'application/json; charset=UTF-8',
    },
      body: con.jsonEncode(<String, dynamic>{
        "zid": selectedzone.zid,
        "employee": selectedEmp==null?'':selectedEmp,
        "km": sliderRating//ifsliderratingchange==true ? sliderRating : null,
      }));
    if(res.statusCode==200)
      setState(() {
        print("done");
        checkupdatezone = true;
        selectedEmp = null;
        sliderRating = null;
        ifsliderratingchange = false;
        getemp();
        Navigator.pop(context);
      });
  }
  //===================================================List of Zones Work===========================================
  List<DB_Zone> zonelist;

  Widget listview(){
    return zonelist == null
        ?
    Center(child: CircularProgressIndicator(),)
        :
    new ListView.builder(
      itemCount: zonelist.length,
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
            //contentPadding: EdgeInsets.symmetric(vertical: 30),
            title: Text(
              zonelist[i].zname,
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              zonelist[i].emp,
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
            trailing: ToggleSwitch(
              minWidth: 40.0,
              initialLabelIndex: zonelist[i].flag == 1 ? 0 : 1,
              cornerRadius: 20.0,
              activeBgColor: Colors.blue,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.white,
              inactiveFgColor: Colors.blue[300],
              labels: ['', ''],
              icons: [
                FontAwesomeIcons.check,
                FontAwesomeIcons.times
              ],
              onToggle: (index) async {
                var res =await http.put(
                    Uri.parse(
                        UrlString.url+'Zones/updateFlag'),
                    headers: <String, String>{
                      'Content-Type':
                      'application/json; charset=UTF-8',
                    },
                    body: con.jsonEncode(<String, dynamic>{
                      "zid": zonelist[i].zid,
                      "zlatitude": 33.3,
                      "zlongitude": 33.3,
                      "zname": "zone a",
                      "zflag": index == 0 ? 1 : 0
                    }));
                // if(res.statusCode == 200)
                //   MyToast.showToast("Flag Updated! ");
              },
            ),
            onTap: (){
              setState(() {
               //selectedEmp = zonelist[i].emp;
                sliderRating = zonelist[i].km;
              });
              bottomsheet(context, zonelist[i]);

            },
          ),
          new Divider(
            height: 15.0,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
  getZone() async {
    var response = await http.get(
        Uri.parse(UrlString.url+'Zones/allzone'));
    if (response.statusCode == 200) {
      setState(() {
        Iterable list = con.json.decode(response.body);
        zonelist = list.map((e) => DB_Zone.fromJson(e)).toList();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getZone();
    getemp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.add, color: Colors.transparent,),
        title: Text("Zones"),
        centerTitle: true,
        actions: [
          IconButton(
            icon:Icon(Icons.refresh, color: Colors.white,size: 20,),
            onPressed: ()=>getZone(),

          ),
        ],
      ),
      bottomNavigationBar: CurvedBar(),
      body: listview(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, 'add_zone');
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

}
