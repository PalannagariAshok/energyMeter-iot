import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import './components/dashboard.dart';
import './components/profile.dart';
import './components/summery.dart';
import 'package:flutter/services.dart';

class MyHttpOverrides extends HttpOverrides {
  var Cert;

  wss()async {
    Cert =(await rootBundle.load("assets/cert5.pem")).buffer.asInt8List();
  }
  @override
  HttpClient createHttpClient(SecurityContext? context) {

    return super.createHttpClient(context)
      ..badCertificateCallback =(X509Certificate cert, String host, int port) => true; }}
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
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
  wb()async {
    var cert =(await rootBundle.load("assets/cert5.pem")).buffer.asInt8List();
    SecurityContext clientContext = new SecurityContext()
      ..setTrustedCertificatesBytes(cert);
    var client = new HttpClient(context: clientContext);
    var request = await client.getUrl(Uri.parse("https://iot.texoham.in:3500"));
    var response = await request.close();
  }
  @override
  void initState() {
    // wb();

    super.initState();
    // initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformState() async {
  //   String platformVersion;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   // We also handle the message potentially returning null.
  //
  //
  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;
  //
  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });
  // }
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
        debugShowCheckedModeBanner: false,
      home: Scaffold(

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
              label: 'Summary',
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
