import 'package:flutter/material.dart';
import 'dart:async';
import './components/dashboard.dart';
import './components/profile.dart';
import './components/summery.dart';
import 'package:flutter/services.dart';
import 'package:iot_demo/iot_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  int selectedIndex=0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await IotDemo.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }
  Widget pageCaller(int index){
    switch (index) {
      case 0:
        {
          return dasnboard();

        }
      case 1:{
        return  summery();
      }
      case 2:{

        return profile();
      }
      default:{
        return dasnboard();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('IOT Demo'),
        ),
        body: Center(
          child: pageCaller(selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          // backgroundColor:Colors.lightBlueAccent,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.speed),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart_outlined),
              label: 'Summery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              label: 'Profile',
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (val){
            setState(() {
              selectedIndex=val;
            });

          },
        ),
      ),
    );
  }
}
