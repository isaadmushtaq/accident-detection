import 'dart:convert';
import 'dart:typed_data';
import 'package:accident_detection/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'location_history_screen.dart';

late User loggedInUser;

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  BluetoothConnection? _connection;
  bool _isConnected = false;
  bool isLoading = false;
  String coordinatesData = '';
  String rawData = '';
  bool accidentHappened = false;

  Future<void> _connectToDevice() async {
    setState(() {
      isLoading = true;
    });

    var status = await Permission.bluetoothScan.request();
    if (status.isGranted) {
      try {
        final List<BluetoothDevice> devices =
        await FlutterBluetoothSerial.instance.getBondedDevices();
        final BluetoothDevice device = devices.firstWhere((d) => d.name == "HC-05");
        final BluetoothConnection connection =
        await BluetoothConnection.toAddress(device.address);

        setState(() {
          _connection = connection;
          _isConnected = true;
          isLoading = false;
        });
      } catch (e) {
        print(e);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Bluetooth Connect permission denied');
      setState(() {
        isLoading = false;
      });
    }


    // added
    _connection!.input!.listen((Uint8List data) {
      setState(() {
        rawData = utf8.decode(data);
      });

      if (rawData.contains('Latitude') || rawData.contains('Longitude')) {
        setState(() {
          coordinatesData = utf8.decode(data);
          accidentHappened = true;
        });
      }

    }).onDone(() {
      setState(() {
        _isConnected = false;
        coordinatesData = '';
        rawData = '';
      });
    });
  }

  Future<void> _disconnectFromDevice() async {
    await _connection!.finish();
    setState(() {
      _connection = null;
      _isConnected = false;
    });
  }

  void addData() async {
    db.collection("locations").add(
      {
        "text": coordinatesData,
        // add all fields you want to add
      },
    ).then((value) {
      print("Data Added");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 40,
                        color: Colors.black54,
                      ),
                      const SizedBox(
                        height: 40,
                        child: VerticalDivider(
                          thickness: 1,
                          color: Colors.black12,
                          width: 40,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Accident Location",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            coordinatesData,
                            style: const TextStyle(color: Colors.black38),
                          )
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          accidentHappened ? addData() : null;
                          ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                  content:
                                  Text(accidentHappened?'Location added':"No Location Coordinates")));
                          setState(() {
                            accidentHappened = false;
                            coordinatesData = '';
                          });
                        }
                        ,
                        icon: Icon(
                          Icons.add_circle,
                          size: 40,
                          color:
                              accidentHappened ? Colors.green : Colors.black54,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  width: double.infinity,
                  color: Colors.black12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Terminal',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: kHomeScreenContainerDecoration,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(rawData),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text("IOT Based ADS"),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              onPressed:
                  _isConnected ? _disconnectFromDevice : _connectToDevice,

              icon: Icon(
                _isConnected ? Icons.bluetooth : Icons.bluetooth_disabled,
                size: _isConnected ? 20 : 15,
                color: _isConnected ? Colors.white : Colors.white70,
              ),
            ),
          ),
        ),
        PopupMenuButton(
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'locations',
              child: Row(
                children: [
                  Icon(Icons.location_off, color: Colors.black),
                  SizedBox(width: 10),
                  Text(
                    'Recent Locations',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.black),
                  SizedBox(width: 10),
                  Text(
                    'Logout',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'locations') {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LocationHistory()));
            } else if (value == 'logout') {
              _auth.signOut();
              Navigator.pop(context);
            }
          },
        )
      ],
    );
  }
}
