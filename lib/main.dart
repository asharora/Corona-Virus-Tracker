import 'package:corona_virus_tracker/homePage.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return loginPage();
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
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
            Image.asset('images/img2.png')
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
            height: 20,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    colors: [Colors.blueGrey[800], Colors.blueGrey[400]])),
            child: Center(
              child: Text(
                "@developed by Ashish",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    shadows: [Shadow(blurRadius: 50, color: Colors.white70)]),
              ),
            )),
      ),
    );
  }
}
