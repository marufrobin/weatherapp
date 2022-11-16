import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    Position? position;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    position = await Geolocator.getCurrentPosition();
    setState(() {
      lat = position!.latitude;
      lon = position!.longitude;
    });
    print("lattitude: $lat \ Longtitude: $lon");
    gettingData();
  }

  var lat;
  var lon;
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  gettingData() async {
    String weatherLink =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=175cf6ab4459aa37983a566b55f6167f";
    var weatherResponse = await http.get(Uri.parse(weatherLink));
    // print(weatherResponse.body);
    String forecastLink =
        "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=175cf6ab4459aa37983a566b55f6167f";
    var forecastResponse = await http.get(Uri.parse(forecastLink));
    // print(forecastResponse.body);
    weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponse.body));
    forecastMap = Map<String, dynamic>.from(jsonDecode(forecastResponse.body));
    // print(forecastMap);
    setState(() {});
    print(weatherMap);
  }

  void initState() {
    determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // gettingData();
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/b.png"), fit: BoxFit.cover),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${weatherMap!['name']}",
                style: TextStyle(
                    fontSize: 50, color: Colors.white, fontFamily: "SE"),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
