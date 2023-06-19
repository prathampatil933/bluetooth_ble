import 'package:bluetooth_ble/logic/provider/bluetooth_provider.dart';
import 'package:bluetooth_ble/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BluetoothProvider(),
      child: const MaterialApp(
        title: 'Bluetooth BLE',
        home: BluetoothPage(),
      ),
    );
  }
}
