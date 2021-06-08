import 'dart:async';

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

class MobDetail extends StatefulWidget {
  final DB_Mob selectedmob ;
  const MobDetail({Key key, this.selectedmob}) : super(key: key);

  @override
  _MobDetailState createState() => _MobDetailState(selectedmob: selectedmob);
}

class _MobDetailState extends State<MobDetail> {

  final DB_Mob selectedmob;
  _MobDetailState({this.selectedmob});

  //======custom markers==========
  BitmapDescriptor startingmarker;
  BitmapDescriptor currentmarker;
  BitmapDescriptor blackmarker;
  BitmapDescriptor redflag;

  int i =0;
  List<DB_ArielShot> shotlist ;
  List<DB_Zone> zone;

  getshots() async{
    int mid = selectedmob.mid;
    var res = await http.get(Uri.parse(UrlString.url+'picture/Getpicofmob?mid=$mid'));
    if(res.statusCode == 200) {

      setState(() {
        Iterable list = con.json.decode(res.body);
        shotlist = list.map((e) => DB_ArielShot.fromJson(e)).toList();
      });

      int i = 0;
      for( i; i<shotlist.length; i++) {
        onAddMarkerButtonPressed(
          shotlist[i].platitude,
          shotlist[i].plongitude,
          shotlist[i].pdatetime,
          shotlist[i].speed,
          shotlist[i].pname,
          i==0?startingmarker: i==shotlist.length-1? currentmarker : blackmarker,
        );
      }

      double lat = shotlist[i-1].platitude, lon = shotlist[i-1].plongitude;
      var res1 = await http.get(Uri.parse(UrlString.url+'picture/GetDistance?lat=$lat&lon=$lon'));
      if(res1.statusCode == 200) {
        setState(() {
          Iterable list = con.json.decode(res1.body);
          zone = list.map((e) => DB_Zone.fromJson(e)).toList();
        });

       for(int j = 0; j<zone.length; j++) {
         MyMarker(zone[j].zlong, zone[j].zlat, zone[j].zid, CustomMarker.redflag);
         MyCircle(zone[j].zlong, zone[j].zlat, zone[j].km);
       }
      }
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

  onAddMarkerButtonPressed(double lat, double long, DateTime time, String speed, String id, BitmapDescriptor mark) {
    setState(() {
          marker.add(Marker(
              markerId: MarkerId(id),
              position: LatLng(lat,long),
              infoWindow: InfoWindow(
                title: '{$time}',
                snippet: '${speed}',
              ),
              icon: mark
          ));
    });
  }

  MyMarker(double long, double lat,int id, BitmapDescriptor mark) {
    setState(() {
      marker.add(Marker(
          markerId: MarkerId(id.toString()),
          position: LatLng(lat, long),
          infoWindow: InfoWindow(
            title: '',
          ),
          icon: mark == null?BitmapDescriptor.defaultMarker:mark
      ));
    });
  }

  MyCircle(double long, double lat, int km) {
    setState(() {
      circles.add(Circle(
          circleId: CircleId('presses circle'),
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

    if(widget.selectedmob.mflag == 0) {
        MyToast.showToast("This Mob is not start yet!");
        Navigator.pop(context);
      }
    super.initState();
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1),
        'asset/icons/radar.png').then((onValue) {
      setState(() {
        currentmarker=onValue;
      });
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 5),
        'asset/icons/marker1.png').then((onValue) {
      setState(() {
        startingmarker = onValue;
      });
    });

    //BitmapDescriptor.f
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1),
        'asset/icons/black.png').then((onValue) {
      setState(() {
        blackmarker = onValue;
      });
    });

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 5),
      'asset/icons/marker2.png').then((value) {
        setState(() {
          redflag = value;
        });
    });
    getshots();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${selectedmob.mname}'),
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
