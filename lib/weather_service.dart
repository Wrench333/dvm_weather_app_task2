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
