import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather_app_dvm/weather_service.dart';

class Manage_Cities extends StatefulWidget {
  final String cityName;
  final double temperature;

  const Manage_Cities({
    Key? key,
    required this.cityName,
    required this.temperature,
  }) : super(key: key);

  @override
  State<Manage_Cities> createState() => _Manage_CitiesState();
}

class _Manage_CitiesState extends State<Manage_Cities> {
  void showAddCitiesBottomDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: SingleChildScrollView(
            child: AddCitiesBottomDrawer(),
          ),
        );
      },
    );
  }

  // Function to generate a city button
  Widget buildCityButton(String cityName, double temperature) {
    return GestureDetector(
      onLongPress: () {
        // Handle long press (e.g., show a delete button)
      },
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
    List<Map<String, dynamic>> cities = [];
    cities.add({"name": widget.cityName, "temperature": widget.temperature});

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
            onPressed: showAddCitiesBottomDrawer,
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SizedBox(height: 10.0),
                for (int i = 0; i < (cities.length); i++)
                  buildCityButton(cities[i]["name"], cities[i]["temperature"]),
                SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddCitiesBottomDrawer extends StatefulWidget {
  @override
  _AddCitiesBottomDrawerState createState() => _AddCitiesBottomDrawerState();
}

class _AddCitiesBottomDrawerState extends State<AddCitiesBottomDrawer> {
  TextEditingController _searchController = TextEditingController();
  List<String> allCities = [];
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<String> fetchedCities = (data['list'] as List)
            .map((city) => city['name'].toString())
            .toList();

        setState(() {
          allCities.clear();
          allCities.addAll(fetchedCities);
          filteredCities = List.from(allCities);
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
                child: ListView.builder(
                  itemCount: filteredCities.length,
                  itemBuilder: (context, index) {
                    return CityButton(
                      city: filteredCities[index],
                      onCitySelected: () {
                        print(filteredCities[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
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
          print('CityButton pressed for city: $city');
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
