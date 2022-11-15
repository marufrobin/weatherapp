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
    // gettingData();
  }

  var lat;
  var lon;

  gettingData() async {
    String weatherLink =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=f92bf340ade13c087f6334ed434f9761";
    var weatherResponse = await http.get(Uri.parse(weatherLink));
    // print(weatherResponse.body);
    String forecastLink =
        "https://api.openweathermap.org/data/2.5/forecast?lat=37.4219983&lon=-122.084&units=metric&appid=f92bf340ade13c087f6334ed434f9761";
    var forecastResponse = await http.get(Uri.parse(forecastLink));
    // print(forecastResponse.body);
    var weatherMap =
        Map<String, dynamic>.from(jsonDecode(weatherResponse.body));
    var forecastMap =
        Map<String, dynamic>.from(jsonDecode(forecastResponse.body));
    // print(forecastMap);
  }

  @override
  void initState() {
    determinePosition();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    gettingData();
    return SafeArea(child: Scaffold());
  }
}
