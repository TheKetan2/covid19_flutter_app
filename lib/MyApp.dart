import 'package:flutter/material.dart';
import "package:flutter_map/flutter_map.dart" as flutterMap;
import "package:latlong/latlong.dart" as latLng;
import "package:flutter_vector_icons/flutter_vector_icons.dart";
import "dart:convert";
import "package:http/http.dart" as http;
import 'countries.dart';

import "InfoCard.dart";

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
  bool isLoading = true, pinClicked = false;
  String countryName;
  List detailData = [];
  double lat = 0, long = 0;

  @override
  initState() {
    _getDetailedData();
    _getCovidData();
    super.initState();
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
            location["lat"] == null ? 80.0 : location["lat"].toDouble(),
            location["long"] == null ? 40 : location["long"].toDouble(),
          ),
          builder: (context) => new Container(
            child: IconButton(
                icon: Icon(
                  Entypo.location_pin,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    pinClicked = true;
                    lat = location["lat"];
                    long = location["long"];
                  });
                }),
          ),
        ),
      );
    }
    return marker;
  }

  Widget showContainer() {
    print(lat.toString() + " " + long.toString());
    dynamic location = {};
    dynamic iso2;
    for (var country in detailData) {
      if (country["lat"] == lat && country["long"] == long) {
        location = country;
      }
    }
    print(detailData);

    for (var item in totalCountries) {
      if (location["countryRegion"] == item["name"]) {
        iso2 = item["iso2"];
      }
    }

    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: CircleAvatar(
                maxRadius: 20,
                backgroundImage: NetworkImage(
                  "https://raw.githubusercontent.com/hjnilsson/country-flags/master/png100px/${iso2.toString().toLowerCase()}.png",
                ),
              ),
            ),
            location["provinceState"] != null
                ? Text(
                    location["provinceState"].toString().toUpperCase(),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    location["countryRegion"].toUpperCase(),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                getInfoBox(
                  textValue: location["confirmed"],
                  icon: Entypo.emoji_sad,
                  color: Colors.orange,
                ),
                getInfoBox(
                  textValue: location["recovered"],
                  icon: Entypo.emoji_happy,
                  color: Colors.green,
                ),
                getInfoBox(
                  textValue: location["deaths"],
                  icon: Foundation.skull,
                  color: Colors.red,
                )
              ],
            ),
            RaisedButton(
                color: Colors.red,
                child: Text("Close"),
                onPressed: () {
                  setState(() {
                    pinClicked = false;
                  });
                })
          ],
        ),
      ),
    );
  }

  Container getInfoBox({textValue, Color color, IconData icon, String title}) {
    return Container(
      width: 70,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.black.withAlpha(200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          Text(
            textValue.toString(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> showDropDown() {
    List<DropdownMenuItem<String>> dropDownItem = [];
    totalCountries.forEach(
      (country) => dropDownItem.add(
        DropdownMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 20,
              ),
              Image.network(
                "https://raw.githubusercontent.com/hjnilsson/country-flags/master/png100px/${country["iso2"].toString().toLowerCase()}.png",
                width: 20.0,
              ),
              SizedBox(
                width: 20,
              ),
              Text(country["name"]),
            ],
          ),
          value: country["iso2"],
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            DropdownButton<String>(
              isExpanded: true,
              icon: Icon(Icons.arrow_downward),
              items: showDropDown(),
              onChanged: (String value) {
                setState(() {
                  countryName = value;
                });
                _getCovidData();
                _getDetailedData();
                print(countryName);
              },
              hint: Text("Global info"),
              value: countryName,
            ),
            Card(
              child: Container(
                width: double.infinity,
                height: 80,
                margin: EdgeInsets.all(3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    rowInfoBox(
                      title: "total cases",
                      data: total_cases,
                      color: Colors.orange,
                      icon: Entypo.emoji_sad,
                    ),
                    rowInfoBox(
                      title: "recovered",
                      data: recovered,
                      color: Colors.green,
                      icon: Entypo.emoji_happy,
                    ),
                    rowInfoBox(
                      title: "deths",
                      data: deaths,
                      color: Colors.red,
                      icon: Foundation.skull,
                    ),
                  ],
                ),
              ),
            ),
            isLoading
                ? Expanded(
                    child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        Container(
                          height: 10,
                        ),
                        Text("Loading map..."),
                      ],
                    ),
                  ))
                : Expanded(
                    child: Card(
                      margin: EdgeInsets.only(
                        left: 3,
                        right: 3,
                        bottom: 3,
                      ),
                      child: Stack(
                        children: <Widget>[
                          flutterMap.FlutterMap(
                            options: new flutterMap.MapOptions(
                              center: detailData.length == 0
                                  ? latLng.LatLng(51.5, -0.09)
                                  : latLng.LatLng(
                                      detailData[0]["lat"].toDouble(),
                                      detailData[0]["long"].toDouble(),
                                    ),
                              zoom: 2.8,
                            ),
                            layers: [
                              new flutterMap.TileLayerOptions(
                                urlTemplate: "https://api.tiles.mapbox.com/v4/"
                                    "{id}/{z}/{x}/{y}@2x.png?access_token=pk.eyJ1IjoidGhla2V0YW4yIiwiYSI6ImNrODNzbjJhczFkOWEzZnBnY3hvZDEyc3oifQ.Sq0TnHXyfJgodPce7SBlJQ",
                                additionalOptions: {
                                  'accessToken':
                                      'pk.eyJ1IjoidGhla2V0YW4yIiwiYSI6ImNrODNzbjJhczFkOWEzZnBnY3hvZDEyc3oifQ.Sq0TnHXyfJgodPce7SBlJQ',
                                  'id': 'mapbox.streets',
                                },
                              ),
                              new flutterMap.MarkerLayerOptions(
                                markers: generateMarker(),
                              ),
                            ],
                          ),
                          pinClicked
                              ? Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 60, horizontal: 20),
                                  height: 250,
                                  child: Dialog(
                                    backgroundColor:
                                        Colors.white10.withAlpha(100),
                                    elevation: 5.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: showContainer(),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
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
            pinClicked = false;
          });
          _getCovidData();
          _getDetailedData();
        },
        tooltip: 'Get Data',
        child: Icon(AntDesign.earth),
      ),
    );
  }

  Container rowInfoBox({String title, data, IconData icon, Color color}) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Icon(
            icon,
            color: color,
          ),
          Text(
            data.toString(),
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          )
        ],
      ),
    );
  }
}
