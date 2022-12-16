import 'dart:convert';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    return Scaffold(
      backgroundColor: Image.asset("assets/b.png").color,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/b.png"), fit: BoxFit.cover),
        ),
        child: weatherMap == null && forecastMap == null
            ? Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                    color: Colors.white, size: 40),
              )
            : Column(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                  ),
                  Container(height: 250, child: buildweather()),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.080,
                  ),
                  Stack(children: [
                    Image.asset("assets/h.png"),
                    Positioned(
                      right: 0,
                      left: 0,
                      top: 120,
                      bottom: -40,
                      child: BlurryContainer(
                        blur: 5,
                        color: Colors.transparent,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 30, horizontal: 4),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: forecastMap!['cnt'],
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(left: 10),
                                padding: EdgeInsets.all(6),
                                // height: 180,
                                width: 80,
                                decoration: BoxDecoration(
                                    color: Color(0xff5936B4),
                                    borderRadius: BorderRadius.circular(60)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${Jiffy([
                                            forecastMap!['list'][0]['dt']
                                          ]).format("h:mm a")}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: 'SE',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Image.network(
                                        "https://openweathermap.org/img/wn/${forecastMap!['list'][index]['weather'][0]['icon']}@2x.png"),
                                    Text(
                                      "${forecastMap!['list'][index]['weather'][0]['description']}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: 'SE',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "H: ${forecastMap!['list'][index]['main']['temp_max'].toString().substring(0, 2)}° \n L: ${forecastMap!['list'][index]['main']['temp_min'].toString().substring(0, 2)}°",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: 'SE',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  ],
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
