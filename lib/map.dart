import 'package:corona_virus_tracker/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  List<location> loc = []; // user data that is printed

  MapPage(this.loc);
  @override
  _MapPageState createState() => _MapPageState(loc);
}

class _MapPageState extends State<MapPage> {
  List<location> loc = []; // user data that is printed
  List<Marker> allMarker = [];
  GoogleMapController mapController;
  MapType mapType = MapType.normal;
  _MapPageState(this.loc);

  @override
  void initState() {
    super.initState();
    _showDialog();
  }

  _showDialog() async {
    await Future.delayed(Duration(milliseconds: 50));
    // Create button
    Widget okButton = FlatButton(
      child: Text("OK",style: TextStyle(color: Colors.white),),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30))),
      backgroundColor: Colors.blueGrey[700],

      title: Text("Message",style: TextStyle(color: Colors.white),),
      content: Text("Please click on Marker to get Detail",style: TextStyle(color: Colors.white),),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // this is used to update Camera
  void Map_CameraUpdate(double lat, double long) async {
    mapController.animateCamera(CameraUpdate.newLatLng(LatLng(lat, long)));
    return;
  }

  void AddMarker(BuildContext context) {
    double lat = double.parse(loc[0].latitude);
    double long = double.parse(loc[0].longitude);
    for (int i = 0; i < loc.length; i++) {
      setState(() {
        if (i == 0) {
          Map_CameraUpdate(lat, long);
        }
        allMarker.add(Marker(
            onTap: () {
              showbottomsheet(context, loc[i]);
            },
            markerId: MarkerId("$i"),
            draggable: false,
            infoWindow: InfoWindow(
                title: loc[i].province == '' ? loc[i].country : loc[i].province,
                snippet: "Confirmed Cases = ${loc[i].confirmed}"),
            position: LatLng(double.parse(loc[i].latitude),
                double.parse(loc[i].longitude))));
      });
    }
  }

  // this is used to provide detail of confirmed ,death,and recoverd cases
  Widget show_case_detail(location locate) {
    return Container(
      height: 212,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blueGrey[800], Colors.blueGrey[500]]),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: Column(
        children: <Widget>[
          Container(
            height: 32,
            decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            width: MediaQuery.of(context).size.width,
            child: locate.province == ''
                ? null
                : Text(
                    'Province = ${locate.province}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
          ),
          Text(
            '\nConfirmed Cases :  \n${locate.confirmed}\n',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.white70),
          ),
          Text(
            'Death Cases :\n${locate.deaths}\n',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.white70),
          ),
          Text(
            'Recovered Cases : \n${locate.recovered}\n',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  void showbottomsheet(BuildContext context, location locate) {
    showModalBottomSheet(
        backgroundColor: Colors.blueGrey,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        context: context,
        builder: (context) {
          return show_case_detail(locate);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: mapType,
            onMapCreated: (controller) {
              mapController = controller;
              AddMarker(context);
            },
            initialCameraPosition:
                CameraPosition(target: LatLng(28.6758656, 77.1110182), zoom: 5),
            markers: allMarker.toSet(),
          ),
          Positioned(
            right: 30,
            top: 30,
            child: FloatingActionButton(
              backgroundColor: Colors.blueGrey,
              onPressed: () {
                setState(() {
                  mapType = mapType == MapType.normal
                      ? MapType.satellite
                      : MapType.normal;
                });
              },
              splashColor: Colors.blueGrey,
              child: Icon(Icons.map),
            ),
          )
        ],
      ),
    );
  }
}
