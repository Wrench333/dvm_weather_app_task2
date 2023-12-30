import 'dart:math';

class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final double minTemperature;
  final double maxTemperature;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.minTemperature,
    required this.maxTemperature,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      minTemperature: json['main']['temp_min'].toDouble(),
      maxTemperature: json['main']['temp_max'].toDouble(),
    );
  }
}

class Hourly_Forecast {
  final List<String> hours;
  final List<String> descriptions;
  final List<double> temperatures;

  Hourly_Forecast({
    required this.hours,
    required this.descriptions,
    required this.temperatures,
  });

  factory Hourly_Forecast.fromJson(Map<String, dynamic> json) {
    List<String> hours = [];
    List<String> descriptions = [];
    List<double> temperatures = [];

    for (int i = 0; i < 3; i++) {
      hours.add(json['list'][i]['dt_txt']);
      descriptions.add(json['list'][i]['weather'][0]['main']);
      temperatures.add(json['list'][i]['main']['temp'].toDouble());
    }

    return Hourly_Forecast(
      hours: hours,
      descriptions: descriptions,
      temperatures: temperatures,
    );
  }
}


class Daily_Forecast {
  final List<String> dates;
  final List<String> descriptions;
  final List<double> temperatures;
  final List<double> min_temperatures;
  final List<double> max_temperatures;

  Daily_Forecast({
    required this.dates,
    required this.descriptions,
    required this.temperatures,
    required this.min_temperatures,
    required this.max_temperatures,
  });

  factory Daily_Forecast.fromJson(Map<String, dynamic> json) {
    List<String> dates = [];
    List<String> descriptions = [];
    List<double> temperatures = [];
    List<double> min_temperatures = [];
    List<double> max_temperatures = [];
    //int n = 0;
    double min_temp = 0;
    double max_temp = 0;

    for (int i = 0; i < 15; i+=3) {
      dates.add(json['list'][i]['dt_txt']);
      descriptions.add(json['list'][i]['weather'][0]['main']);
      temperatures.add(json['list'][i]['main']['temp'].toDouble());
      min_temp = min(json['list'][i+2]['main']['temp'].toDouble(),min(json['list'][i]['main']['temp'].toDouble(), json['list'][i+1]['main']['temp'].toDouble()));
      min_temperatures.add(min_temp);
            /*if (min_temp == temperatures[i]) {
        n = i;
      } else if (min_temp == temperatures[i+1]) {
        n = (i+1);
      } else if (min_temp == temperatures[i+2]) {
        n = (i+2);
      }*/
      max_temp = max(json['list'][i+2]['main']['temp'].toDouble(),max(json['list'][i]['main']['temp'].toDouble(), json['list'][i+1]['main']['temp'].toDouble()));
      max_temperatures.add(max_temp);

    }

    return Daily_Forecast(
      dates: dates,
      descriptions: descriptions,
      temperatures: temperatures,
      min_temperatures: min_temperatures,
      max_temperatures: max_temperatures,
    );
  }
}

class AppState {
  static String selectedTemperatureUnit = 'celsius';
}

/*class Hourly_Forecast
 {
  final String hour1;
  final String description_forecast1;
  final double temperature_forecast1;
  final String hour2;
  final String description_forecast2;
  final double temperature_forecast2;
  final String hour3;
  final String description_forecast3;
  final double temperature_forecast3;

  Hourly_Forecast
  ({
    required this.hour1,
    required this.description_forecast1,
    required this.temperature_forecast1,
    required this.hour2,
    required this.description_forecast2,
    required this.temperature_forecast2,
    required this.hour3,
    required this.description_forecast3,
    required this.temperature_forecast3,
  });

  factory Hourly_Forecast
  .fromJson(Map<String, dynamic> json) {
    return Hourly_Forecast
    (
      hour1: json['list'][0]['dt_txt'],
      description_forecast1: json['list'][0]['weather'][0]['main'],
      temperature_forecast1: json['list'][0]['main']['temp'].toDouble(),
      hour2: json['list'][1]['dt_txt'],
      description_forecast2: json['list'][1]['weather'][0]['main'],
      temperature_forecast2: json['list'][1]['main']['temp'].toDouble(),
      hour3: json['list'][2]['dt_txt'],
      description_forecast3: json['list'][2]['weather'][0]['main'],
      temperature_forecast3: json['list'][2]['main']['temp'].toDouble(),
    );
  }
}*/
