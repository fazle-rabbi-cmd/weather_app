import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherEventsScreen extends StatefulWidget {
  @override
  _WeatherEventsScreenState createState() => _WeatherEventsScreenState();
}

class _WeatherEventsScreenState extends State<WeatherEventsScreen> {
  List<String> events = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndFetchWeatherAlerts();
  }

  Future<void> _getCurrentLocationAndFetchWeatherAlerts() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double latitude = position.latitude;
      double longitude = position.longitude;
      await fetchWeatherAlerts(latitude, longitude);
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> fetchWeatherAlerts(double latitude, double longitude) async {
    final apiKey = 'aa05b3052bf24c11b0a9cd580d0ca631'; // Replace with your actual API key
    final apiUrl =
        'https://api.weatherbit.io/v2.0/alerts?lat=$latitude&lon=$longitude&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> alerts = data['alerts'];
        setState(() {
          events = alerts
              .map<String>((alert) => alert['description'].toString())
              .toList();
        });
      } else {
        print('Failed to load weather alerts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading weather alerts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Events'),
      ),
      body: _buildNotifications(),
    );
  }

  Widget _buildNotifications() {
    return events.isEmpty
        ? Center(
      child: Text(
        'No current weather alerts.',
        style: TextStyle(fontSize: 16),
      ),
    )
        : ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            events[index],
            style: TextStyle(fontSize: 16),
          ),
        );
      },
    );
  }
}
