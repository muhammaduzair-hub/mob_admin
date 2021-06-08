import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class CustomMarker extends StatefulWidget {
  //======custom markers==========
  static BitmapDescriptor startingmarker;
  static BitmapDescriptor currentmarker;
  static BitmapDescriptor blackmarker;
  static BitmapDescriptor redflag;

  @override
  void initState() {
    // TODO: implement initState
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1),
        'asset/icons/radar.png').then((onValue) {
          CustomMarker.currentmarker=onValue;
        });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 5),
        'asset/icons/marker1.png').then((onValue) {
      CustomMarker.startingmarker=onValue;
    });

    //BitmapDescriptor.f
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1),
        'asset/icons/black.png').then((onValue) {
      CustomMarker.blackmarker=onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1),
        'asset/icons/redflag.png').then((onValue) {
      CustomMarker.blackmarker=onValue;
    });
  }
  @override
  _CustomMarkerState createState() => _CustomMarkerState();
}

class _CustomMarkerState extends State<CustomMarker> {

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

