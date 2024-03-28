import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mine/models/weather.dart';

class WeatherService {
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getCurrentWeather(double lat, double lon) async {
    final baseUrl = 'https://api.weatherbit.io/v2.0';
    final response = await http.get(
      Uri.parse('$baseUrl/current?lat=$lat&lon=$lon&key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data['data'][0]);
    } else {
      throw Exception('Failed to load current weather');
    }
  }

  Future<Weather> getWeatherByLocationName(String locationName) async {
    final baseUrl = 'https://api.weatherbit.io/v2.0';
    final response = await http.get(
      Uri.parse('$baseUrl/current?city=$locationName&key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data['data'][0]);
    } else {
      throw Exception('Failed to load weather for location: $locationName');
    }
  }

  Future<List<Weather>> getDailyForecast(double? lat, double? lon) async {
    if (lat == null || lon == null) {
      throw Exception('Latitude and longitude must not be null.');
    }
    final baseUrl = 'https://api.weatherbit.io/v2.0';
    final response = await http.get(
      Uri.parse('$baseUrl/forecast/daily?lat=$lat&lon=$lon&key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final forecasts = data['data'] as List;
      return forecasts
          .map((forecast) => Weather.fromJson(forecast))
          .take(7)
          .toList();
    } else {
      throw Exception('Failed to load daily forecast');
    }
  }

  Future<List<Weather>> getHourlyForecast(double? lat, double? lon) async {
    if (lat == null || lon == null) {
      throw Exception('Latitude and longitude must not be null.');
    }
    final baseUrl = 'https://api.weatherbit.io/v2.0';
    final response = await http.get(
      Uri.parse('$baseUrl/forecast/hourly?lat=$lat&lon=$lon&key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final forecasts = data['data'] as List;
      return forecasts
          .map((forecast) => Weather.fromJson(forecast))
          .take(12)
          .toList();
    } else {
      throw Exception('Failed to load hourly forecast');
    }
  }

  Future<Weather> getHistoricalWeather(
      double lat, double lon, DateTime date) async {
    try {
      final baseUrl = 'https://api.weatherbit.io/v2.0';
      final formattedDate =
          '${date.year}-${_formatNumber(date.month)}-${_formatNumber(date.day)}';
      final response = await http.get(
        Uri.parse(
            '$baseUrl/history/hourly?lat=$lat&lon=$lon&start_date=$formattedDate&end_date=$formattedDate&key=$apiKey'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hourlyData = data['data'] as List;
        if (hourlyData.isNotEmpty) {
          return Weather.fromJson(hourlyData[0]);
        } else {
          throw Exception(
              'No historical weather data available for the specified date.');
        }
      } else {
        throw Exception(
            'Failed to load historical weather data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching historical weather data: $e');
      rethrow;
    }
  }

  String _formatNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  Future<Weather> getWeatherForDate(
      double lat, double lon, DateTime selectedDate) async {
    final weatherService = WeatherService(apiKey);
    try {
      // Fetch historical weather data for the specified date
      final historicalWeather =
      await weatherService.getHistoricalWeather(lat, lon, selectedDate);
      return historicalWeather;
    } catch (e) {
      print('Error fetching weather data for date: $e');
      rethrow; // Rethrow the exception for error handling in the UI
    }
  }

  // New method for fetching location suggestions
  Future<List<dynamic>> getLocationSuggestions(String query) async {
    try {
      final response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$query'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load location suggestions');
      }
    } catch (e) {
      print('Error fetching location suggestions: $e');
      rethrow;
    }
  }
}
