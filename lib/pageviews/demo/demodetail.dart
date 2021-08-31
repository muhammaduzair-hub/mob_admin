import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mob_admin_panel/classes/db_arielshot.dart';
import 'package:mob_admin_panel/classes/db_mob.dart';
import 'package:mob_admin_panel/classes/db_zone.dart';
import 'package:mob_admin_panel/components/curvedbar.dart';

import 'package:http/http.dart' as http;
import 'package:mob_admin_panel/components/custommarkers.dart';
import 'dart:convert' as con;

import 'package:mob_admin_panel/components/toast.dart';
import 'package:mob_admin_panel/components/urlstring.dart';

import 'package:geolocator/geolocator.dart';
import 'package:mob_admin_panel/pageviews/demo/myvariables.dart';

class DemoDetail extends StatefulWidget {
  @override
  _DemoDetailState createState() => _DemoDetailState();
}

class _DemoDetailState extends State<DemoDetail> {

  List<DB_Zone> threadedzone = new List<DB_Zone>();
  int shotlistlenght=0;

  //======custom markers==========
  BitmapDescriptor startingmarker;
  BitmapDescriptor currentmarker;
  BitmapDescriptor blackmarker;
  BitmapDescriptor redflag;

  int i =0;

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

  onAddMarkerButtonPressed(double lat, double long, DateTime time, String speed,String id, String qty, BitmapDescriptor mark) {
    setState(() {
      marker.add(Marker(
          markerId: MarkerId(id),
          position: LatLng(lat,long),
          infoWindow: InfoWindow(
            title: 'Quantity:$qty',
            snippet: 'Speed:${speed},Time:${time}',
          ),
          icon: mark
      ));
    });
  }

  getshots() async{

      int i = 0;
      for(i ; i<MyVariables.DemoShotList.length; i++) {
        //shotlistlenght+=1;
        await Future.delayed(Duration(seconds: 2), () {

          onAddMarkerButtonPressed(
              MyVariables.DemoShotList[i].platitude,
              MyVariables.DemoShotList[i].plongitude,
              MyVariables.DemoShotList[i].pdatetime,
              MyVariables.DemoShotList[i].speed,
              MyVariables.DemoShotList[i].picno.toString(),
              "",
              i==MyVariables.DemoShotList.length-1?currentmarker: blackmarker);


          //check the zones
        for(int j = 0; j<MyVariables.DemoZoneList.length; j++) {
          String previous_status='';
          //MyToast.showToast('j$j');

          var dist = distance(
              MyVariables.DemoShotList[i].platitude,
              MyVariables.DemoShotList[i].plongitude,
              MyVariables.DemoZoneList[j].zlat,
              MyVariables.DemoZoneList[j].zlong, "K");

          var speed = MyVariables.DemoShotList[i].speed.split(' ');
          var time = (double.parse(dist)-MyVariables.DemoZoneList[j].km.toDouble()) <= 0
              ? 0
              :
          (double.parse(dist)-MyVariables.DemoZoneList[j].km.toDouble())/double.parse(speed[0]);

          setState(() {
            MyVariables.DemoZoneList[j].isshow==null?false:MyVariables.DemoZoneList[j].isshow;
          });
          //now check is this zone is already isshow then we will updates its information
          if(MyVariables.DemoZoneList[j].isshow){
            if(time>MyVariables.DemoZoneList[j].time){
              setState(() {
                MyVariables.DemoZoneList[j].distancekm = dist;
                MyVariables.DemoZoneList[j].time=time;
                MyVariables.DemoZoneList[j].status = "Away";
              });
            }

            Marker _marker = marker.firstWhere((c) => c.markerId.value == MyVariables.DemoZoneList[j].zid.toString() ,orElse: () => null);
            Circle _circle = circles.firstWhere((c) => c.circleId.value == MyVariables.DemoZoneList[j].zid.toString() ,orElse: () => null);
            setState(() {
              marker.remove(_marker);
              circles.remove(_circle);
            });
          }

          //if zone is near to mob
          if(double.parse(dist) <= MyVariables.DemoZoneList[j].km+3){
            previous_status = "Toward";
            DB_Zone newthreadedzone = new DB_Zone(
                zid: MyVariables.DemoZoneList[j].zid+100,
                zlat: MyVariables.DemoZoneList[j].zlat,
                zlong: MyVariables.DemoZoneList[j].zlong,
                km: MyVariables.DemoZoneList[j].km,
                zname: MyVariables.DemoZoneList[j].zname,
                status:"Toward",time:time);

            setState(() {
              threadedzone.add(newthreadedzone);
              MyVariables.DemoZoneList[j].isshow = true;
              MyVariables.DemoZoneList[j].time = time;
              MyVariables.DemoZoneList[j].status = previous_status;
            });
          }

          if(MyVariables.DemoZoneList[j].isshow) {
            var newthreadedzone = MyVariables.DemoZoneList[j];
            MyMarker( newthreadedzone.zlong,  newthreadedzone.zlat, newthreadedzone.zid, CustomMarker.redflag, '${newthreadedzone.time} minutes', newthreadedzone.status);
            MyCircle( newthreadedzone.zlong,  newthreadedzone.zlat,  newthreadedzone.km, newthreadedzone.zid.toString());
          }
        }
        });
        //MyToast.showToast('threadzone${threadedzone.length}');
      }
  }




