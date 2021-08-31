import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:mob_admin_panel/classes/db_arielshot.dart';
import 'package:mob_admin_panel/classes/db_mob.dart';
import 'package:mob_admin_panel/classes/db_zone.dart';
import 'package:mob_admin_panel/classes/db_zonedetail.dart';
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

  List<DB_ArielShot> myshotlist;
  List<DB_Zone> zone;
  int shotlistlenght=0;
  int dispercent=100;
  double hundredpert=1;
  double currentmob=1;

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
      // if (id == "1"){
      //   hundredpert=double.parse(qty);
      // }
      // currentmob=double.parse(qty);
      // double dispersal = (currentmob/hundredpert)*100;
      // //MyToast.showToast('${dispersal}');
      // if((dispersal<=dispercent.toDouble()+5 || dispersal<=dispercent.toDouble()-5) && dispersal>=dispercent.toDouble()-20.0) {
      //   marker.add(Marker(
      //       markerId: MarkerId(id),
      //       position: LatLng(lat, long),
      //       infoWindow: InfoWindow(
      //         title: 'Qty:$qty, Dispersal:${100-dispersal}%, Remaining:${dispersal.toInt()}%',
      //         snippet: 'Speed:${speed}, Time:${time}',
      //       ),
      //       icon: mark,
      //       onTap: () {
      //         for (int i = 0; i < myshotlist.length; i++) {
      //           if (id == myshotlist[i].picno.toString()) {
      //             setState(() {
      //               bytes = base64Decode(myshotlist[i].paddres);
      //             });
      //           }
      //         }
      //       }
      //   ));
      //
      //   setState(() {
      //     dispercent -=20;
      //   });
      // }

      if (id == "1"){hundredpert=double.parse(qty);}
      currentmob=double.parse(qty);
      double dispersal = (currentmob/hundredpert)*100;
      marker.add(Marker(
          markerId: MarkerId(id),
          position: LatLng(lat, long),
          infoWindow: InfoWindow(
            title: 'Qty:$qty, Dispersal:${100-dispersal}%, Remaining:${dispersal.toInt()}%',
            snippet: 'Speed:${speed}, Time:${time}',
          ),
          icon: mark,
          onTap: () {
            for (int i = 0; i < myshotlist.length; i++) {
              if (id == myshotlist[i].picno.toString()) {
                setState(() {
                  bytes = base64Decode(myshotlist[i].paddres);
                });
              }
            }
          }
      ));
    });

  }

  getshots() async{

    var res1 = await http.get(Uri.parse(UrlString.url+'Zones/allzone'));
    if(res1.statusCode == 200) {
      setState(() {
        Iterable list = con.json.decode(res1.body);
        zone = (list.map((e) => DB_Zone.fromJson(e)).toList());
      });
    }

    int mid = selectedmob.mid;
    var res = await http.get(Uri.parse(UrlString.url+'picture/Getpicofmob?mid=$mid'));
    if(res.statusCode == 200) {

      setState(() {
        Iterable list = con.json.decode(res.body);
        myshotlist = list.map((e) => DB_ArielShot.fromJson(e)).toList();
        print(myshotlist.length.toString());
      });

      int i = 0;
      for(i ; i<myshotlist.length; i++) {
        MyToast.showToast("$i");
        //shotlistlenght+=1;
        await Future.delayed(Duration(seconds: 2), () async {

          onAddMarkerButtonPressed(
              myshotlist[i].platitude,
              myshotlist[i].plongitude,
              myshotlist[i].pdatetime,
              myshotlist[i].speed,
              myshotlist[i].picno.toString(),
              myshotlist[i].pmobquantity.toString(),
              i==myshotlist.length-1?currentmarker: blackmarker
          );

          //get new sensitive zones
           double lat = myshotlist[i].platitude, lon = myshotlist[i].plongitude;

          setState(() {
            position = CameraPosition(
                bearing: 192.833,
                target: LatLng(myshotlist[i].platitude, myshotlist[i].plongitude),
                tilt: 59.440,
                zoom: 11.0);
            goToPositone1();
          });

              for(int j = 0; j<zone.length; j++) {
             //   MyToast.showToast("${zone[j].zid.toString()},  ${myshotlist[i].mid}");
             //   DB_ZoneDetail thiszonedetail;
             //   var res = await http.get(Uri.parse(
             //       UrlString.url + 'ZoneDetail/viewzonestatus?zid=${zone[j]
             //           .zid}&mid=${myshotlist[i].mid}')
             //   );
             //   if (res.statusCode == 200) {
             //     MyMarker(zone[j].zlong, zone[j].zlat, (zone[j].zid+100), CustomMarker.redflag, '${thiszonedetail.reachtime} minute', thiszonedetail.mstatus);
             //     MyCircle(zone[j].zlong, zone[j].zlat, zone[j].km, (zone[j].zid+100).toString());
             //   }
             // }

               print("zoneindex${zone[j].zname}");
                 var dist = distance(myshotlist[i].platitude, myshotlist[i].plongitude,zone[j].zlat, zone[j].zlong, "K");
               print("dist:${dist}");
                 var speed = myshotlist[i].speed.split(' ');
               print("speed:${speed}");

               var time = (double.parse(dist)-zone[j].km.toDouble()) <= 0
                     ? 0.toDouble():
               double.parse(speed[0])==0?
               (double.parse(dist)-zone[j].km.toDouble())/1
                     :
                 (double.parse(dist)-zone[j].km.toDouble())/double.parse(speed[0]);
               print("time:${time}");
                 String previous_status='';

                 if(zone[j].isshow==null){
                   setState(() {
                     zone[j].isshow= false;
                   });
                 }
                 //now check is this zone is already isshow then we will updates its information
                 double pre_time=0;
                 if(zone[j].isshow){
                   if(time>zone[j].time){
                     setState(() {
                       zone[j].time=time;
                       zone[j].status = "Away";
                     });
                   }
                   else{
                     setState(() {
                       zone[j].time=time;
                       zone[j].status = "Toward";
                     });
                   }

                   Marker _marker = marker.firstWhere((c) => c.markerId.value == (zone[j].zid+100).toString() ,orElse: () => null);
                   Circle _circle = circles.firstWhere((c) => c.circleId.value ==(zone[j].zid+100).toString() ,orElse: () => null);
                   setState(() {
                     marker.remove(_marker);
                     circles.remove(_circle);
                   });
                 }

                 //if zone is near to mob
                 else if(double.parse(dist) <= (zone[j].km+3).toDouble()){
                   previous_status = "Toward";

                   setState(() {
                     zone[j].isshow = true;
                     zone[j].time = time.toDouble();
                     zone[j].status = previous_status;
                   });
                 }

                 if(zone[j].isshow){
                   MyMarker(zone[j].zlong, zone[j].zlat, (zone[j].zid+100), CustomMarker.redflag, '${zone[j].time} minute', zone[j].status);
                   MyCircle(zone[j].zlong, zone[j].zlat, zone[j].km, (zone[j].zid+100).toString());
                 }
               }

        });
      }

      thread();
    }
  }

  thread() async {

    while(true){
      int a = myshotlist.length;
      //get shots again
      int mid = selectedmob.mid;
      var res = await http.get(Uri.parse(UrlString.url+'picture/Getpicofmob?mid=$mid'));
      if(res.statusCode == 200) {
        setState(() {
          Iterable list = con.json.decode(res.body);
          myshotlist = list.map((e) => DB_ArielShot.fromJson(e)).toList();
          //print(myshotlist.length.toString());
        });

        if(myshotlist.length > a) {
          //we got new pic
          MyToast.showToast('got new length:${myshotlist.length}');
          //first we convert previous marker to black marker from blue
          // Marker _marker = marker.firstWhere((marker) => marker.markerId.value == (myshotlist.length-1).toString() ,orElse: () => null);
          // setState(() {
          //   marker.remove(_marker);
          // });
          onAddMarkerButtonPressed(
              myshotlist[myshotlist.length-2].platitude,
              myshotlist[myshotlist.length-2].plongitude,
              myshotlist[myshotlist.length-2].pdatetime,
              myshotlist[myshotlist.length-2].speed,
              myshotlist[myshotlist.length-2].picno.toString(),
              myshotlist[myshotlist.length-2].pmobquantity.toString(),
              blackmarker
          );
          //now make marker of new pic
          onAddMarkerButtonPressed(
              myshotlist[myshotlist.length-1].platitude,
              myshotlist[myshotlist.length-1].plongitude,
              myshotlist[myshotlist.length-1].pdatetime,
              myshotlist[myshotlist.length-1].speed,
              myshotlist[myshotlist.length-1].picno.toString(),
              myshotlist[myshotlist.length-1].pmobquantity.toString(),
              currentmarker
          );//i==0? startingmarker :

          setState(() {
            position = CameraPosition(
                bearing: 192.833,
                target: LatLng(myshotlist[myshotlist.length-1].platitude, myshotlist[myshotlist.length-2].plongitude),
                tilt: 59.440,
                zoom: 11.0);
            goToPositone1();
          });

          //now update the zones according to new current location
          //forst remove the markers
          for(int j=0; j<zone.length; j++){

     //now get the zones nearst to new current location
            double lat = myshotlist[myshotlist.length-1].platitude, long = myshotlist[myshotlist.length-1].plongitude;
            var dist = distance(lat, long, zone[j].zlat, zone[j].zlong, "K");
            var speed = myshotlist[myshotlist.length-1].speed.split(' ');
            var time = (double.parse(dist)-zone[j].km.toDouble()) <= 0
                ? 0 :
            (double.parse(dist)-zone[j].km.toDouble())/double.parse(speed[0]);

            //now check is this zone is already isshow then we will updates its information
            double previous_time=0;
            if(zone[j].isshow){
              if(time>zone[j].time){
                setState(() {
                  zone[j].distancekm = dist;
                  previous_time = zone[j].time;
                  zone[j].time=time;
                  zone[j].status = "Away";
                });
              }
              else{
                setState(() {
                  zone[j].distancekm = dist;
                  previous_time = zone[j].time;
                  zone[j].time=time;
                  zone[j].status = "Toward";
                });
              }

              // Marker _marker = marker.firstWhere((c) => c.markerId.value == (zone[j].zid+100).toString() ,orElse: () => null);
              // Circle _circle = circles.firstWhere((c) => c.circleId.value == (zone[j].zid+100).toString() ,orElse: () => null);
              // setState(() {
              //   marker.remove(_marker);
              //   circles.remove(_circle);
              // });
            }
            //if zone is near to mob
            else if(double.parse(dist) <= zone[j].km+3 ){
              String previous_status = "Toward";

              setState(() {
                zone[j].isshow = true;
                zone[j].time = time;
                zone[j].status = previous_status;
              });
            }

            if(zone[j].isshow){
              MyMarker(zone[j].zlong, zone[j].zlat, (zone[j].zid+100), CustomMarker.redflag, '${zone[j].distancekm} minutes', zone[j].status);
              MyCircle(zone[j].zlong, zone[j].zlat, zone[j].km, (zone[j].zid+100).toString());
            }

          }
        }
      }
    }
  }

  var  bytes;
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

  MyMarker(double long, double lat,int id, BitmapDescriptor mark, var speed,String Status) {
    setState(() {
      marker.add(Marker(
          markerId: MarkerId(id.toString()),
          position: LatLng(lat, long),
          infoWindow: InfoWindow(
            title: Status.toString(),
            //snippet: Status
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
        Padding(
          padding: EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 200,
              width: 300,
              child: bytes==null?Text("No Image"):Image(image: MemoryImage(bytes)),
            )
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
    Future.delayed(Duration(seconds: 1), () {
      getshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${selectedmob.mname}'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white,),
            onPressed: (){

              for(int j = 0; j<zone.length; j++)
              {
                Marker _marker = marker.firstWhere((c) => c.markerId.value == (zone[j].zid+100).toString() ,orElse: () => null);
                Circle _circle = circles.firstWhere((c) => c.circleId.value ==(zone[j].zid+100).toString() ,orElse: () => null);
                setState(() {
                  marker.remove(_marker);
                  circles.remove(_circle);
                });
              }
              for(int i = 0; i<myshotlist.length; i++)
              {
                Marker _marker = marker.firstWhere((marker) => marker.markerId.value == myshotlist[i].picno.toString() ,orElse: () => null);
                setState(() {
                  marker.remove(_marker);
                });
              }
              getshots();
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
