import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mob_admin_panel/classes/db_arielshot.dart';
import 'package:mob_admin_panel/classes/db_emp.dart';
import 'package:mob_admin_panel/classes/db_mob.dart';
import 'package:mob_admin_panel/classes/db_zone.dart';
import 'package:mob_admin_panel/classes/db_zonedetail.dart';
import 'package:mob_admin_panel/components/curvedbar.dart';
import 'package:mob_admin_panel/components/custommarkers.dart';
import 'package:mob_admin_panel/components/toast.dart';
import 'package:mob_admin_panel/components/urlstring.dart';
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
  List<DB_ZoneDetail> mobinzone = null;
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

  static CameraPosition position = CameraPosition(
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

  onAddMarkerButtonPressed(double lat, double long, String time, int qty, String id,String mname, BitmapDescriptor mark, String speed){
    setState(() {
      marker.add(Marker(
          markerId: MarkerId(id),
          position: LatLng(lat,long),
          infoWindow: InfoWindow(
            title: '${mname}, ',
            snippet: 'Status:${speed},ReachTime:${time} min',
          ),
          icon: mark,
        onTap: () async{
          await Future.delayed(Duration(seconds: 2), () async {});
          showDialog(
            context: context,
            builder: (_)=> AlertDialog(
              title: Text("Show Mob ${mname}", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20, color: Colors.white),),
              content: Text("Want to see movement?", style: TextStyle(fontSize: 16, color: Colors.white)),
              backgroundColor: Colors.blue,
              elevation: 2.0,
              buttonPadding: EdgeInsets.symmetric(horizontal: 15),
              //shape: CircleBorder(),
              actions: [
                ElevatedButton(
                  child: Text('Yes', style: TextStyle(fontSize: 16, color: Colors.white)),
                  onPressed: () async{
                    Navigator.of(context).pop();
                    for(int i = 0;i<mobinzone.length;i++){
                      Marker _marker = marker.firstWhere((marker) => marker.markerId.value == mobinzone[i].mid.toString() ,orElse: () => null);
                      marker.remove(_marker);
                    }
                    var res = await http.get(Uri.parse(UrlString.url+'picture/Getpicofmob?mid=${id}'));
                    if(res.statusCode == 200) {
                      List<DB_ArielShot> myshotlist;
                      setState(() {
                        Iterable list = con.json.decode(res.body);
                        myshotlist = list.map((e) => DB_ArielShot.fromJson(e)).toList();
                        print(myshotlist.length.toString());
                      });
                      int i = 0;
                      for(i ; i<myshotlist.length; i++) {
                        await Future.delayed(Duration(seconds: 2), () async {

                          onAddMarkerButtonPressed_on(
                              myshotlist[i].platitude,
                              myshotlist[i].plongitude,
                              myshotlist[i].pdatetime,
                              myshotlist[i].speed,
                              myshotlist[i].picno.toString(),
                              myshotlist[i].pmobquantity.toString(),
                              i==myshotlist.length-1?currentmarker: blackmarker
                          );

                          setState(() {
                            position = CameraPosition(
                                bearing: 192.833,
                                target: LatLng(myshotlist[i].platitude, myshotlist[i].plongitude),
                                tilt: 59.440,
                                zoom: 11.0);
                            goToPositone1();
                          });

                        });
                      }
                      await Future.delayed(Duration(seconds: 2), () async {
                        for(int i = 0;i<myshotlist.length;i++){
                          Marker _marker = marker.firstWhere((marker) => marker.markerId.value == myshotlist[i].picno.toString() ,orElse: () => null);
                          marker.remove(_marker);
                        }
                        for(int i = 0; i<mobinzone.length; i++){

                          onAddMarkerButtonPressed(
                            mobinzone[i].mlat,
                            mobinzone[i].mlong,
                            mobinzone[i].reachtime.toString(),
                            mobinzone[i].mqty,
                            mobinzone[i].mid.toString(),
                            mobinzone[i].mobname,
                            currentmarker ,
                            mobinzone[i].mstatus,
                          );
                        }
                      });
                    }
                  },
                ),
                ElevatedButton(
                  child: Text('No', style: TextStyle(fontSize: 16, color: Colors.white)),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );

        }
      ));
       //Marker _marker = marker.firstWhere((marker) => marker.markerId.value == (id).toString() ,orElse: () => null);
       //_marker!=null?MyToast.showToast("OK"):MyToast.showToast("OK");
    });
  }

  onAddMarkerButtonPressed_on(double lat, double long, DateTime time, String speed,String id, String qty, BitmapDescriptor mark) {
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
      var res = await http.get(Uri.parse(UrlString.url+'ZoneDetail/viewzone?id=${zid}'));
      if(res.statusCode == 200){
        Iterable list = con.json.decode(res.body);
        mobinzone = list.map((e) => DB_ZoneDetail.fromJson(e)).toList();

        for(int i = 0; i<mobinzone.length; i++){
          int mmid = mobinzone[i].mid;
          var name =await http.get(Uri.parse(UrlString.url+'Mob/getname?mid=$mmid'));
          if(name.statusCode == 200) {
            DB_Mob mname = DB_Mob.fromJson(con.jsonDecode(name.body));
            mobinzone[i].mobname = mname.mname;
            onAddMarkerButtonPressed(
              mobinzone[i].mlat,
              mobinzone[i].mlong,
              mobinzone[i].reachtime.toString(),
              mobinzone[i].mqty,
              mobinzone[i].mid.toString(),
              mname.mname,
              currentmarker ,
              mobinzone[i].mstatus,
            );
          }
        }
      }
      else MyToast.showToast(res.body);
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
      bottomNavigationBar:CurvedBar(),
    );
  }
}

