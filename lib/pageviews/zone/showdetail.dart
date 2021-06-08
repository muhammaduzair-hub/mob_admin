import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mob_admin_panel/classes/db_arielshot.dart';
import 'package:mob_admin_panel/classes/db_emp.dart';
import 'package:mob_admin_panel/classes/db_mob.dart';
import 'package:mob_admin_panel/classes/db_zone.dart';
import 'package:mob_admin_panel/components/curvedbar.dart';
import 'package:mob_admin_panel/components/custommarkers.dart';
import 'package:mob_admin_panel/components/toast.dart';
import 'package:mob_admin_panel/components/urlstring.dart';
import 'package:mob_admin_panel/pageviews/home/loginperson.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as con;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShowDetail extends StatefulWidget {
  final DB_Zone selectedzone;
  const ShowDetail({Key key, this.selectedzone}) : super(key: key); 
  
  @override
  _ShowDetailState createState() => _ShowDetailState(selectedzone);
}

class _ShowDetailState extends State<ShowDetail> {
  final DB_Zone selectedzone;
  _ShowDetailState(this.selectedzone);
  
  //===========================================MAP Work Start=======================================================
  List<DB_ArielShot> mobinzone = null;
  double lat, long;
  //======custom markers==========
  BitmapDescriptor startingmarker;
  BitmapDescriptor currentmarker;
  BitmapDescriptor blackmarker;
  BitmapDescriptor redflag;

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

  onAddMarkerButtonPressed(double lat, double long, DateTime time, int qty, String id,String mname, BitmapDescriptor mark, String speed) {
    setState(() {
      marker.add(Marker(
          markerId: MarkerId(id),
          position: LatLng(lat,long),
          infoWindow: InfoWindow(
            title: mname,
            snippet: '${speed}',
          ),
          icon: mark == null?BitmapDescriptor.defaultMarker:mark,
      ));
    });
  }

  MyMarker(double long, double lat, BitmapDescriptor mark) {
    setState(() {
      marker.add(Marker(
          markerId: MarkerId('Presses Marker'),
          position: LatLng(lat, long),
          infoWindow: InfoWindow(
            title: '',
          ),
          icon: mark == null?BitmapDescriptor.defaultMarker:mark,
      ));
    });
  }

  MyCircle(double long, double lat, double rad) {
    setState(() {
      circles.add(Circle(
          circleId: CircleId('presses circle'),
          fillColor: Colors.red.withOpacity(0.3),
          center: LatLng(lat, long),
          visible: true,
          radius: 1000 * rad,
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
  
  getzonedetail() async{
    MyMarker(selectedzone.zlong, selectedzone.zlat, CustomMarker.redflag);
    MyCircle(selectedzone.zlong, selectedzone.zlat, selectedzone.km.toDouble());
    if(selectedzone.flag == 0){
    }
    else {
      int zid= selectedzone.zid;
      var res = await http.get(Uri.parse(UrlString.url+'picture/Zonedetail?zid=$zid'));
      if(res.statusCode == 200){
        Iterable list = con.json.decode(res.body);
        mobinzone = list.map((e) => DB_ArielShot.fromJson(e)).toList();

        for(int i = 0; i<mobinzone.length; i++){

          int mmid = mobinzone[i].mid;
          var name =await http.get(Uri.parse(UrlString.url+'Mob/getname?mid=$mmid'));
          if(name.statusCode == 200) {
            DB_Mob mname = DB_Mob.fromJson(con.jsonDecode(name.body));

            onAddMarkerButtonPressed(
              mobinzone[i].platitude,
              mobinzone[i].plongitude,
              mobinzone[i].pdatetime,
              mobinzone[i].pmobquantity,
              mobinzone[i].pname,
              mname.mname,
              currentmarker ,
              mobinzone[i].speed
            );
          }
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    if(widget.selectedzone.flag == 0) {
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
        ImageConfiguration(devicePixelRatio: 3),
        'asset/icons/redflag.png').then((value) {
      setState(() {
        redflag = value;
      });
    });

    getzonedetail();

  }

  @override
  Widget build(BuildContext context) {

    String zonename;
    setState(() {
      zonename = selectedzone.zname;
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("$zonename Zone Detail"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white,),
          onPressed: ()=>Navigator.pop(context),
          color: Colors.white,
        ),
      ),
      body: map(),
      bottomNavigationBar: LoginPerson.loginuser == null?CurvedBar():null,
    );
  }
}

