import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bluetooth_ble/logic/provider/bluetooth_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  @override
  void initState() {
    super.initState();
    // Permission to location and nearby devices
  }

  @override
  Widget build(BuildContext context) {
    //Interface design of application
    return Scaffold(
      body: SafeArea(
        child: Consumer<BluetoothProvider>(builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                        //primary buttons for scanning and connection.
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (!provider.isScanning) {
                                provider.startScan();
                              }
                            },
                            child: const Text("Start Scan"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (provider.isScanning) {
                                provider.stopScan();
                              }
                            },
                            child: const Text("Stop Scan"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await provider.connect();
                            },
                            child: const Text("Connect"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await provider.disconnect();
                            },
                            child: const Text("Disconnect"),
                          ),
                        ]),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Discovered Devices :${provider.discoverResults.length}',
                          style: const TextStyle(fontSize: 20),
                        ),
                        if (provider.isScanning)
                          const SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                            ),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  //   child: DecoratedBox(
                  //     decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.black),
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: SizedBox(
                  //         height: 200,
                  //         child: provider.discoverResults.isNotEmpty
                  //             ? Scrollbar(
                  //                 child: ListView.builder(
                  //                     itemBuilder: (context, index) {
                  //                       return ListTile(
                  //                         dense: true,
                  //                         title: Text(provider
                  //                             .discoverResults[index].name),
                  //                         subtitle: Text(provider
                  //                             .discoverResults[index].id),
                  //                       );
                  //                     },
                  //                     itemCount:
                  //                         provider.discoverResults.length),
                  //               )
                  //             : const Center(
                  //                 child: Text(
                  //                   "Scanned Devices found here",
                  //                   style: TextStyle(fontSize: 18),
                  //                 ),
                  //               )),
                  //   ),
                  // ),    //Displaying the systems scanned through bluetooth.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Use Advertise Connection method'),
                        Checkbox(
                            value: provider.useAdvertiseConnect,
                            onChanged: (value) =>
                                provider.changeConnectMethod(value ?? false))
                      ], // Switching between two mode of connection
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: DropdownButton(
                              value: provider.devicename != ''
                                  ? provider.devicename
                                  : null,
                              hint: const Text('Device'),
                              isExpanded: true,
                              itemHeight: kMinInteractiveDimension + 10,
                              borderRadius: BorderRadius.circular(10),
                              items: provider.discoverResults
                                  .map((e) => DropdownMenuItem(
                                        value: e.device.id,
                                        child: Text(e.device.name),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                provider.connect();
                              }),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ), //selecting Connection of required device
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Device: '),
                            const SizedBox(
                              width: 20,
                            ),
                            if (provider.device_connected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            else if (provider.device_connecting)
                              const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                ),
                              )
                            else
                              const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              )
                          ],
                        ),
                      ],
                    ),
                  ), //validating the hardware connected or not.

                  // StreamBuilder<List<int>>(
                  //   stream: provider.connectedDeviceStream.,
                  //   builder: (context, snapshot) {
                  //     String data =
                  //         ascii.decode(Uint8List.fromList(snapshot.data ?? []));

                  //     provider.addValues(data);

                  //     return const SizedBox();
                  //   },
                  // ),

                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    '  First sensor     Second sensor   Seconds(milli)',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: 550,
                    child: ListView.builder(
                      itemCount: provider.values.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            provider.values[index],
                            style: const TextStyle(fontSize: 32),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Sampling Rate: ${provider.samplingRate.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Total count: ${provider.rawValues.length}',
                          style: const TextStyle(fontSize: 24),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
