import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather_app_dvm/weather_service.dart';

List<Map<String, dynamic>> cities = [];

class ManageCities extends StatefulWidget {
  final String cityName;
  final double temperature;

  const ManageCities({
    Key? key,
    required this.cityName,
    required this.temperature,
  }) : super(key: key);

  @override
  State<ManageCities> createState() => _ManageCitiesState();
}

class _ManageCitiesState extends State<ManageCities> {
  void navigateToAddCitiesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCitiesPage()),
    );
  }

  void showDeleteDialog(String cityName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete City"),
          content: Text("Do you want to delete $cityName?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  cities.removeWhere((city) => city["name"] == cityName);
                });
                Navigator.of(context).pop();
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Widget buildCityButton(String cityName, double temperature) {
    return GestureDetector(
      onLongPress: () {
        showDeleteDialog(cityName);
      },
      onTap: () {},
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[800] ?? Colors.grey,
            width: 1.0,
          ),
          color: const Color(0x00000000).withOpacity(0.5),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              cityName,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            Text(
              '${(temperature - 273).toStringAsFixed(0)}°',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cities.length == 0){
      cities.add({"name": widget.cityName, "temperature": widget.temperature});}

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Cities"),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
        actions: [
          IconButton(
            onPressed: navigateToAddCitiesPage,
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(height: 10.0),
              for (int i = 0; i < cities.length; i++)
                buildCityButton(
                  cities[i]["name"],
                  cities[i]["temperature"],
                ),
              /*ListView.builder(
                  itemCount: cities.length, itemBuilder: (context, index) {
                return buildCityButton(
                    cities[index]["name"],
                    cities[index]["temperature"]);
              }),*/
              SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}

class AddCitiesPage extends StatefulWidget {
  @override
  _AddCitiesPageState createState() => _AddCitiesPageState();
}

class _AddCitiesPageState extends State<AddCitiesPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allCities = [];
  List<String> filteredCities = [];
  final String apiKey = '418e2fa8d6411ce63ca657ad379712fb';

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  Future<void> fetchCities() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://api.openweathermap.org/data/2.5/find?q=&type=like&sort=population&cnt=30&appid=${apiKey}',
        ),
      );
      print('Search API response: $response');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> fetchedCities = (data['list'] as List)
            .map((city) => {
                  "name": city['name'].toString(),
                  "temperature": city['main']['temp'].toDouble(),
                })
            .toList();

        setState(() {
          allCities.clear();
          allCities.addAll(fetchedCities);
          filteredCities = List.from(allCities.map((city) => city["name"]));
        });
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  Future<void> searchCities(String query) async {
    try {
      final results = await WeatherApi.searchCities(query);
      setState(() {
        filteredCities = results;
      });
    } catch (e) {
      print('Error searching cities: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Cities"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(5.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.white,
                  ),
                  width: size.width,
                  height: size.height / 12,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      searchCities(query);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: ListView.builder(
                      itemCount: filteredCities.length,
                      itemBuilder: (context, index) {
                        return CityButton(
                          city: filteredCities[index],
                          onCitySelected: () {
                            setState(() {
                              cities.add({
                                'name': filteredCities[index],
                                'temperature': 273.15
                              });
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CityButton extends StatelessWidget {
  final String city;
  final Function onCitySelected;

  CityButton({required this.city, required this.onCitySelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: ElevatedButton(
        onPressed: () {
          onCitySelected();
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(15.0),
          backgroundColor: Colors.blueGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Row(
          children: [
            Text(
              city,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
