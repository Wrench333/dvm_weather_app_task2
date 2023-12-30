import 'package:flutter/material.dart';

class Manage_Cities extends StatefulWidget {
  const Manage_Cities({super.key});

  @override
  State<Manage_Cities> createState() => _Manage_CitiesState();
}

class _Manage_CitiesState extends State<Manage_Cities> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

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
      ),
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          width: size.width,
          child: Column(
            children: [
              /*TextField(
                controller: _searchController,
                onChanged: (query) {
                  //Add search functionality
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
              ),*/
              SizedBox(height: 20.0,),
            ],
          ),
        ),
      ),
    );
  }
}
