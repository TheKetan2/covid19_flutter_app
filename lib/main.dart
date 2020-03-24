import 'package:flutter/material.dart';
import "dart:convert";
import "package:http/http.dart" as http;
import "package:flutter_vector_icons/flutter_vector_icons.dart";
import "package:flutter_map/flutter_map.dart" as flutterMap;
import "package:latlong/latlong.dart" as latLng;

import "InfoCard.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Corona Updates'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int total_cases = 0, recovered = 0, deaths = 0;
  bool isLoading = true;
  String countryName;
  List detailData = [];

  @override
  initState() {
    _getDetailedData();
    _getCovidData();
    super.initState();
  }

  void _getDetailedData() async {
    String url = countryName == null
        ? "https://covid19.mathdro.id/api/confirmed"
        : "https://covid19.mathdro.id/api/countries/$countryName/confirmed";
    http.Response data = await http.get(url);
    dynamic coronaDetail = jsonDecode(data.body);
    print(coronaDetail);
    setState(() {
      detailData = coronaDetail;
    });
    for (var location in detailData) {
      print(location);
    }
  }

// Method to generate all the markers on map from detailData
  List<flutterMap.Marker> generateMarker() {
    List<flutterMap.Marker> marker = [];

    for (var location in detailData) {
      marker.add(
        flutterMap.Marker(
          width: 80.0,
          height: 40.0,
          point: new latLng.LatLng(
            location["lat"].toDouble(),
            location["long"].toDouble(),
          ),
          builder: (context) => new Container(
            child: new Icon(
              Icons.pin_drop,
              color: Colors.red,
              size: 20,
            ),
          ),
        ),
      );
    }
    return marker;
  }

  void _getCovidData() async {
    setState(() {
      isLoading = true;
    });
    String url = countryName == null
        ? "https://covid19.mathdro.id/api"
        : "https://covid19.mathdro.id/api/countries/$countryName";
    http.Response data = await http.get(url);
    dynamic coronaData = jsonDecode(data.body);

    setState(() {
      total_cases = coronaData["confirmed"]["value"];
      recovered = coronaData["recovered"]["value"];
      deaths = coronaData["deaths"]["value"];
      isLoading = false;
    });
    print(countryName);
  }

  List<DropdownMenuItem<String>> showDropDown() {
    List<DropdownMenuItem<String>> dropDownItem = [];
    countries.keys.forEach(
      (key) => dropDownItem.add(
        DropdownMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                "assets/img/${countries[key]}.png",
                width: 20.0,
                height: 15.0,
              ),
              Container(
                width: 10.0,
              ),
              Text(key),
            ],
          ),
          value: countries[key],
        ),
      ),
    );

    print(dropDownItem.length);
    return dropDownItem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/img/corona.png",
                    width: 100,
                    height: 100,
                  ),
                  CircularProgressIndicator(),
                  Container(
                    height: 10,
                  ),
                  Text("Loading..."),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  DropdownButton<String>(
                    items: showDropDown(),
                    onChanged: (String value) {
                      setState(() {
                        countryName = value;
                      });
                      _getCovidData();
                      _getDetailedData();
                      print(countryName);
                    },
                    hint: Text("Select country"),
                    value: countryName,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: InfoCard(
                          icon: Entypo.emoji_sad,
                          total_cases: total_cases,
                          title: "TOTAL CASES",
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: InfoCard(
                          icon: Entypo.emoji_happy,
                          total_cases: recovered,
                          title: "RECOVERED",
                          color: Colors.green,
                        ),
                      ),
                      Expanded(
                        child: InfoCard(
                          icon: Foundation.skull,
                          total_cases: deaths,
                          title: "DEATHS",
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: flutterMap.FlutterMap(
                      options: new flutterMap.MapOptions(
                        center: detailData.length == 0
                            ? latLng.LatLng(51.5, -0.09)
                            : latLng.LatLng(
                                detailData[0]["lat"].toDouble(),
                                detailData[0]["long"].toDouble(),
                              ),
                        zoom: 1.0,
                      ),
                      layers: [
                        new flutterMap.TileLayerOptions(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        new flutterMap.MarkerLayerOptions(
                            markers: generateMarker()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          setState(() {
            countryName = null;
          });
          _getCovidData();
          _getDetailedData();
        },
        tooltip: 'Get Data',
        child: Icon(AntDesign.earth),
      ),
    );
  }
}

Map<String, String> countries = {
  "Afghanistan": "af",
  "India": "in",
  "Indonesia": "id",
  "Iran": "ir",
  "Iraq": "iq",
  "Spain": "es",
  "Germany": "de",
  "Japan": "jp",
  "US": "us",
  "Italy": "it",
  "Korea, South": "kr",
  "Pakistan": "pk",
  "Australia": "au"
};
