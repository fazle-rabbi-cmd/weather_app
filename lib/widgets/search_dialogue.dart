import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mine/models/weather.dart';
import 'package:mine/services/weather_service.dart';
import 'package:mine/services/location_service.dart';

class SearchScreen extends StatelessWidget {
  final String apiKey;
  final Function(Weather, List<Weather>, List<Weather>, String) updateWeather;

  SearchScreen({
    required this.apiKey,
    required this.updateWeather,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SearchDialog(apiKey: apiKey, updateWeather: updateWeather),
      ),
    );
  }
}

class SearchDialog extends StatefulWidget {
  final String apiKey;
  final Function(Weather, List<Weather>, List<Weather>, String) updateWeather;

  SearchDialog({
    required this.apiKey,
    required this.updateWeather,
  });

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  String? _tempLocationName;
  String? _error;
  List<dynamic> _predictions = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Enter location name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12.0),
                  errorText: _error,
                ),
                onChanged: (value) {
                  setState(() {
                    _tempLocationName = value;
                    _error = null; // Clear error when user starts typing
                  });
                  if (value.isNotEmpty) {
                    _autocompletePlace(value);
                  } else {
                    setState(() {
                      _predictions = [];
                    });
                  }
                },
                onSubmitted: _searchLocation,
              ),
              if (_predictions.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _predictions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_predictions[index]['display_name']),
                      onTap: () {
                        _searchController.text = _predictions[index]['display_name'];
                        _searchLocation(_predictions[index]['display_name']);
                      },
                    );
                  },
                ),
              SizedBox(height: 12.0),
              ElevatedButton.icon(
                onPressed: () => _searchLocation(_searchController.text),
                icon: Icon(Icons.search),
                label: Text('Search'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              SizedBox(height: 24.0), // Increase spacing between groups
              ElevatedButton(
                onPressed: _setCurrentLocation,
                child: Text('Use Current Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _autocompletePlace(String value) async {
    try {
      final response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$value'));
      if (response.statusCode == 200) {
        setState(() {
          _predictions = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      print('Error fetching autocomplete results: $e');
    }
  }

  Future<void> _searchLocation(String value) async {
    if (value.trim().isEmpty) {
      setState(() {
        _error = 'Please enter a location name';
      });
      return;
    }

    final weatherService = WeatherService(widget.apiKey);

    try {
      final weatherData = await weatherService.getWeatherByLocationName(value);
      final dailyForecastData = await weatherService.getDailyForecast(
        weatherData.latitude ?? 0.0,
        weatherData.longitude ?? 0.0,
      );
      final hourlyForecastData = await weatherService.getHourlyForecast(
        weatherData.latitude ?? 0.0,
        weatherData.longitude ?? 0.0,
      );

      widget.updateWeather(
        weatherData,
        dailyForecastData,
        hourlyForecastData,
        value,
      );

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _error = 'Error fetching weather data';
      });
      print('Error fetching weather data: $e');
    }
  }

  Future<void> _setCurrentLocation() async {
    final locationService = LocationService();
    final weatherService = WeatherService(widget.apiKey);

    try {
      final position = await locationService.getCurrentLocation();
      final lat = position.latitude;
      final lon = position.longitude;

      final currentWeatherData =
      await weatherService.getCurrentWeather(lat, lon);
      final dailyForecastData = await weatherService.getDailyForecast(lat, lon);
      final hourlyForecastData =
      await weatherService.getHourlyForecast(lat, lon);

      widget.updateWeather(
        currentWeatherData,
        dailyForecastData,
        hourlyForecastData,
        currentWeatherData.locationName!,
      );

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _error = 'Error fetching weather data';
      });
      print('Error fetching weather data: $e');
    }
  }
}
