import 'package:flutter/material.dart';
import 'package:mine/models/weather.dart';
import 'package:mine/services/location_service.dart';
import 'package:mine/services/weather_service.dart';
import 'package:mine/widgets/current_weather_widget.dart';
import 'package:mine/widgets/daily_forecast_widget.dart';
import 'package:mine/widgets/hourly_forecast_widget.dart';
import 'package:mine/widgets/crop_suggestions_widget.dart';
import 'package:mine/widgets/recommendation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home_screen_utils.dart'; // Import the new file

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
      setState(() => isLoading = false);
      return;
    }

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
          IconButton(icon: Icon(Icons.search), onPressed: () => showSearchScreen(context, widget.apiKey, (Weather weather, List<Weather> dailyForecast, List<Weather> hourlyForecast, String locationName) {
            setState(() {
              currentWeather = weather;
              this.dailyForecast = dailyForecast;
              this.hourlyForecast = hourlyForecast;
              this.locationName = locationName;
            });
          })),
          IconButton(icon: Icon(Icons.info), onPressed: () => showRecommendation(context, currentWeather)),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: buildDrawer(context, () {}), // Adjust the onFeedbackTap callback as needed
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
                  Card(
                    child: CurrentWeatherWidget(currentWeather: currentWeather, locationName: locationName, timezoneIdentifier: currentWeather.zone ?? 'UTC'),
                  ),
                  SizedBox(height: 20),
                  buildButton(context, 'Crop Suggestions', showCropSuggestions, () => setState(() => showCropSuggestions = !showCropSuggestions)),
                  SizedBox(height: 10),
                  buildButton(context, 'Hourly Forecast', showHourlyForecast, () => setState(() => showHourlyForecast = !showHourlyForecast)),
                  SizedBox(height: 10),
                  buildButton(context, 'Daily Forecast', showDailyForecast, () => setState(() => showDailyForecast = !showDailyForecast)),
                  SizedBox(height: 20),
                  if (showCropSuggestions) Card(
                    child: CropSuggestionWidget(temperature: currentWeather.temperature),
                  ),
                  SizedBox(height: 20),
                  if (showHourlyForecast) Card(
                    child: HourlyForecastWidget(hourlyForecast: hourlyForecast),
                  ),
                  SizedBox(height: 20),
                  if (showDailyForecast) Card(
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
}
