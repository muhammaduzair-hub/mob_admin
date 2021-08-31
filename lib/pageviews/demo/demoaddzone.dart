import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mob_admin_panel/classes/db_emp.dart';
import 'package:mob_admin_panel/classes/db_zone.dart';
import 'package:mob_admin_panel/components/curvedbar.dart';
import 'package:mob_admin_panel/components/toast.dart';
import 'package:mob_admin_panel/components/urlstring.dart';
import 'package:mob_admin_panel/pageviews/demo/demoaddpicture.dart';
import 'package:mob_admin_panel/pageviews/demo/myvariables.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as con;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DemoAddZone extends StatefulWidget {
  @override
  _DemoAddZoneState createState() => _DemoAddZoneState();
}

class _DemoAddZoneState extends State<DemoAddZone> {
  bool press = false;

  //===========================================MAP Work Start=======================================================
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
                  height: press?50:390,
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

                ElevatedButton(
                    onPressed: () async {
                      DB_Zone newzone = new DB_Zone(isshow: false,zname: txt_con.text, km: sliderRating, zlong: long, zlat: lat, zid: MyVariables.DemoZoneList.length,);
                      setState(() {
                        MyVariables.DemoZoneList.add(newzone);
                        txt_con.text = "";
                        lat = long = null;
                        sliderRating = 1;
                      });
                      MyToast.showToast("New zone added\n${MyVariables.DemoZoneList.length}");
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
                  height: press?100:450,
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
      body: map(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: IconButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => DemoAddPicture(),));
          },
          icon: Icon(Icons.arrow_forward, color: Colors.white ,),
        ),
      ),
    );
  }
}