  String selectedEmp;
  double lat, long;
  TextEditingController txt_con = TextEditingController(text: '');
  int sliderRating = 1;

  Completer<GoogleMapController> mapController = Completer();
  static const LatLng center = const LatLng(33.6844, 73.0479);
  final Set<Marker> marker = {};
  final Set<Circle> circles = {};

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

  MyMarker(double long, double lat,int id, BitmapDescriptor mark, var speed,String Status) {
    setState(() {
      marker.add(Marker(
          markerId: MarkerId(id.toString()),
          position: LatLng(lat, long),
          infoWindow: InfoWindow(
            title: speed.toString(),
            snippet: Status
          ),
          icon: mark == null?BitmapDescriptor.defaultMarker:mark
      ));
    });
  }

  MyCircle(double long, double lat, int km, String id) {
    setState(() {
      circles.add(Circle(
          circleId: CircleId(id),
          fillColor: Colors.red.withOpacity(0.3),
          center: LatLng(lat, long),
          visible: true,
          radius: 1000 * km.toDouble(),
          strokeColor: Colors.red,
          strokeWidth: 1));
    });
  }

  Widget map() {
    return Stack(
      //overflow: Overflow.visible,
      children: [
        GoogleMap(
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
            alignment: Alignment.bottomLeft,
            child: Column(
              children: [
                SizedBox(
                  height: 450,
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
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2),
        'asset/icons/radar.png').then((onValue) {
      setState(() {
        currentmarker=onValue;
      });
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2),
        'asset/icons/startlocation.png').then((onValue) {
      setState(() {
        startingmarker = onValue;
      });
    });

    //BitmapDescriptor.f
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2),
        'asset/icons/black.png').then((onValue) {
      setState(() {
        blackmarker = onValue;
      });
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 5),
        'asset/icons/redflag.png').then((value) {
      setState(() {
        redflag = value;
      });
    });
    Future.delayed(Duration(seconds: 5), () {
      getshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(''),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white,),
            onPressed: (){

              for(int i = 0; i<MyVariables.DemoShotList.length; i++)
              {
                Marker _marker = marker.firstWhere((marker) => marker.markerId.value == MyVariables.DemoShotList[i].picno.toString() ,orElse: () => null);
                setState(() {
                  marker.remove(_marker);
                });
              }
              //getshots();
            },
          )
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp, color: Colors.white,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      bottomNavigationBar: CurvedBar(),
      body: map(),
    );
  }
}
