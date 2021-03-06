import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:segment_display/segment_display.dart';
class dasnboard extends StatefulWidget {
  const dasnboard({Key? key}) : super(key: key);

  @override
  _dasnboardState createState() => _dasnboardState();
}

class _dasnboardState extends State<dasnboard> {
  final client = MqttServerClient('iot.texoham.in', '',);
  var message=null;

  ScrollController messageController = ScrollController();
  // Future<MqttServerClient> connect() async {
  //   MqttServerClient client =
  //   MqttServerClient.withPort('188.166.231.10', 'device/477352496680172', 8083);
  //   client.logging(on: true);
  //   client.onConnected = onConnected;
  //   client.onDisconnected = onDisconnected;
  //
  //   client.onSubscribed = onSubscribed;
  //   client.onSubscribeFail = onSubscribeFail;
  //   client.pongCallback = pong;
  //
  //   final connMessage = MqttConnectMessage()
  //       .keepAliveFor(60)
  //       .withWillTopic('device/477352496680172')
  //       .withWillMessage('Will message')
  //       .startClean()
  //       .withWillQos(MqttQos.atLeastOnce);
  //   client.connectionMessage = connMessage;
  //   try {
  //     await client.connect();
  //   } catch (e) {
  //     print('Exception: $e');
  //     client.disconnect();
  //   }
  //
  //   client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
  //     final MqttMessage message = c[0].payload;
  //     // final payload =
  //     // MqttPublishPayload.bytesToStringAsString(message.payload.message);
  //
  //     print('Received message:$message from topic: ${c[0].topic}>');
  //   });
  //
  //   return client;
  // }
  void onConnected() {
    print('Connected');
  }
  void connect() async {
    client.logging(on: false);

    /// If you intend to use a keep alive you must set it here otherwise keep alive will be disabled.
    client.keepAlivePeriod = 20;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = onDisconnected;

    /// Add the successful connection callback
    client.onConnected = onConnected;


    client.onSubscribed = onSubscribed;

    /// Set a ping received callback if needed, called whenever a ping response(pong) is received
    /// from the broker.
    client.pongCallback = pong;


    final connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .withWillTopic('willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      print('EXAMPLE::socket exception - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      // exit(-1);
    }

    /// Ok, lets try a subscription
    print('EXAMPLE::Subscribing to the test topic');
    const topic = 'test'; // Not a wildcard topic
    client.subscribe(topic, MqttQos.atMostOnce);

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      setState(() {
        message=jsonDecode(pt);
      });

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- ${jsonDecode(pt)}] -->');
    });

    /// If needed you can listen for published messages that have completed the publishing
    /// handshake which is Qos dependant. Any message received on this stream has completed its
    /// publishing handshake with the broker.
    // client.published!.listen((MqttPublishMessage message) {
    //   print(
    //       'EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
    // });
  }
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }
// Disconnection
  void onDisconnected() {
    print('Disconnected');
  }

// Subscription to topic succeeded


// Failed to subscribe to topic
  void onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

// Unsubscribed successfully
  void onUnsubscribed(String topic) {
    print('Unsubscribed topic: $topic');
  }

