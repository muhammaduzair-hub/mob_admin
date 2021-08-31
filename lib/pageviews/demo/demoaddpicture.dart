import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:mob_admin_panel/classes/db_arielshot.dart';
import 'package:mob_admin_panel/components/toast.dart';
import 'package:mob_admin_panel/pageviews/demo/demodetail.dart';
import 'dart:convert' as con;

import 'package:mob_admin_panel/pageviews/demo/myvariables.dart';



class DemoAddPicture extends StatefulWidget {


  @override
  _DemoAddPictureState createState() => _DemoAddPictureState();
}

class _DemoAddPictureState extends State<DemoAddPicture> {

  final DateFormat dateFormat =DateFormat('yyyy-MM-dd HH:mm');
  double long,lat;
  DateTime dateTime = DateTime.now();
  String pname,padress;


  Completer<GoogleMapController> mapController = Completer();
  static const LatLng center = const LatLng(33.6844, 73.0479);
  final Set<Marker> marker = {};
  LatLng lastMapPosition = center;
  MapType currentMapType = MapType.normal;

  //===============================================calculating distance between two points==================
  String distance(double lat1, double lon1, double lat2, double lon2, String unit) {
    double theta = lon1 - lon2;
    double dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta));
    dist = acos(dist);
    dist = rad2deg(dist);
    dist = dist * 60 * 1.1515;
    if (unit == 'K') {
      dist = dist * 1.609344;
    } else if (unit == 'N') {
      dist = dist * 0.8684;
    }
    return dist.toStringAsFixed(2);
  }
  double deg2rad(double deg) {
    return (deg * pi / 180.0);
  }
  double rad2deg(double rad) {
    return (rad * 180.0 / pi);
  }
//=================================================end calculating distance================================


  static final CameraPosition position = CameraPosition(
      bearing: 192.833,
      target: LatLng(33.6844, 73.0479),
      tilt: 59.440,
      zoom: 11.0
  );

  Future<void> goToPositone1() async{
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  onMapCreated(GoogleMapController controller){
    mapController.complete(controller);
  }

  onCameraMove(CameraPosition position){
    lastMapPosition = position.target;
  }

  onMapTypeButtonPressed(){
    setState(() {
      currentMapType = currentMapType == MapType.normal? MapType.satellite: MapType.normal;
    });
  }

  Widget button (Function function, IconData icon) {
    return FloatingActionButton(
      onPressed: function,
      materialTapTargetSize:  MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(icon, size: 36.0,),
    );
  }

  onAddMarkerButtonPressed(){
    setState(() {
      marker.add(
          Marker(
            markerId: MarkerId(lastMapPosition.toString()),
            position: lastMapPosition,
            infoWindow: InfoWindow(
              title:'',
              snippet: '',
            ),
            icon: BitmapDescriptor.defaultMarker,
          )
      );
    });
  }

  MyMarker(double long, double lat){
    setState(() {
      marker.add(
          Marker(
              markerId: MarkerId('Presses Marker'),
              position: LatLng(lat,long),
              infoWindow: InfoWindow(
                title: 'marker',
              ),
              icon: BitmapDescriptor.defaultMarker
          )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: IconButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => DemoDetail(),));
          },
          icon: Icon(Icons.arrow_forward, color: Colors.white ,),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Add Markers"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined, color: Colors.white, size: 20,),
          onPressed: ()=>Navigator.pop(context),


        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onTap: (LatLng){
              setState(() {
                long = LatLng.longitude;
                lat = LatLng.latitude;
                MyMarker(long, lat);
              });
            },
            onMapCreated: onMapCreated,
            initialCameraPosition: CameraPosition(
                target: center,
                zoom: 11.0
            ),
            mapType: currentMapType,
            markers: marker,
            onCameraMove: onCameraMove,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.blue
                        ),
                        child:IconButton(
                          icon:Icon(Icons.minimize, color: Colors.white,) ,
                          onPressed: (){
                            setState(() {
                              dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.minute-1);
                            });
                          },
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 8)),
                      GestureDetector(
                        onTap: () async {
                          DateTime dates = DateTime.now();
                          TimeOfDay time = TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
                          await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2025),
                          ).then((data){
                            dates = data;}
                          );

                          time = await showTimePicker(context: context,
                              initialTime: TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute));

                          setState(() {
                            dateTime = DateTime(dates.year, dates.month, dates.day, time.hour, time.minute);
                          });

                        },
                        child: Container(

                          width: 250,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.blue
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 45, vertical: 10),
                            child: Row(
                                children:[
                                  Text('Date: ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                  Text(dateFormat.format(dateTime), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ]
                            ),
                          ),

                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 8)),
                      Container(
                        width: 40,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.blue
                        ),
                        child:IconButton(
                          icon:Icon(Icons.add, color: Colors.white,) ,
                          onPressed: (){
                            setState(() {
                              dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.minute+1);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 550,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: Container(
                    width: 230,
                    child: ElevatedButton(
                        onPressed: (){
                          addMarker();
                        },
                        style: ElevatedButton.styleFrom(
                          onPrimary: Colors.blue,
                          primary: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text("Add Marker",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),)
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                children: [
                  SizedBox(height: 500,),
                  button(onMapTypeButtonPressed, Icons.map),
                  // SizedBox(height: 16,) ,
                  // button(onAddMarkerButtonPressed, Icons.add_location),
                  SizedBox(height: 16,),
                  button(goToPositone1, Icons.location_searching),

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

 addMarker() {
    if(MyVariables.DemoShotList.length==0) {
      DB_ArielShot newMarker = new DB_ArielShot(picno: 0,speed: "0 km/n", platitude: lat, plongitude: long,pdatetime: dateTime);
      setState(() {
        MyVariables.DemoShotList.add(newMarker);
        long = lat = null;
      });
      MyToast.showToast("new marker is added\n${MyVariables.DemoShotList.length}");
    }
    else{
      int i;
      for(i =0; i<MyVariables.DemoShotList.length; i++){
        if(MyVariables.DemoShotList[i].plongitude == long && MyVariables.DemoShotList[i].platitude== lat){
          MyToast.showToast("Same location marker is already in a list");
          break;
        }
        print("I am in");
        if(MyVariables.DemoShotList[i].pdatetime == dateTime){
          MyToast.showToast("marker with Same Time is already in a list");
          break;
        }

      }
      if(i == MyVariables.DemoShotList.length){
        DB_ArielShot previousmarker = MyVariables.DemoShotList[MyVariables.DemoShotList.length-1];
        var dist = distance(previousmarker.platitude, previousmarker.plongitude,lat, long, "K");//await Geolocator.distanceBetween(shotlist[i-1].platitude, shotlist[i-1].plongitude,zone[j].zlat, zone[j].zlong);
        var time = dateTime.difference(previousmarker.pdatetime).inMinutes  ;
        var speed = double.parse(dist)/time.toDouble();

        DB_ArielShot newMarker = new DB_ArielShot(picno: MyVariables.DemoShotList.length,speed: "${speed} km/n", platitude: lat, plongitude: long,pdatetime: dateTime);
        setState(() {
          MyVariables.DemoShotList.add(newMarker);
          long = lat = null;
        });
        MyToast.showToast("new marker is added\n${MyVariables.DemoShotList.length}");
      }
      else{

      }
    }

 }
}
