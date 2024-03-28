import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '8e6765f879b04f48b69f37ea80bf2bdf'; // Replace with your Weatherbit API key
  final String baseUrl = 'https://api.weatherbit.io/v2.0/history/daily';

  Future<Map<String, dynamic>> getPastWeatherData(String city, String date) async {
    final DateTime startDate = DateTime.parse(date);
    final DateTime endDate = startDate.add(Duration(days: 1));
    final String formattedStartDate = startDate.toIso8601String().split('T')[0]; // Format as YYYY-MM-DD
    final String formattedEndDate = endDate.toIso8601String().split('T')[0]; // Format as YYYY-MM-DD

    final response = await http.get(
      Uri.parse('$baseUrl?city=$city&key=$apiKey&start_date=$formattedStartDate&end_date=$formattedEndDate'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data. Status code: ${response.statusCode}. Response body: ${response.body}');
    }
  }
}
