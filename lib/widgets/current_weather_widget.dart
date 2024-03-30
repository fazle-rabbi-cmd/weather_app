import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mine/models/weather.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class CurrentWeatherWidget extends StatefulWidget {
  final Weather currentWeather;
  final String locationName;
  final String timezoneIdentifier;

  const CurrentWeatherWidget({
    Key? key,
    required this.currentWeather,
    required this.locationName,
    required this.timezoneIdentifier,
  }) : super(key: key);

  @override
  _CurrentWeatherWidgetState createState() => _CurrentWeatherWidgetState();
}

class _CurrentWeatherWidgetState extends State<CurrentWeatherWidget> {
  bool _isDetailedInfoVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.locationName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
          SizedBox(height: 10),
          Text(_getCurrentTime(), style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${widget.currentWeather.temperature}°C', style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.black)),
              if (_getPrecipitationIcon() != null) _buildWeatherIcon(_getPrecipitationIcon()!),
            ],
          ),
          SizedBox(height: 20),
          Text('Feels Like ${_getValueOrNA(widget.currentWeather.feelsLikeTemperature)}°C', style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 10),
          Text('${_getPrecipitation()}', style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 20),
          Divider(thickness: 1.5, color: Colors.grey),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() => _isDetailedInfoVisible = !_isDetailedInfoVisible),
            child: Text(_isDetailedInfoVisible ? 'Hide Details' : 'Show Details', style: TextStyle(color: Colors.black)),
          ),
          Visibility(
            visible: _isDetailedInfoVisible,
            child: Column(
              children: [
                _buildWeatherInfo('Wind Speed', _getWindSpeed(), '', Icons.speed_outlined),
                _buildWeatherInfo('Humidity', _getValueOrNA(widget.currentWeather.humidity), '%', Icons.water_drop),
                _buildWeatherInfo('Cloud Coverage', _getValueOrNA(widget.currentWeather.cloudCoverage), '', Icons.cloud_circle),
                _buildWeatherInfo('Chance of Rain', _getValueOrNA(widget.currentWeather.chanceOfRain), '%', Icons.beach_access),
                _buildWeatherInfo('AQI', _getValueOrNA(widget.currentWeather.aqi), '%', Icons.air),
                _buildWeatherInfo('UV Index', _getValueOrNA(widget.currentWeather.uvIndex), '', Icons.wb_iridescent_rounded),
                _buildWeatherInfo('Pressure', _getValueOrNA(widget.currentWeather.pressure), 'hPa', Icons.compress),
                _buildWeatherInfo('Visibility', _getValueOrNA(widget.currentWeather.visibility), 'km', Icons.visibility_outlined),
                _buildWeatherInfo('Sunrise Time', widget.currentWeather.sunriseTime ?? 'N/A', '', Icons.wb_sunny_outlined),
                _buildWeatherInfo('Sunset Time', widget.currentWeather.sunsetTime ?? 'N/A', '', Icons.nightlight_round),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(String label, String value, String unit, IconData iconData) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(iconData, color: Colors.blue[300], size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Text('$label: $value$unit', style: TextStyle(color: Colors.black, fontSize: 16)),
        ),
      ],
    ),
  );

  Widget _buildWeatherIcon(String url) => Image.network(
    url,
    width: 100,
    height: 100,
    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) =>
    loadingProgress == null ? child : CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null),
    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const Icon(Icons.error),
  );

  String _getPrecipitation() => widget.currentWeather.precipitationType ?? 'N/A';

  String _getWindSpeed() => widget.currentWeather.windSpeed != null && widget.currentWeather.windDirection != null
      ? '${widget.currentWeather.windSpeed} km/h ${widget.currentWeather.windDirection}'
      : widget.currentWeather.windSpeed != null ? '${widget.currentWeather.windSpeed} ' : widget.currentWeather.windDirection ?? 'N/A';

  String _getValueOrNA(dynamic value) => value?.toString() ?? 'N/A';

  String? _getPrecipitationIcon() => widget.currentWeather.weatherIconCode != null ? "https://www.weatherbit.io/static/img/icons/${widget.currentWeather.weatherIconCode}.png" : null;

  String _getCurrentTime() {
    tz.initializeTimeZones();
    tz.Location? location = tz.getLocation(widget.timezoneIdentifier);
    tz.setLocalLocation(location);
    var now = tz.TZDateTime.now(location);
    var formatter = DateFormat('EEE, MMM d, h:mm a');
    return formatter.format(now);
  }
}
