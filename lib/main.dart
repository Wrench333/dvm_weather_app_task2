import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_app_dvm/manage_cities.dart';
import 'package:weather_app_dvm/settings.dart';
import 'package:weather_app_dvm/statistics.dart';
import 'package:weather_app_dvm/models.dart';
import 'package:weather_app_dvm/weather_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.light(useMaterial3: true),
      dark: ThemeData.dark(useMaterial3: true),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather App DVM',
        theme: theme,
        darkTheme: darkTheme,
        home: Home(),
        routes: {
          '/home': (context) => Home(),
          '/settings': (context) => Settings(),
        },
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class TemperatureInfo extends StatelessWidget {
  final String title;
  final double temperature;

  TemperatureInfo({required this.title, required this.temperature});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18),
        ),
        Text(
          '${(temperature - 273.15).toStringAsFixed(0)}°C',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}

class ForecastRow extends StatelessWidget {
  final String date;
  final double minTemperature;
  final double maxTemperature;

  ForecastRow(
      {required this.date,
      required this.minTemperature,
      required this.maxTemperature});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          date,
          style: TextStyle(fontSize: 18),
        ),
        Text(
          '${(minTemperature).toStringAsFixed(0)}/${(maxTemperature).toStringAsFixed(0)}',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}

class _HomeState extends State<Home> {
  String? cityName = 'Chennai';
  final String apiKey = '418e2fa8d6411ce63ca657ad379712fb';
  final WeatherService weatherService =
      WeatherService('418e2fa8d6411ce63ca657ad379712fb');
  Weather? weather;
  Hourly_Forecast? hourly_forecast;
  Daily_Forecast? daily_forecast;
  late SharedPreferences _prefs;

  //Location location = Location();
  Position? position;

  @override
  void initState() {
    super.initState();
    _initPreferences();
    _fetchWeather();
    _fetchForecast();
    //requestPermission();
    //_fetchLocation();
    _determinePosition();
  }

  void _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    String? savedUnit = _prefs.getString('temperature_unit');
    if (savedUnit != null) {
      setState(() {
        AppState.selectedTemperatureUnit = savedUnit;
      });
    }
  }

  void _saveTheme(String newTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', newTheme);
  }

  Future<void> _saveTemperatureUnit(String unit) async {
    await _prefs.setString('temperature_unit', unit);
    setState(() {
      AppState.selectedTemperatureUnit = unit;
    });
  }

  /*Future<bool> requestPermission() async {
    final permission = await location.requestPermission();
    return permission == PermissionStatus.granted;
  }*/

  /*Future<void> _fetchLocation() async {
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best)
          .timeout(Duration(seconds: 5))

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        print(placemarks[0]);
    ...
    }catch(err){}
      //LocationData locationData = await location.getLocation();
      //print('Location: ${locationData.latitude}, ${locationData.longitude}');

    } catch (e) {
      print('Error fetching location: $e');
    }
  }*/

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<String?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best)
        .timeout(Duration(seconds: 5));

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position?.latitude ?? 0,
      position?.longitude ?? 0,
    );
    cityName = placemarks[0].locality;
    return placemarks[0].locality;
  }

  Future<void> _fetchWeather() async {
    try {
      var result = await weatherService.getWeather(cityName);
      print('Weather API Response: $result');
      setState(() {
        weather = result;
      });
    } catch (e) {
      print('Error fetching weather: $e');
    }
  }

  Future<void> _fetchForecast() async {
    try {
      var result = await weatherService.getHourly(cityName);
      var result2 = await weatherService.getDaily(cityName);
      print('Hourly Forecast API Response: $result');
      print('Daily Forecast API Response: $result2');
      setState(() {
        hourly_forecast = result;
        daily_forecast = result2;
      });
    } catch (e) {
      print('Error fetching hourly forecast: $e');
    }
  }

  double convertTemperature(double temperature) {
    return (AppState.selectedTemperatureUnit == 'celsius'
        ? (temperature - 273.15)
        : ((temperature - 273.15) * 9 / 5 + 32));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(cityName!),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Manage_Cities(
                    cityName: cityName!,
                    // Replace with your cityName variable
                    temperature: weather?.temperature ??
                        0, // Replace with your temperature variable
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.location_city,
            ),
          ),
          IconButton(
            onPressed: () async {
              Map<String, String>? settings = await Navigator.push<Map<String, String>>(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
              if (settings != null) {
                String? selectedUnits = settings['units'];
                String? selectedTheme = settings['theme'];
                // Handle the selected units and theme accordingly
                if (selectedUnits != null) {
                  // Update units in your app
                }
                if (selectedTheme != null) {
                  // Update theme in your app
                }
              }
            },
            icon: Icon(
              Icons.settings,
            ),
          ),
        ],
      ),
      body: buildBody(),
    );
  }

  SingleChildScrollView buildBody() {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Center(
              child: Text(
                '${convertTemperature(weather?.temperature ?? 0).toStringAsFixed(0)}${AppState.selectedTemperatureUnit == 'celsius' ? "°C" : "°F"}',
                style: TextStyle(
                  fontSize: 72,
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(weather?.description[0] ?? 'N/A').toUpperCase() + (weather?.description ?? 'N/A').substring(1)} ',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                Text(
                  '${((weather?.minTemperature ?? 0) - 273.15).toStringAsFixed(0)}/${((weather?.maxTemperature ?? 0) - 273.15).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[800] ?? Colors.grey,
                  width: 1.0,
                ),
                color: const Color(0x00000000).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0;
                          i < (hourly_forecast?.hours.length ?? 0);
                          i++)
                        Column(
                          children: [
                            Text(
                              hourly_forecast?.hours[i]?.substring(11, 16) ??
                                  'N/A',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              '${convertTemperature(hourly_forecast?.temperatures[i] ?? 0).toStringAsFixed(0)}${AppState.selectedTemperatureUnit == 'celsius' ? "°C" : "°F"}',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[800] ?? Colors.grey,
                  width: 1.0,
                ),
                color: const Color(000000).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0;
                          i < (daily_forecast?.dates.length ?? 0);
                          i++)
                        ForecastRow(
                          date: daily_forecast?.dates[i]?.substring(5, 10) ??
                              'N/A',
                          minTemperature: convertTemperature(
                              daily_forecast?.min_temperatures[i] ?? 0),
                          maxTemperature: convertTemperature(
                              daily_forecast?.max_temperatures[i] ?? 0),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              width: size.width,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Statistics(
                        minTemperatures: daily_forecast?.min_temperatures ?? [],
                        maxTemperatures: daily_forecast?.max_temperatures ?? [],
                      ),
                    ),
                  );
                },
                child: Text("Statistics"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
