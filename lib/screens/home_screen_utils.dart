import 'package:flutter/material.dart';
import 'package:mine/screens/past_weather_screen.dart';
import 'package:mine/screens/settings_screen.dart';
import 'package:mine/screens/weather_events_screen.dart';
import 'package:mine/widgets/crop_suggestions_widget.dart';
import 'package:mine/widgets/recommendation_widget.dart';
import 'package:mine/widgets/search_dialogue.dart';

import '../models/weather.dart';

Widget buildButton(BuildContext context, String text, bool isVisible, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    child: Text(isVisible ? 'Hide $text' : 'Show $text'),
    style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
  );
}

Widget buildDrawer(BuildContext context, VoidCallback onFeedbackTap) {
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
        buildDrawerItem(context, Icons.history, 'Past Weather', () => _navigateTo(context, PastWeatherScreen())),
        buildDrawerItem(context, Icons.settings, 'Settings', () => _navigateTo(context, SettingsScreen())),
        buildDrawerItem(context, Icons.event, 'Weather Events', () => _navigateTo(context, WeatherEventsScreen())),
        buildDrawerItem(context, Icons.feedback, 'Feedback', onFeedbackTap),
      ],
    ),
  );
}

Widget buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
  return ListTile(
    leading: Icon(icon, color: Colors.blueGrey[800]),
    title: Text(title, style: TextStyle(fontSize: 16)),
    onTap: onTap,
  );
}

void showRecommendation(BuildContext context, dynamic currentWeather) {
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

void showSearchScreen(BuildContext context, String apiKey, Function(Weather, List<Weather>, List<Weather>, String) updateWeather) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SearchScreen(
        apiKey: apiKey,
        updateWeather: updateWeather,
      ),
    ),
  );
}

void _navigateTo(BuildContext context, Widget routeWidget) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => routeWidget));
}
