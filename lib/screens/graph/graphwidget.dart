import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bluetooth_ble/logic/provider/bluetooth_provider.dart';
import 'package:bluetooth_ble/model/datapoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphWidget extends StatefulWidget {
  const GraphWidget({
    super.key,
  });

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  StreamSubscription? streamSubscription;
  ChartSeriesController? _chartSeriesController;
  Color lineColor = Colors.blue;
  GlobalKey chartKey = GlobalKey();
  int count = 0;
  Timer? timer;
  bool showDataPoints = true;
  bool isOn = false;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() {
    // streamSubscription = Provider.of<BluetoothProvider>(context, listen: false)
    //     .streamSubscription;
    Provider.of<BluetoothProvider>(context, listen: false).clearValues();
    // -------------------------------------------------
    //  Experimental function to test
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // random number
      int y = Random().nextInt(100);
      updateChartData(DataPoint(
          xPoint: count.toDouble(),
          yPoint: y.toDouble(),
          yNewPoint: (y + 100).toDouble()));
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription?.cancel();
    // BluetoothDataProvider.bluetoothDataProvider.clearDataPoints();
    timer?.cancel();
  }

  void updateChartData(DataPoint dataPoint) {
    Provider.of<BluetoothProvider>(context, listen: false)
        .addDataPoint(dataPoint);
    if (Provider.of<BluetoothProvider>(context, listen: false).values.length ==
        100) {
      Provider.of<BluetoothProvider>(context, listen: false).removeDataPoint(0);
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[
          Provider.of<BluetoothProvider>(context, listen: false).values.length -
              1
        ],
        removedDataIndexes: <int>[0],
      );
    } else {
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[
          Provider.of<BluetoothProvider>(context, listen: false).values.length -
              1
        ],
      );
    }
    count++;
  }

  Future<void> removePage() async {
    if (!mounted) return;
    // portrait
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Column(
                    children: [
                      Stack(
                        children: [
                          buildChart(context, constraints),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              onTap: () {
                                // disable all ui
                                // --------------------
                                // Page route
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) {
                                //       return Scaffold(
                                //         floatingActionButton:
                                //             FloatingActionButton(
                                //           backgroundColor: lineColor,
                                //           elevation: 2,
                                //           onPressed: () {
                                //             Navigator.pop(context);
                                //           },
                                //           child: const Icon(
                                //             Icons.close,
                                //             color: Colors.white,
                                //           ),
                                //         ),
                                //         floatingActionButtonLocation:
                                //             FloatingActionButtonLocation
                                //                 .endTop,
                                //         body: Container(
                                //           decoration: BoxDecoration(
                                //               color: Colors.white,
                                //               borderRadius:
                                //                   BorderRadius.circular(10)),
                                //           height: MediaQuery.of(context)
                                //               .size
                                //               .height,
                                //           width: MediaQuery.of(context)
                                //               .size
                                //               .width,
                                //           child: buildChart(
                                //               context, constraints),
                                //         ),
                                //       );
                                //     },
                                //   ),
                                // );
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return OrientationBuilder(
                                      builder: (context, orientation) {
                                        return RotatedBox(
                                          quarterTurns: orientation ==
                                                  Orientation.portrait
                                              ? 3
                                              : 0,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: StatefulBuilder(
                                                    key: chartKey,
                                                    builder:
                                                        (context, setState) {
                                                      return buildChart(
                                                          context, constraints);
                                                    }),
                                              ),
                                              Positioned(
                                                top: 20,
                                                right: 20,
                                                child: FloatingActionButton(
                                                  backgroundColor: lineColor,
                                                  elevation: 2,
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ).then((value) {
                                  setState(() {});
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: CircleAvatar(
                                  backgroundColor: lineColor.withAlpha(100),
                                  child: Icon(
                                    Icons.zoom_out_map,
                                    color: lineColor,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Show Markers '),
                            Text(
                              '(Turn off for better performance)',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            )
                          ],
                        ),
                        Switch(
                          value: showDataPoints,
                          onChanged: (value) {
                            setState(() {
                              showDataPoints = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Line Color'),
                        Spacer(),
                        DropdownButton(
                          value: lineColor,
                          borderRadius: BorderRadius.circular(10),
                          elevation: 2,
                          dropdownColor: Colors.grey.shade100,
                          selectedItemBuilder: (BuildContext context) {
                            return <Widget>[
                              colorWidget('Blue', Colors.blue),
                              colorWidget('Red', Colors.red),
                              colorWidget('Green', Colors.green),
                              colorWidget('Orange', Colors.orange),
                              colorWidget('Purple', Colors.purple),
                            ];
                          },
                          items: <DropdownMenuItem>[
                            DropdownMenuItem(
                              value: Colors.blue,
                              child: colorWidget('Blue', Colors.blue),
                            ),
                            DropdownMenuItem(
                              value: Colors.red,
                              child: colorWidget('Red', Colors.red),
                            ),
                            DropdownMenuItem(
                              value: Colors.green,
                              child: colorWidget('Green', Colors.green),
                            ),
                            DropdownMenuItem(
                              value: Colors.orange,
                              child: colorWidget('Orange', Colors.orange),
                            ),
                            DropdownMenuItem(
                              value: Colors.purple,
                              child: colorWidget('Purple', Colors.purple),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              lineColor = value;
                            });
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<BluetoothProvider>(context, listen: false)
                            .connectedDeviceStream
                            ?.onData((data) {
                          String stringData = utf8.decode(data);
                          double? thirdPoint;
                          if (stringData.split(" ").length > 2) {
                            thirdPoint =
                                double.tryParse(stringData.split(' ')[1]);
                          }
                          DataPoint dataPoint = DataPoint(
                            xPoint:
                                double.parse(stringData.split(" ").last) / 1000,
                            yPoint: double.parse(stringData.split(" ").first),
                            yNewPoint: thirdPoint ?? 100,
                          );
                          updateChartData(dataPoint);
                          chartKey.currentState?.setState(() {});
                        });
                      },
                      child: const Text('Read Graph'),
                    )
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget colorWidget(String colorName, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          maxRadius: 9,
          backgroundColor: color,
        ),
        const SizedBox(
          width: 10,
        ),
        Text('$colorName')
      ],
    );
  }

  Widget buildChart(BuildContext context, BoxConstraints constraints) {
    return AspectRatio(
      aspectRatio: constraints.maxWidth > 600
          ? MediaQuery.of(context).size.aspectRatio
          : 1.17,
      child: SfCartesianChart(
        primaryXAxis: NumericAxis(isVisible: false),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: 1200,
          interval: 100,
        ),
        series: <LineSeries<DataPoint, num>>[
          LineSeries<DataPoint, num>(
            width: 2,
            xAxisName: 'Time',
            yAxisName: 'Value2',
            legendItemText: 'Value',
            // dashArray: <double>[5, 5],
            emptyPointSettings: EmptyPointSettings(
              mode: EmptyPointMode.zero,
            ),
            color: Colors.black,
            dataSource:
                Provider.of<BluetoothProvider>(context, listen: false).values,
            xValueMapper: (DataPoint data, _) => data.xPoint,
            yValueMapper: (DataPoint data, _) => data.yNewPoint,
            animationDuration: 0,
          ),
          LineSeries<DataPoint, num>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            width: 2,
            xAxisName: 'Time',
            yAxisName: 'Value',
            legendItemText: 'Value',
            // dashArray: <double>[5, 5],
            emptyPointSettings: EmptyPointSettings(
              mode: EmptyPointMode.zero,
            ),
            dataSource:
                Provider.of<BluetoothProvider>(context, listen: false).values,
            xValueMapper: (DataPoint data, _) => data.xPoint,
            yValueMapper: (DataPoint data, _) => data.yPoint,
            animationDuration: 0,
          ),
        ],
      ),
    );
  }
}
