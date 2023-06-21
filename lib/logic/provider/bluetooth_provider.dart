import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothProvider extends ChangeNotifier {
  final FlutterBluePlus _flutterBluetooth = FlutterBluePlus.instance;

  StreamSubscription<ScanResult>? scanSubscription;
  StreamSubscription<BluetoothDeviceState>? connectionState;
  StreamSubscription<List<int>>? connectedDeviceStream;
  bool isScanning = false;
  String devicename = '';
  double samplingRate = 0;
  String middleSymbol = " ";
  String serviceId = 'df292a60-ddfa-428d-86aa-c7fc913276c4';
  String characteristicsUid = 'dc1a14aa-f905-4432-a142-161937fca521';
  String? value;
  String deviceId = "58:CF:79:16:7F:AA";
  List<ScanResult> _discoverResults = [];
  List<ScanResult> get discoverResults => _discoverResults;
  BluetoothDevice? connectedDevice;
  bool device_connecting = false, device_connected = false;

  List<String> values = [];
  List<String> rawValues = [];
  double initialTime = -1, finalTime = -1;

  bool useAdvertiseConnect = true;

  BluetoothProvider() {
    [
      Permission.bluetoothScan,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();
    listenConnectionState(BluetoothDevice.fromId(deviceId));
  }


  //Start scanning of the devices 
  Future<void> startScan() async {
    _discoverResults.clear();
    isScanning = true;
    notifyListeners();
    scanSubscription = _flutterBluetooth
        .scan(timeout: const Duration(seconds: 5))
        .listen(null);
    scanSubscription?.onData((data) {
      if (data.device.name != "") {
        _discoverResults.add(data);
      }
    });
    scanSubscription?.onDone(() {
      isScanning = false;
    });
  }

  //Stop the scanning  
  Future<void> stopScan() async {
    await _flutterBluetooth.stopScan();
    await scanSubscription?.cancel().then((value) {
      isScanning = false;
      _discoverResults.clear();
      notifyListeners();
    });
  }

  //connection of systems
  Future<void> connect() async {
    device_connecting = true;
    notifyListeners();
    try {
      BluetoothDevice connectedDevice = BluetoothDevice.fromId(deviceId);    //connecting with required device
      connectedDevice.connect(
          autoConnect: false,
          shouldClearGattCache: true,
          timeout: const Duration(seconds: 5));
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  void listenConnectionState(BluetoothDevice connectedDevice) {
    connectionState = connectedDevice.state.listen(null);
    connectionState?.onData(onChangedDeviceState);  //changing the state as per the connection
  }


//Disconnect device 
  Future<void> disconnect() async {
    try {
      BluetoothDevice connectedDevice =
          await _flutterBluetooth.connectedDevices.then((value) => value.first);
      connectedDevice.disconnect();
      device_connected = false;
    } catch (e) {
      changeConnection(connectingState: false, connectedState: true);
    }
    notifyListeners();
  }

  //discovering the characteristics shared by the device and call addValues() to store data.
  Future<void> discoverCharacteristics(BluetoothDevice connectedDevice) async {
    List<BluetoothService> services = await connectedDevice.discoverServices();
    BluetoothCharacteristic? characteristics = getCharacteristics(services);
    if (characteristics != null) {
      connectedDeviceStream = characteristics.value.listen((data) {
        addValues(utf8.decode(data));
      }, onDone: clearValues);
      await characteristics.setNotifyValue(true);
    }
  }

  BluetoothCharacteristic? getCharacteristics(List<BluetoothService> services) {
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() == characteristicsUid) {
          return characteristic;
        }
      }
    }
    return null;
  }

  //changing connection method
  void changeConnectMethod(bool value) {
    useAdvertiseConnect = value;
    notifyListeners();
  }

  //Storing values to the application and calculate sampling rate 
  void addValues(String value) {
    if (values.length > 100) {
      values.removeAt(0);
    }
    values.add(value);
    rawValues.add(value);
    if (rawValues.first == "") {
      rawValues.removeAt(0);
    }
    if (rawValues.isEmpty) return;
    if (initialTime == -1) {
      initialTime =
          double.tryParse(rawValues.first.split(middleSymbol).last) ?? -1;
    }
    finalTime = double.tryParse(rawValues.last.split(middleSymbol).last) ?? -1;
    // print(
    //     '${rawValues.first.split(middleSymbol).last}|${rawValues.last.split(middleSymbol).last}');
    samplingRate = ((rawValues.length) / (finalTime - initialTime)) * 1000;
    notifyListeners();
  }

  Future<void> onChangedDeviceState(BluetoothDeviceState state) async {
    switch (state) {
      case BluetoothDeviceState.connected:
        changeConnection(connectedState: true, connectingState: false);
        callbyclick(); //for call to the Characteristics
        return;
      case BluetoothDeviceState.connecting:
        changeConnection(connectedState: false, connectingState: true);
        return;
      case BluetoothDeviceState.disconnected:
        changeConnection(connectedState: false, connectingState: false);
        await connectedDeviceStream?.cancel();
        clearValues();
        return;
      case BluetoothDeviceState.disconnecting:
        changeConnection(connectedState: false, connectingState: false);
        return;
      default:
        changeConnection(connectedState: false, connectingState: false);
        return;
    }
  }

  //Switching between connections
  void changeConnection(
      {required bool connectingState, required bool connectedState}) {
    device_connected = connectedState;
    device_connecting = connectingState;
    notifyListeners();
  } 

  void clearValues() {
    rawValues.clear();
    values.clear();
    samplingRate = 0.0;
    initialTime = -1;
    finalTime = -1;
  } //Clear whole data after disconnecting

  Future<void> callbyclick() async {
    BluetoothDevice connectedDevice =
        await _flutterBluetooth.connectedDevices.then((value) => value.first);
    await discoverCharacteristics(connectedDevice);
  }
}
