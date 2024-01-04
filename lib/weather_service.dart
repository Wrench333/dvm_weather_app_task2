import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app_dvm/models.dart';

class WeatherService {
  final String apiKey;
  final String baseUrl1 = 'https://api.openweathermap.org/data/2.5/weather';
  final String baseUrl2 = 'https://api.openweathermap.org/data/2.5/forecast';

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String? city) async {
    final response = await http.get(Uri.parse('$baseUrl1?q=$city&appid=$apiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Hourly_Forecast> getHourly(String? city) async {
    final response = await http.get(Uri.parse('$baseUrl2?q=$city&appid=$apiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> forecast = json.decode(response.body);
      return Hourly_Forecast.fromJson(forecast);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Daily_Forecast> getDaily(String? city) async {
    final response = await http.get(Uri.parse('$baseUrl2?q=$city&appid=$apiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> forecast = json.decode(response.body);
      return Daily_Forecast.fromJson(forecast);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}

class WeatherApi {
  static Future<List<String>> searchCities(String query) async {
    final response = await http.get(
      Uri.parse('http://api.openweathermap.org/data/2.5/find?q=$query&type=like&sort=population&cnt=30&appid=418e2fa8d6411ce63ca657ad379712fb'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<String> cityNames = (data['list'] as List)
          .map((city) => city['name'].toString())
          .toList();
      return cityNames;
    } else {
      throw Exception('Failed to search cities');
    }
  }
}