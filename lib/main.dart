import 'dart:async';
import 'dart:convert';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<location>> locations;
  List<location> locs; // get detail of corona cases
  List<location> loc = [];
  MapType mapType = MapType.normal;
  int confirmed = 0;
  int deaths = 0;
  int recovered = 0;
  var _counrtycontroller = TextEditingController();
  var _provincecontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    locations = fetchdata();
  }

  @override
  void dispose() {
    super.dispose();
  }

  GoogleMapController mapController;
  List<Marker> allMarkers = [];

  final _marker = Marker(
    markerId: MarkerId("BVPIEEE"),
    position: LatLng(28.6758656, 77.1110182),
    infoWindow: InfoWindow(
      title: "BVPIEEE",
      snippet:
          " A-4 Block, Baba Ramdev Marg, Shiva Enclave, Paschim Vihar, New Delhi, Delhi 110063",
    ),
  );

  Future<List<location>> fetchdata() async {
    var response = await http
        .get('https://coronavirus-tracker-api.herokuapp.com/v2/locations');
    List<location> locations = [];
    if (response.statusCode == 200) {
      Map<dynamic, dynamic> map = json.decode(response.body);
      //  List<Map<dynamic,dynamic>> loc=map['locations'];
      for (int i = 0; i < map['locations'].length; i++) {
        locations.add(location.fromJson(map['locations'][i]));
      }
    }
    return locations;
  }

  void pressed(var globalkey) {
    List<location> temp_loc = [];
    if (_counrtycontroller.text != '') {
      setState(() {
        temp_loc = (locs).where((location) {
          if (location.country == _counrtycontroller.text) {
            return true;
          } else {
            return false;
          }
        }).toList();
      });
    }

    if (_provincecontroller.text != '') {
      setState(() {
        List<location> loct = (temp_loc).where((location) {
          if (location.province == _provincecontroller.text) {
            return true;
          } else {
            return false;
          }
        }).toList();

        temp_loc = loct;
      });
    }

    setState(() {
      loc = temp_loc;
      allMarkers.clear();
    });

    double lat = double.parse(loc[0].latitude);
    double long = double.parse(loc[0].longitude);
    for (int i = 0; i < loc.length; i++) {
      setState(() {
        if (i == 0) {
          mapController
              .animateCamera(CameraUpdate.newLatLng(LatLng(lat, long)));
        }
        allMarkers.add(Marker(
            markerId: MarkerId("$i"),
            draggable: false,
            infoWindow: InfoWindow(
                title: loc[i].province == '' ? loc[i].country : loc[i].province,
                snippet:
                    "Confirmed Cases = ${loc[i].confirmed} \nDeaths = ${loc[i].deaths}\n Recovered = ${loc[i].recovered}"),
            position: LatLng(double.parse(loc[i].latitude),
                double.parse(loc[i].longitude))));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var globalkey;
    return Scaffold(
        drawer: Drawer(),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("  Corona Virus Tracker"),
          backgroundColor: Colors.blueGrey,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(50, 50),
                  bottomRight: Radius.elliptical(50, 50))),
        ),
        key: globalkey,
        backgroundColor: Colors.blueGrey[100],
        body: FutureBuilder(
            future: locations,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                locs = snapshot.data;

                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 580,
                        width: 600,
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey,
                                blurRadius: 5.0,
                              )
                            ]),
                        child: Column(
                          children: <Widget>[
                            Card(
                              color: Colors.blueGrey,
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: 20, right: 20, top: 40, bottom: 40),
                                child: Column(
                                  children: <Widget>[
                                    TextField(
                                        controller: _counrtycontroller,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          hintText: "Select the Country",
                                          icon: Icon(Icons.ac_unit),
                                        )),
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 30,
                                        bottom: 30,
                                      ),
                                    ),
                                    TextField(
                                        controller: _provincecontroller,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            hintText: "Select the Province",
                                            icon: Icon(Icons.ac_unit))),
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 25,
                                        bottom: 30,
                                      ),
                                    ),
                                    Container(
                                      width: 250,
                                      height: 200,
                                      
                                  
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: loc.length,
                                        itemBuilder:
                                            (BuildContext context, index) {
                                          return Container(
                                            decoration: BoxDecoration(
                                            
                                            ),
                                            width: 250,
                                            child: Card(
                                              color: Colors.blueGrey[100],
                                              elevation: 20,
                                              child: Column(
                                                children: <Widget>[
                                                   Card(
                                                      child: loc[index]
                                                                  .province ==
                                                              ''
                                                          ? null
                                                          : Text(
                                                              'Province = ${loc[index].province}',
                                                              textAlign: TextAlign
                                                                  .center,style: TextStyle(fontFamily: 'Roboto',fontStyle: FontStyle.italic),
                                                            ),
                                                    ),
                                                   Text(
                                                        '\nConfirmed Cases :  \n${loc[index].confirmed}\n',
                                                        textAlign:
                                                            TextAlign.center),
                                                  Text(
                                                        'Death Cases :\n${loc[index].deaths}\n',
                                                        textAlign:
                                                            TextAlign.center),
                                                  Text(
                                                        'Recovered Cases : \n${loc[index].recovered}\n',
                                                        textAlign:
                                                            TextAlign.center),
                                                  
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 0,
                                        bottom: 20,
                                      ),
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        pressed(globalkey);
                                      },
                                      child: Text("submit"),
                                      splashColor: Colors.lightBlueAccent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        children: <Widget>[
                          Container(
                            height: 500,
                            width: 600,
                            padding: EdgeInsets.all(5),
                            margin:
                                EdgeInsets.only(left: 20, right: 20, top: 20),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueGrey,
                                    blurRadius: 5.0,
                                  )
                                ]),
                            child: GoogleMap(
                              onMapCreated: (controller) {
                                mapController = controller;
                              },
                              mapType: mapType,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(28.6758656, 77.1110182),
                                zoom: 5.0,
                              ),
                              markers: Set.from(allMarkers),
                            ),
                          ),
                          Positioned(
                            right: 30,
                            top: 30,
                            child: FloatingActionButton(
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
                    ],
                  ),
                );
              }

              return CircularProgressIndicator();
            }));
  }
}
