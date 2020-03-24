import 'dart:async';
import 'dart:convert';
import 'package:corona_virus_tracker/data.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Fetch_data> _fetch_data; // fetchded data is stored
  List<location> locs; // get detail of each corona cases
  List<location> loc = []; // user data that is printed
  List<String> countries = [];
  List<String> provinces = [];

  MapType mapType = MapType.normal;
  int confirmed = 0;
  int deaths = 0;
  int recovered = 0;
  var _counrtycontroller = TextEditingController();
  var _provincecontroller = TextEditingController();
  int flag = 0; //// this is to check show_case called or not
  double h = 325;
  @override
  void initState() {
    super.initState();
    _fetch_data = fetchdata();
  }

  @override
  void dispose() {
    super.dispose();
  }

  GoogleMapController mapController;
  List<Marker> allMarkers = [];

  Future<Fetch_data> fetchdata() async {
    var response = await http
        .get('https://coronavirus-tracker-api.herokuapp.com/v2/locations');
    List<location> locations = [];
    List<String> countrys = [];
    List<String> provinces = [];
    if (response.statusCode == 200) {
      Map<dynamic, dynamic> map = json.decode(response.body);
      //  List<Map<dynamic,dynamic>> loc=map['locations'];
      for (int i = 0; i < map['locations'].length; i++) {
        locations.add(location.fromJson(map['locations'][i]));
        countrys.add(locations[i].country);
        provinces.add(locations[i].province);
      }
    }
    return Fetch_data(locations, countrys, provinces);
  }

  void show_SnackBar(String det, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(
        "$det",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
        ),
      ),
      backgroundColor: Colors.blueGrey,
      duration: Duration(seconds: 1),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25))),
    ));
  }

  void Map_CameraUpdate(double lat, double long) {
    mapController.animateCamera(CameraUpdate.newLatLng(LatLng(lat, long)));
  }

  Widget show_case_detail() {
    return Container(
      width: 250,
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: loc.length,
        itemBuilder: (BuildContext context, index) {
          return Container(
            decoration: BoxDecoration(),
            width: 250,
            child: Card(
              color: Colors.blueGrey[100],
              elevation: 20,
              child: Column(
                children: <Widget>[
                  Card(
                    child: loc[index].province == ''
                        ? null
                        : Text(
                            'Province = ${loc[index].province}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontStyle: FontStyle.italic),
                          ),
                  ),
                  Text('\nConfirmed Cases :  \n${loc[index].confirmed}\n',
                      textAlign: TextAlign.center),
                  Text('Death Cases :\n${loc[index].deaths}\n',
                      textAlign: TextAlign.center),
                  Text('Recovered Cases : \n${loc[index].recovered}\n',
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget Show_DropDown(List<String> parts, String det) {
    // return TextField(
    //     controller: controller,
    //     keyboardType: TextInputType.text,
    //     decoration: InputDecoration(
    //       labelText: "$det",
    //       icon: Icon(Icons.ac_unit),
    //     ));

    return DropdownButton(
      isExpanded: true,
      hint: Text("$det"),
      icon: Icon(Icons.ac_unit),
      elevation: 10,
      //    value: selectedValue,
      items: parts.map((part) {
        return DropdownMenuItem(
          child: Text("$part"),
          value: part,
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          //    selectedValue=val;
        });
      },
    );
  }

  void pressed(BuildContext context) {
    List<location> temp_loc = [];

    setState(() {
      allMarkers.clear();
      loc = temp_loc;
    });
    if (_counrtycontroller.text == '') {
      show_SnackBar("please enter the country", context);
      setState(() {
        flag = 0;
        h = 325;
        Map_CameraUpdate(28.6758656, 77.1110182);
      });
      return;
    }
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
    });

    if (loc.length == 0) {
      setState(() {
        flag = 0;
        h = 325;
      });
      show_SnackBar("Data not available !!!!", context);
      Map_CameraUpdate(28.6758656, 77.1110182);
      return;
    }

    setState(() {
      flag = 1;
      h = 530;
    });
    double lat = double.parse(loc[0].latitude);
    double long = double.parse(loc[0].longitude);
    for (int i = 0; i < loc.length; i++) {
      setState(() {
        if (i == 0) {
          Map_CameraUpdate(lat, long);
        }
        allMarkers.add(Marker(
            markerId: MarkerId("$i"),
            draggable: false,
            infoWindow: InfoWindow(
                title: loc[i].province == '' ? loc[i].country : loc[i].province,
                snippet:
                    "Confirmed Cases = ${loc[i].confirmed} , Deaths = ${loc[i].deaths} , Recovered = ${loc[i].recovered}"),
            position: LatLng(double.parse(loc[i].latitude),
                double.parse(loc[i].longitude))));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.blueGrey[100],
        body: FutureBuilder(
            future: _fetch_data,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                locs = snapshot.data.loc;
                countries = snapshot.data.countrys;
                provinces = snapshot.data.provinces;
                print(countries);
                print(provinces);

                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: h,
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
                                    Show_DropDown(
                                        countries, "Select the Country"),
                                    Container(
                                      height: 20,
                                    ),
                                    Show_DropDown(
                                        provinces, "Select the Provinces"),
                                    Container(
                                      height: 20,
                                    ),
                                    flag == 1 ? show_case_detail() : Text(""),
                                    Container(
                                      height: 20,
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        pressed(context);
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
