import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mine/models/weather.dart';
import 'package:mine/screens/past_weather_screen.dart';
import 'package:mine/screens/settings_screen.dart';
import 'package:mine/screens/weather_events_screen.dart';
import 'package:mine/services/location_service.dart';
import 'package:mine/services/weather_service.dart';
import 'package:mine/widgets/current_weather_widget.dart';
import 'package:mine/widgets/daily_forecast_widget.dart';
import 'package:mine/widgets/hourly_forecast_widget.dart';
import 'package:mine/widgets/crop_suggestions_widget.dart';
import 'package:mine/widgets/recommendation_widget.dart';
import 'package:permission_handler/permission_handler.dart';


import '../widgets/search_dialogue.dart';

class HomeScreen extends StatefulWidget {
  final String apiKey;

  HomeScreen({required this.apiKey});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Weather currentWeather = Weather(temperature: 0);
  List<Weather> dailyForecast = [];
  List<Weather> hourlyForecast = [];
  String locationName = '';
  String timezoneIdentifier='';
  bool isLoading = true;
  bool showCropSuggestions = false;
  bool showHourlyForecast = false;
  bool showDailyForecast = false;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    final permission = await Permission.location.request();

    if (permission != PermissionStatus.granted) {
      // Handle the case where permission is not granted
      setState(() => isLoading = false); // Stop showing the loading indicator
      // You could show an error message or a prompt to ask for permission again
      return; // Exit the function if permission isn't granted
    }

    // The rest of your existing code follows
    final location = await LocationService().getCurrentLocation();
    final weather = WeatherService(widget.apiKey);

    setState(() => isLoading = true);

    final current = await weather.getCurrentWeather(location.latitude, location.longitude);
    final daily = await weather.getDailyForecast(location.latitude, location.longitude);
    final hourly = await weather.getHourlyForecast(location.latitude, location.longitude);

    setState(() {
      currentWeather = current;
      locationName = current.locationName!;
      dailyForecast = daily;
      hourlyForecast = hourly;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nimbus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () => showSearchScreen(context)),
          IconButton(icon: Icon(Icons.info), onPressed: () => _showRecommendation(context)),
        ],
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card( // Wrap in Card
                    child: CurrentWeatherWidget(currentWeather: currentWeather, locationName: locationName, timezoneIdentifier: currentWeather.zone ?? 'UTC', ),
                  ),
                  SizedBox(height: 20),
                  _buildButton('Crop Suggestions', showCropSuggestions, () => setState(() => showCropSuggestions = !showCropSuggestions)),
                  SizedBox(height: 10),
                  _buildButton('Hourly Forecast', showHourlyForecast, () => setState(() => showHourlyForecast = !showHourlyForecast)),
                  SizedBox(height: 10),
                  _buildButton('Daily Forecast', showDailyForecast, () => setState(() => showDailyForecast = !showDailyForecast)),
                  SizedBox(height: 20),
                  if (showCropSuggestions) Card( // Wrap in Card
                    child: CropSuggestionWidget(temperature: currentWeather.temperature),
                  ),
                  SizedBox(height: 20),
                  if (showHourlyForecast) Card( // Wrap in Card
                    child: HourlyForecastWidget(hourlyForecast: hourlyForecast),
                  ),
                  SizedBox(height: 20),
                  if (showDailyForecast) Card( // Wrap in Card
                    child: DailyForecastWidget(dailyForecast: dailyForecast),
                  ),
                  SizedBox(height: 20),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, bool isVisible, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(isVisible ? 'Hide $text' : 'Show $text'),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey, Colors.blueGrey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _buildDrawerItem(Icons.history, 'Past Weather', () => _navigateTo(PastWeatherScreen())),
          _buildDrawerItem(Icons.settings, 'Settings', () => _navigateTo(SettingsScreen())),
          _buildDrawerItem(Icons.event, 'Weather Events', () => _navigateTo(WeatherEventsScreen())),
          _buildDrawerItem(Icons.feedback, 'Feedback', () {}),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[800]),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  void _showRecommendation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Recommendations'),
        content: RecommendationWidget(airQualityIndex: currentWeather.aqi?.toDouble() ?? 0, uvIndex: currentWeather.uvIndex?.toDouble() ?? 0),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void showSearchScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SearchScreen(
              apiKey: widget.apiKey,
              updateWeather: (Weather weather, List<Weather> dailyForecast,
                  List<Weather> hourlyForecast, String locationName) {
                setState(() {
                  currentWeather = weather;
                  this.dailyForecast = dailyForecast;
                  this.hourlyForecast = hourlyForecast;
                  this.locationName = locationName;
                });
              },
            ),
      ),
    );
  }

  void _navigateTo(Widget routeWidget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => routeWidget));
  }
}
