import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/status.dart' as status;
class summery extends StatefulWidget {
  const summery({Key? key}) : super(key: key);

  @override
  _summeryState createState() => _summeryState();
}
class SalesData{
  SalesData(this.year,this.sales);
  final double year;
  final double sales;
}
class _summeryState extends State<summery> {
   List chartPoewrData=[];
   List chartVoltageData=[];
   List chartCurrentData=[];
   int loading=0;
   var channel;
   TextEditingController dateTime=TextEditingController();
  late List<SalesData> _chartData=[];
  late TooltipBehavior _tooltipBehavior1;
   late TooltipBehavior _tooltipBehavior2;
   late TooltipBehavior _tooltipBehavior3;
  List<SalesData> getChartData() {
    final List<SalesData> chartData = [
      SalesData(2017, 25),
      SalesData(2018, 12),
      SalesData(2019, 24),
      SalesData(2020, 18),
      SalesData(2021, 30)
    ];
    return chartData;
  }

  @override
  void initState() {
    // TODO: implement initState
    print(DateTime.now());
    _chartData = getChartData();
    dateTime.text= DateFormat('dd-MM-yyyy').format(DateTime.now());
    _tooltipBehavior1 = TooltipBehavior(enable: true);
    _tooltipBehavior2 = TooltipBehavior(enable: true);
    _tooltipBehavior3 = TooltipBehavior(enable: true);
    setState(() {
      channel = WebSocketChannel.connect(
        Uri.parse('wss://iot.texoham.in:3500/graph'),
      );
    });
    //chartData=getChartData();
    super.initState();


    channel.sink.add(jsonEncode({
      'time': '${DateFormat('yyyy-MM-dd').format(DateTime.now())}'
    }));
    print('sdhyu ${channel.closeCode}');
    var dataset=[];
    var voltage=[];
    var current=[];
    // WebSocketChannel.connect(
    //   Uri.parse('wss://iot.texoham.in:3500/ws'),
    // ).stream.listen((message) {
    //   // print('messagessss$message');
    //   var msg;
    //   msg=jsonDecode(message);
    //   print('message${msg}');
    //   setState(() {
    //     //
    //     if(msg['period'] == 'day'){
    //
    //     }
    //     else{
    //
    //       var val='${msg['liveData']['kwh'].toStringAsFixed(1)}';
    //       var voltageVal='${msg['liveData']['voltage'].round()}';
    //       var currentVal='${msg['liveData']['current'].toStringAsFixed(2)}';
    //       var dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(msg['liveData']['utctime'], false);
    //       var dateLocal = dateTime.toUtc();
    //       dataset.add({'value':'${val}','time':dateLocal});
    //       voltage.add({'value':'${voltageVal.split('.')[0]}','time':dateLocal});
    //       current.add({'value':'${currentVal}','time':dateLocal});
    //       setState(() {
    //         chartPoewrData=[...dataset];
    //         chartVoltageData=[...voltage];
    //         chartCurrentData=[...current];
    //       });
    //     }
    //   });
    // }).onError((error){
    //   print('erorr${error}');
    // });



    channel.stream.listen((message) {
      // channel.sink.close(status.goingAway);
      print('sdhyu ${channel.closeCode}');
      print('messagessss$message');
      channel.sink.add('received!');


      var msg;
      msg=jsonDecode(message);

      if(msg != null){
        setState(() {
          loading=2;
        });
        msg.forEach((value){
          var val='${value['kwh'].toStringAsFixed(1)}';
          var voltageVal='${value['voltage'].round()}';
          var currentVal='${value['current'].toStringAsFixed(2)}';
          var dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(value['utctime'], false);
          var dateLocal = dateTime.toUtc();
          dataset.add({'value':'${val}','time':dateLocal});
          voltage.add({'value':'${voltageVal.split('.')[0]}','time':dateLocal});
          current.add({'value':'${currentVal}','time':dateLocal});


        });
        // print('${val.split('.')[0]} ${DateFormat('Hms').format(DateTime.parse(value['datetime']))}');
      }
      else{
        setState(() {
          loading=3;
        });
      }

      setState(() {
        chartPoewrData=dataset;
        chartVoltageData=voltage;
        chartCurrentData=current;
      });
      print(chartPoewrData);

    });
    // if(channel.closeCode==null){
    //   setState(() {
    //     loading=3;
    //   });
    // }
  }
  @override
  Widget build(BuildContext context) {
    final List<Color> color = <Color>[];
    color.add(Colors.blue[50]!);
    color.add(Colors.blue[200]!);
    color.add(Colors.blue);
    final List<double> stops = <double>[];
    stops.add(0.0);
    stops.add(0.5);
    stops.add(1.0);
    return Scaffold(
      appBar: AppBar(
        title: Text('Historical Data'),
      ),
      body: RefreshIndicator(
        onRefresh: ()async{
          dateTime.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
          final chan= WebSocketChannel.connect(
            Uri.parse('wss://iot.texoham.in:3500/graph'),
          );
          chan.sink.add(jsonEncode({
            'time':'${DateFormat('yyyy-MM-dd').format(DateTime.now())}'
          }));
          setState(() {
            loading=0;
          });
       await chan.stream.listen((message) {

            var msg;
            msg=jsonDecode(message);
            var dataset=[];
            var voltage=[];
            var current=[];
            if(msg != null){
              setState(() {
                loading=2;
              });
              msg.forEach((value){
                var dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(value['localtime'], false);
                var dateLocal = dateTime.toLocal();
                var val='${value['kwh'].toStringAsFixed(1)}';
                var voltageVal='${value['voltage'].round()}';
                var currentVal='${value['current'].toStringAsFixed(2)}';
                dataset.add({'value':'${val}','time':dateLocal});
                voltage.add({'value':'${voltageVal.split('.')[0]}','time':dateLocal});
                current.add({'value':'${currentVal}','time':dateLocal});

                //print('${val.split('.')[0]} ${DateFormat('Hms').format(DateTime.parse(value['datetime']))}');
              });
              print('messages${dataset}');
            }
            else{
              setState(() {
                loading=3;
              });
            }

            setState(() {
              chartPoewrData=dataset;
              chartVoltageData=voltage;
              chartCurrentData=current;
            });
            print(chartPoewrData);
          });
          return ;

        },
        child: ListView(
          children: [
            SizedBox(height:15),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                keyboardType: TextInputType.datetime,
                controller: dateTime,
                autocorrect: false,

                enableInteractiveSelection: false, // will disable paste operation


                onTap: () async{
                  FocusScope.of(context).requestFocus(new FocusNode());
                  DateTime date = DateTime(1900);
                  print((DateFormat('yyyy').format(date)));
                  FocusScope.of(context).requestFocus(new FocusNode());

                  date = (await showDatePicker(
                      context: context,
                      initialDate:DateTime.now(),
                      firstDate:DateTime(1900),
                      lastDate: DateTime.now()
                  ))!;
                  // validationService.changeDob(value);
                  dateTime.text = DateFormat('dd-MM-yyyy').format(date);
                  print(DateFormat('yyyy-MM-dd').format(date));

                  final chan= WebSocketChannel.connect(
                    Uri.parse('wss://iot.texoham.in:3500/graph'),
                  );
                  chan.sink.add(jsonEncode({
                    'time':'${DateFormat('yyyy-MM-dd').format(date)}'
                  }));
                  setState(() {
                    loading=0;
                  });
                  chan.stream.listen((message) {

                    var msg;
                    msg=jsonDecode(message);
                    var dataset=[];
                    var voltage=[];
                    var current=[];
                    if(msg != null){
                      setState(() {
                        loading=2;
                      });
                      msg.forEach((value){
                        var dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(value['localtime'], false);
                        var dateLocal = dateTime.toLocal();
                        var val='${value['kwh'].toStringAsFixed(1)}';
                        var voltageVal='${value['voltage'].round()}';
                        var currentVal='${value['current'].toStringAsFixed(2)}';
                        dataset.add({'value':'${val}','time':dateLocal});
                        voltage.add({'value':'${voltageVal.split('.')[0]}','time':dateLocal});
                        current.add({'value':'${currentVal}','time':dateLocal});

                        //print('${val.split('.')[0]} ${DateFormat('Hms').format(DateTime.parse(value['datetime']))}');
                      });
                      print('messages${dataset}');
                    }
                    else{
                      setState(() {
                        loading=3;
                      });
                    }

                    setState(() {
                      chartPoewrData=dataset;
                      chartVoltageData=voltage;
                      chartCurrentData=current;
                    });
                    print(chartPoewrData);
                  });



                },

                decoration:InputDecoration(
                  // labelStyle: TextStyle(
                  //     color: Theme.of(context).primaryColor),

                  isDense:true,
                  labelText: "Select Date",
                  // errorText:error==false ?null:'',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey),
                  ),
                  suffixIcon: Icon(Icons.date_range),


                  border: OutlineInputBorder(

                  ),

                ),
              ),
            ),
            loading==2?Column(
              children: [
                chartPoewrData.length>0? SfCartesianChart(
                  title: ChartTitle(text: 'Power'),

                  tooltipBehavior: _tooltipBehavior1,
                  series: <ChartSeries>[
                    AreaSeries(
                      // name: 'Sales',
                        dataSource: chartPoewrData,

                        borderColor: Colors.blueAccent,
                        borderWidth: 1,
                        color: Colors.blue[100],
                        xValueMapper: ( sales, _) =>sales['time'],
                        yValueMapper: (sales, _) =>double.parse(sales['value']),
                        // dataLabelSettings: DataLabelSettings(isVisible: true),
                        enableTooltip: true)
                  ],
                  primaryXAxis: DateTimeAxis(
                    labelFormat: "{value}",
                    // edgeLabelPlacement: EdgeLabelPlacement.shift,
                  ),
                  // primaryYAxis: NumericAxis(
                  //     labelFormat: '{value}M',
                  //     numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0)),
                ):Container(),
                chartPoewrData.length>0? SfCartesianChart(
                  title: ChartTitle(text: 'Voltage'),

                  tooltipBehavior: _tooltipBehavior2,
                  series: <ChartSeries>[
                    AreaSeries(
                      // name: 'Sales',
                        dataSource: chartVoltageData,

                        borderColor: Colors.blueAccent,
                        borderWidth: 1,
                        color: Colors.blue[100],
                        xValueMapper: ( sales, _) =>sales['time'],
                        yValueMapper: (sales, _) =>int.parse(sales['value']),
                        // dataLabelSettings: DataLabelSettings(isVisible: true),
                        enableTooltip: true)
                  ],
                  primaryXAxis: DateTimeAxis(
                    labelFormat: '{value}',
                    // edgeLabelPlacement: EdgeLabelPlacement.shift,
                  ),
                  // primaryYAxis: NumericAxis(
                  //     labelFormat: '{value}M',
                  //     numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0)),
                ):Container(),
                chartPoewrData.length>0? SfCartesianChart(
                  title: ChartTitle(text: 'Current'),

                  tooltipBehavior: _tooltipBehavior3,
                  series: <ChartSeries>[
                    AreaSeries(
                      // name: 'Sales',
                        dataSource: chartCurrentData,
                        borderColor: Colors.blueAccent,
                        borderWidth: 1,
                        color: Colors.blue[100],

                        xValueMapper: ( sales, _) =>sales['time'] ,
                        yValueMapper: (sales, _) =>double.parse(sales['value']),
                        // dataLabelSettings: DataLabelSettings(isVisible: true),
                        enableTooltip: true

                    )
                  ],
                  primaryXAxis: DateTimeAxis(
                    labelFormat: '{value}',
                    // edgeLabelPlacement: EdgeLabelPlacement.shift,
                  ),
                  // primaryYAxis: NumericAxis(
                  //     labelFormat: '{value}M',
                  //     numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0)),
                ):Container(),
              ],
            ):loading==0?Container(
              height: MediaQuery.of(context).size.height/1.3,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ):
            Container(
              height: MediaQuery.of(context).size.height/1.3,
              child: Center(
                child: Text('No Data Found'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