// PING response received
  void pong() {
    print('Ping response client callback invoked');
  }
  void initState() {
    connect();
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Container(
        //   padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
        //   child: Card(
        //
        //     child: Container(
        //       height: 80,
        //       alignment: Alignment.center,
        //       child: ListTile(
        //
        //
        //         leading:
        //         Container(
        //
        //             child: Icon(Icons.bolt_outlined,color:Color.fromRGBO(112, 219, 250, 1),size:35)),
        //         title: Text('Real Time Power'),
        //         // subtitle:
        //         // Text('Add your home and office addresses'),
        //         trailing: Text('100 Kwh',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
        //
        //       ),
        //     ),
        //   ),
        // ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          height: 300,
          child: SfRadialGauge(
              title: GaugeTitle(
                  alignment: GaugeAlignment.center,
                  text: 'Avarage Voltage',
                  textStyle:
                  const TextStyle(fontSize: 16.0,color:Colors.black)),
              axes: <RadialAxis>[

                RadialAxis(minimum: 0, maximum: 500,interval: 70,
                    ranges: <GaugeRange>[
                      GaugeRange(startValue: 0, endValue: 150, color:Colors.green),
                      GaugeRange(startValue: 150,endValue: 300,color: Colors.orange),
                      GaugeRange(startValue: 300,endValue: 500,color: Colors.red)],
                    pointers: <GaugePointer>[

                      NeedlePointer(
                          needleLength: 0.5,needleEndWidth: 6,
                          value: message != null?message['voltage']:0.0),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(widget:
                      Container(
                        alignment: Alignment.center,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('${message != null?message['voltage'].toStringAsFixed(2):0.0}',
                                      style: TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold,color:Colors.black)),
                                  Text(' volt',
                                      style: TextStyle(
                                          fontSize: 14,color:Colors.grey[700])),

                                ],
                              ),
                              SizedBox(height:20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SevenSegmentDisplay(
                                    value: "${message != null? message['kw'] != null ?message['kw'].toStringAsFixed(2):0.0:0.0}",
                                    size: 2.0,
                                    characterSpacing: 5.0,
                                    backgroundColor: Colors.transparent,
                                    segmentStyle: HexSegmentStyle(
                                      enabledColor: Colors.blue,
                                      disabledColor: Colors.red.withOpacity(0.01),
                                      segmentBaseSize: const Size(1.8, 6.0),
                                    ),
                                  ),
                                  SizedBox(width:7),
                                  Text('kw')
                                ],
                              )
                            ],
                          )),
                      // Container(child:
                      // Text('${message != null?'${message['kwh']}kWh':'0.0 kWh' }',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold))),
                          angle: 90, positionFactor: 1.5
                      )]
                )]),
        ),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child: GridView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Card(
                shape:RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color:Colors.grey[100],
                //color: message.single_devices['topicData'] != null? Color.fromRGBO(112, 219, 250, 1):Colors.black38,
                child: Stack(
                    children:[
                      Positioned(
                        bottom:0,
                        right:0,
                        left:0,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          height:100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0)),
                            // color:Color.fromRGBO(3, 194, 179, 1.0),
                          ),
                          width:MediaQuery.of(context).size.width,

                        ),
                      ),
                      Container(

                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.bolt_outlined,size:30,color:Colors.blue[200]),
                            SizedBox(height: 10,),
                            Expanded(child: Text('Avarage Power Factor',textAlign: TextAlign.center,style: TextStyle(fontSize:16,color:Colors.grey[800]))),

                            Expanded(child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('${message != null? message['pf'] != null ?message['pf'].toStringAsFixed(2):0.0:0.0}',textAlign: TextAlign.center,style: TextStyle(fontSize:20,fontWeight: FontWeight.bold)),
                                Text('',textAlign: TextAlign.center,style: TextStyle(fontSize:14)),
                              ],
                            )),
                            SizedBox(height: 10,),
                            // Expanded(child: Text('Good',textAlign: TextAlign.center,style: TextStyle(fontSize:14,))),
                          ],
                        ),
                      ),
                    ]
                ),

              ),
              Card(
                shape:RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color:Colors.grey[100],
                //color: message.single_devices['topicData'] != null? Color.fromRGBO(112, 219, 250, 1):Colors.black38,
                child: Stack(
                    children:[
                      Positioned(
                        bottom:0,
                        right:0,
                        left:0,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          height:100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0)),
                            // color:Color.fromRGBO(3, 194, 179, 1.0),
                          ),
                          width:MediaQuery.of(context).size.width,

                        ),
                      ),
                      Container(

                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.flash_on_outlined,size:30,color:Colors.blue[200]),
                            SizedBox(height: 10,),
                            Expanded(child: Text('Average kwh',textAlign: TextAlign.center,style: TextStyle(fontSize:16,color:Colors.grey[800]))),

                            Expanded(child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('${message != null?message['kwh'].toStringAsFixed(2):0.0}',textAlign: TextAlign.center,style: TextStyle(fontSize:20,fontWeight: FontWeight.bold)),
                                Text(' kwh',textAlign: TextAlign.center,style: TextStyle(fontSize:14)),
                              ],
                            )),
                            SizedBox(height: 10,),
                            // Expanded(child: Text('Good',textAlign: TextAlign.center,style: TextStyle(fontSize:14,))),
                          ],
                        ),
                      ),
                    ]
                ),

              ),
              Card(
                shape:RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color:Colors.grey[100],
                //color: message.single_devices['topicData'] != null? Color.fromRGBO(112, 219, 250, 1):Colors.black38,
                child: Stack(
                    children:[
                      Positioned(
                        bottom:0,
                        right:0,
                        left:0,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          height:100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0)),
                            // color:Color.fromRGBO(3, 194, 179, 1.0),
                          ),
                          width:MediaQuery.of(context).size.width,

                        ),
                      ),
                      Container(

                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.flash_on_outlined,size:30,color:Colors.blue[200]),
                            SizedBox(height: 10,),
                            Expanded(child: Text('Average Current',textAlign: TextAlign.center,style: TextStyle(fontSize:16,color:Colors.grey[800]))),

                            Expanded(child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('${message != null?message['current'].toStringAsFixed(2):0.0}',textAlign: TextAlign.center,style: TextStyle(fontSize:20,fontWeight: FontWeight.bold)),
                                Text(' A',textAlign: TextAlign.center,style: TextStyle(fontSize:14)),
                              ],
                            )),
                            SizedBox(height: 10,),
                            // Expanded(child: Text('Good',textAlign: TextAlign.center,style: TextStyle(fontSize:14,))),
                          ],
                        ),
                      ),
                    ]
                ),

              ),
              Card(
                shape:RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color:Colors.grey[100],
                //color: message.single_devices['topicData'] != null? Color.fromRGBO(112, 219, 250, 1):Colors.black38,
                child: Stack(
                    children:[
                      Positioned(
                        bottom:0,
                        right:0,
                        left:0,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          height:100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0)),
                            // color:Color.fromRGBO(3, 194, 179, 1.0),
                          ),
                          width:MediaQuery.of(context).size.width,

                        ),
                      ),
                      Container(

                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.flash_on_outlined,size:30,color:Colors.blue[200]),
                            SizedBox(height: 10,),
                            Expanded(child: Text('Frequency',textAlign: TextAlign.center,style: TextStyle(fontSize:16,color:Colors.grey[800]))),

                            Expanded(child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('${message != null?message['frequency'].toStringAsFixed(2):0.0}',textAlign: TextAlign.center,style: TextStyle(fontSize:20,fontWeight: FontWeight.bold)),
                                Text(' ',textAlign: TextAlign.center,style: TextStyle(fontSize:14)),
                              ],
                            )),
                            SizedBox(height: 10,),
                            // Expanded(child: Text('Good',textAlign: TextAlign.center,style: TextStyle(fontSize:14,))),
                          ],
                        ),
                      ),
                    ]
                ),

              ),
            ],
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(

              childAspectRatio: ((MediaQuery.of(context).size.width/ 2) / (MediaQuery.of(context).size.height/ 4.5)),

              crossAxisCount:2,

            ),
            // physics: NeverScrollableScrollPhysics(), // to disable GridView's scrolling
            // shrinkWrap: true,
            primary: false,

          ),
        ),
      ],
    );
  }
}
