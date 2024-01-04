import 'package:flutter/material.dart';

class Manage_Cities extends StatefulWidget {
  const Manage_Cities({super.key});

  @override
  State<Manage_Cities> createState() => _Manage_CitiesState();
}

class _Manage_CitiesState extends State<Manage_Cities> {
  TextEditingController _searchController = TextEditingController();

  void showAddCitiesBottomDrawer() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddCitiesBottomDrawer(); // Create a new widget for the bottom drawer content
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
        height: 80,
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
              '${temperature.toStringAsFixed(0)}°',
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
    // Example usage of the function
    Widget currentCityButton = buildCityButton("Vidyavihar", 39.0);

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
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              currentCityButton,
              // Add more city buttons using the function
              buildCityButton("City2", 25.0),
              buildCityButton("City3", 30.0),
              // ...
              SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddCitiesBottomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Add City'),
            onTap: () {
              // Handle adding a city
              Navigator.pop(context); // Close the bottom drawer
            },
          ),
          // Add more items as needed
        ],
      ),
    );
  }
}