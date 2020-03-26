import 'dart:convert';

import 'package:corona_virus_tracker/data.dart';
import 'package:corona_virus_tracker/location.dart';
import 'package:corona_virus_tracker/map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class loginPage extends StatefulWidget {
  @override
  _loginPageState createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  Future<Fetch_data> _fetch_data; // fetchded data is stored
  List<location> locs; // get detail of each corona cases
  List<location> loc = []; // user data that is printed
  List<String> countries = []; // dropdown countries list
  Map<String, List<String>> provinces; // dropdown province list

  @override
  void initState() {
    super.initState();
    _fetch_data = fetchdata();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Fetch_data> fetchdata() async {
    var response = await http
        .get('https://coronavirus-tracker-api.herokuapp.com/v2/locations');

    List<location> locations = [];
    List<String> countrys = [];
    Map<String, List<String>> provinces = new Map<String, List<String>>();
    if (response.statusCode == 200) {
      Map<dynamic, dynamic> map = json.decode(response.body);

      //  List<Map<dynamic,dynamic>> loc=map['locations'];
      for (int i = 0; i < map['locations'].length; i++) {
        locations.add(location.fromJson(map['locations'][i]));
        if (countrys.contains(locations[i].country) == false) {
          countrys.add(locations[i].country);
        }

        if (provinces.containsKey("${locations[i].country}")) {
          List<String> a = provinces["${locations[i].country}"];
          if (locations[i].province != "") {
            a.add("${locations[i].province}");
          }

          provinces["${locations[i].country}"] = a;
        } else {
          List<String> a = [];
          if (locations[i].province != "") {
            a.add("${locations[i].province}");
          }

          provinces["${locations[i].country}"] = a;
        }
      }
    }

    return Fetch_data(locations, countrys, provinces);
  }

  // to show dropdown menu
  String _counrtycontroller;
  String _provincecontroller;
  String province; //store country for which we have to provide a provinces
  Widget Show_DropDown(List<String> parts, String det, int f) {
    if (f == 1) {
      return DropdownButton(
        isExpanded: true,
        hint: Text("Select the Country"),
        value: _counrtycontroller,
        icon: Icon(Icons.ac_unit),
        //    value: selectedValue,
        items: parts.map((part) {
          return DropdownMenuItem<String>(
            child: Text("$part"),
            value: part,
          );
        }).toList(),
        onChanged: (String val) {
          setState(() {
            _counrtycontroller = val;
            province = val;
          });
        },
      );
    } else {
      return DropdownButton(
        isExpanded: true,
        hint: Text("Select the province (Optional)"),
        value: _provincecontroller,

        icon: Icon(Icons.ac_unit),
        //    value: selectedValue,
        items: parts.map((part) {
          return DropdownMenuItem<String>(
            child: Text("$part"),
            value: part,
          );
        }).toList(),
        onChanged: (String val) {
          setState(() {
            _provincecontroller = val;
          });
        },
      );
    }
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

  bool t = false;
  Future<void> pressed(BuildContext context) async {
    List<location> temp_loc = [];

    setState(() {
      loc = temp_loc;
      t = true;
    });

    if (_counrtycontroller == null) {
      show_SnackBar("please enter the country", context);
      setState(() {
        _provincecontroller = null;
        _counrtycontroller = null;
      });
      return;
    }
    print(locs);
    if (_counrtycontroller != null) {
      setState(() {
        temp_loc = (locs).where((location) {
          if (location.country == _counrtycontroller) {
            return true;
          } else {
            return false;
          }
        }).toList();
      });
    }

    print(temp_loc);
    if (_provincecontroller != null) {
      setState(() {
        List<location> loct = (temp_loc).where((location) {
          if (location.province == _provincecontroller) {
            return true;
          } else {
            return false;
          }
        }).toList();

        temp_loc = loct;
      });
    }

    print(temp_loc);
    if (temp_loc.length == 0) {
      show_SnackBar("Data not available !!!!", context);
      setState(() {
        _provincecontroller = null;
        _counrtycontroller = null;
      });

      return;
    }

    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MapPage(temp_loc);
    }));

    setState(() {
      _provincecontroller = null;
      _counrtycontroller = null;
      t = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: FutureBuilder(
            future: _fetch_data,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                locs = snapshot.data.loc;
                countries = snapshot.data.countrys;
                provinces = snapshot.data.provinces;
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          colors: [
                        Colors.blueGrey[800],
                        Colors.blueGrey[400]
                      ])),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 50, left: 10, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "CORONA VIRUS",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.white70),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Text(
                                    "Tracker",
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.white70),
                                  ),
                                )
                              ],
                            ),
                            Image.asset(
                              'images/img2.png',
                              height: 100,
                              width: 135,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(top: 40),
                          margin: EdgeInsets.only(top: 30),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [Colors.blueGrey[200], Colors.white]),
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(70),
                                  topRight: Radius.circular(70))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Form(
                                  child: Column(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.only(left: 30, right: 30),
                                    decoration: BoxDecoration(
                                      // color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      //boxShadow: [BoxShadow(blurRadius: 5,color: Colors.black)]
                                    ),
                                    child: Show_DropDown(
                                        countries, "Select the Country", 1),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.only(left: 30, right: 30),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      // boxShadow: [BoxShadow(blurRadius: 15,color: Colors.blue)]
                                    ),
                                    child: Show_DropDown(
                                        province == null
                                            ? []
                                            : provinces['$province'],
                                        "Select the Provinces (Optional)",
                                        0),
                                  ),
                                  Container(
                                    height: 70,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      pressed(context);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 46,
                                      width: 170,
                                      //padding: EdgeInsets.only(top: 10, left: 60),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [
                                            Colors.blueGrey[800],
                                            Colors.blueGrey[300]
                                          ]),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Text("Submit"),
                                    ),
                                  ),
                                  t == true
                                      ? Container(
                                          margin: EdgeInsets.only(top: 30),
                                          child: CircularProgressIndicator(
                                          backgroundColor: Colors.blueGrey,
                                        ))
                                      : Text(""),
                                ],
                              )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
              return showReloadpart(context);
            }));
  }
}

Widget showReloadpart(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Colors.blueGrey[800], Colors.blueGrey[400]])),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "CORONA VIRUS",
          style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              shadows: [Shadow(blurRadius: 50, color: Colors.white70)]),
        ),
        Text(
          "TRACKER",
          style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              shadows: [Shadow(blurRadius: 50, color: Colors.white70)]),
        ),
        Image.asset('images/img2.png'),
        CircularProgressIndicator(
          backgroundColor: Colors.blueGrey,
        )
      ],
    ),
  );
}
