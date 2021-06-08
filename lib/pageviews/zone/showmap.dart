import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mob_admin_panel/classes/db_emp.dart';
import 'package:mob_admin_panel/classes/db_zone.dart';
import 'package:mob_admin_panel/components/curvedbar.dart';
import 'package:mob_admin_panel/components/toast.dart';
import 'package:mob_admin_panel/components/urlstring.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as con;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShowMap extends StatefulWidget {
  @override
  _ShowMapState createState() => _ShowMapState();
}

class _ShowMapState extends State<ShowMap> {
  bool press = false;

  //===========================================MAP Work Start=======================================================
  List<DB_Emp> emplist;//new List<DB_Emp>() ;
  String selectedEmp;
  TextEditingController txt_con = TextEditingController(text: '');
  int sliderRating = 1;

  Completer<GoogleMapController> mapController = Completer();
  static const LatLng center = const LatLng(33.6844, 73.0479);
  final Set<Marker> marker = {};
  final Set<Circle> circles = {};
  double lat, long;

  LatLng lastMapPosition = center;
  MapType currentMapType = MapType.normal;

  static final CameraPosition position = CameraPosition(
      bearing: 192.833,
      target: LatLng(33.6844, 73.0479),
      tilt: 59.440,
      zoom: 11.0);

  Future<void> goToPositone1() async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
  }

  onCameraMove(CameraPosition position) {
    lastMapPosition = position.target;
  }

  onMapTypeButtonPressed() {
    setState(() {
      currentMapType =
      currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  Widget button(Function function, IconData icon) {
    return FloatingActionButton(
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(
        icon,
        size: 36.0,
      ),
    );
  }

  onAddMarkerButtonPressed() {
    setState(() {
      marker.add(Marker(
        markerId: MarkerId(lastMapPosition.toString()),
        position: lastMapPosition,
        infoWindow: InfoWindow(
          title: '',
          snippet: '',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  MyMarker(double long, double lat) {
    setState(() {
      marker.add(Marker(
          markerId: MarkerId('Presses Marker'),
          position: LatLng(lat, long),
          infoWindow: InfoWindow(
            title: 'marker',
          ),
          icon: BitmapDescriptor.defaultMarker));
    });
  }

  MyCircle(double long, double lat) {
    setState(() {
      circles.add(Circle(
          circleId: CircleId('presses circle'),
          fillColor: Colors.red.withOpacity(0.3),
          center: LatLng(lat, long),
          visible: true,
          radius: 1000 * sliderRating.toDouble(),
          strokeColor: Colors.red,
          strokeWidth: 1));
    });
  }

  getemp() async {
    var res =await  http.get(Uri.parse(UrlString.url+'Employee/getemp'));
    if(res.statusCode == 200)
    {
      setState(() {
        Iterable list = con.json.decode(res.body);
        emplist = list.map((e) => DB_Emp.fromJson(e)).toList();
        MyToast.showToast(emplist.toString());
      });
    }
    else{
      setState(() {
        emplist = null;
      });
      MyToast.showToast('No Employee available for new zone');
      Navigator.pop(context);
    }
  }

  Widget map() {
    return Stack(
      //overflow: Overflow.visible,
      children: [
        GoogleMap(
          onTap: (LatLng) {
            setState(() {
              long = LatLng.longitude;
              lat = LatLng.latitude;
              MyMarker(long, lat);
              MyCircle(long, lat);
            });
          },
          onMapCreated: onMapCreated,
          initialCameraPosition: CameraPosition(target: center, zoom: 11.0),
          mapType: currentMapType,
          markers: marker,
          onCameraMove: onCameraMove,
          circles: circles,
          myLocationButtonEnabled: true,
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 50, right: 50),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(50)
                    ),
                    child: TextField(
                      onTap: (){
                        setState(() {
                          press=true;
                        });
                      },
                      onSubmitted: (v){
                        setState(() {
                          press = false;
                        });
                      },
                      style: TextStyle(
                        color: Colors.white,//Color.fromRGBO(66, 165, 255, 1),
                      ),
                      controller: txt_con,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                          labelText: " Name",
                          labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2
                              )
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2
                              )
                          )
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 390//press?50:390,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50, right: 50),
                  child: Slider(
                    min: 1,
                    max: 5,
                    value: sliderRating.toDouble(),
                    activeColor: Colors.blue,
                    inactiveColor: Colors.blueGrey,
                    label: "${sliderRating.toInt()} km",
                    divisions: 4,
                    onChanged: (newRating){
                      setState(() {
                        sliderRating = newRating.toInt();
                        if(lat!=null)
                          MyCircle(long, lat);
                        print(sliderRating.toString());
                      });
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(right: 50, left: 60),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(50)
                    ),
                    padding: EdgeInsets.only(left: 5),
                    child: DropdownButton(
                      value: selectedEmp,
                      //isExpanded: true,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      focusColor: Colors.blue,
                      dropdownColor: Colors.blue,
                      iconSize: 20,
                      hint: Text("Select Employee for zone", style: TextStyle(color: Colors.white),),
                      onChanged: (v){
                        setState(() {
                          selectedEmp = v;
                          print('${selectedEmp}');
                        });
                      },
                      icon:  Icon(Icons.arrow_drop_down, color: Colors.white,),
                      items: emplist.map((va){
                        return DropdownMenuItem(
                          value: va.email,
                          child: Text(va.email),
                        );
                      }
                      ).toList(),
                    ),
                  ) ,
                ),
                ElevatedButton(

                    onPressed: () async {
                      var response = await http.post(Uri.parse(
                              UrlString.url+'Zones/postzone'),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                          body: con.jsonEncode(<String, dynamic>{
                            "zlatitude": lat,
                            "zlongitude": long,
                            "zname": txt_con.text,
                            "zflag": 1,
                            "km":sliderRating,
                            "employee":selectedEmp
                          }));
                      if (response.statusCode == 200)
                        {
                          setState(() {
                            emplist = null;
                          });
                          //MyToast.showToast("===========status code ok  ${selectedEmp}");
                          Navigator.pop(context);
                        }
                      else{
                        MyToast.showToast(response.body);
                      }

                    },
                    child: Text("Add"))
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              children: [
                SizedBox(
                  height: 450//press?100:450,
                ),
                button(onMapTypeButtonPressed, Icons.map),
                // SizedBox(height: 16,) ,
                // button(onAddMarkerButtonPressed, Icons.add_location),
                SizedBox(
                  height: 16,
                ),
                button(goToPositone1, Icons.location_searching),
              ],
            ),
          ),
        ),
      ],
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getemp();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add Zone"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white,),
          onPressed: ()=>Navigator.pop(context),
          color: Colors.white,
        ),
      ),
      body: emplist==null? Center(child: CircularProgressIndicator(),):map(),
      bottomNavigationBar: CurvedBar(),
    );
  }
}

