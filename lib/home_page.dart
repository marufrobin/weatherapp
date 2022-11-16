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
        backgroundColor: Image.asset("assets/b.png").color,
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/b.png"), fit: BoxFit.cover),
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.06,
              ),
              Container(height: 250, child: buildweather()),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.078,
              ),
              Stack(children: [
                Image.asset("assets/h.png"),
                Positioned(
                  right: 0,
                  left: 0,
                  top: 120,
                  bottom: -40,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 50, horizontal: 6),
                    height: 325,
                    // width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(44),
                            topRight: Radius.circular(44)),
                        image: DecorationImage(
                            image: AssetImage('assets/r.png'),
                            fit: BoxFit.cover)),
                    child: Container(
                      // margin: EdgeInsets.all(16),
                      // color: Colors.pink,
                      // height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 30, left: 10),
                            // height: 180,
                            width: 60,
                            decoration: BoxDecoration(
                                color: Colors.cyan,
                                borderRadius: BorderRadius.circular(30)),
                            child: Column(
                              children: [],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildweather() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "${weatherMap!['name']}",
          style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              fontFamily: "SE"),
        ),
        Text(
          "${weatherMap!['main']["temp"].toString().substring(0, 2)}°",
          style: TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              fontFamily: "SEThin"),
        ),
        Text(
          "${weatherMap!['weather'][0]["description"]}",
          style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w400,
              color: Color(0xffEBEBF5).withOpacity(0.6),
              fontFamily: "SE"),
        ),
        Text(
          "Feels Like: ${weatherMap!['main']["feels_like"].toString().substring(0, 2)}°",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: "SE"),
        ),
        Text(
          "H: ${weatherMap!['main']["temp_max"].toString().substring(0, 2)}°  L: ${weatherMap!['main']["temp_min"].toString().substring(0, 2)}°",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: "SE"),
        ),
      ],
    );
  }
}
