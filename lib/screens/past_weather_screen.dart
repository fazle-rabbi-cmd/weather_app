import 'package:flutter/material.dart';
import '../services/past_weather_service.dart';

class PastWeatherScreen extends StatefulWidget {
  @override
  _PastWeatherScreenState createState() => _PastWeatherScreenState();
}

class _PastWeatherScreenState extends State<PastWeatherScreen> {
  final WeatherService weatherService = WeatherService();
  Map<String, dynamic> weatherData = {};
  TextEditingController _dateController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  Future<void> fetchWeatherData(String location, String date) async {
    try {
      final data = await weatherService.getPastWeatherData(location, date);
      setState(() => weatherData = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching weather data: $e')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() => _dateController.text = picked.toIso8601String().split('T')[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Past Weather Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Enter Date (YYYY-MM-DD)',
                      suffixIcon: IconButton(icon: Icon(Icons.calendar_today), onPressed: () => _selectDate(context)),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: TextField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: 'Enter Location'),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_locationController.text.isNotEmpty && _dateController.text.isNotEmpty) {
                      fetchWeatherData(_locationController.text, _dateController.text);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter both location and date')));
                    }
                  },
                  child: Text('Search'),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (weatherData.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: weatherData['data'].length,
                  itemBuilder: (context, index) {
                    return _buildWeatherItemWidget(weatherData['data'][index]);
                  },
                ),
              )
            else
              Center(child: Text('No data available')),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherItemWidget(Map<String, dynamic> item) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: item.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Text('${_getLabel(entry.key)}:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(width: 8),
                Expanded(child: Text(entry.value.toString(), style: TextStyle(fontSize: 14))),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  String _getLabel(String key) {
    // Mapping of keys to their corresponding labels
    final Map<String, String> labelMap = {
      'city_id': 'City ID',
      'city_name': 'City',
      'country_code': 'Country Code',
      'clouds': 'Clouds',
      'datetime': 'Date Time',
      'dewpt': 'Dew Point',
      'dhi': 'Diffuse Horizontal Irradiance',
      'dni': 'Direct Normal Irradiance',
      'ghi': 'Global Horizontal Irradiance',
      'max_dhi': 'Max Diffuse Horizontal Irradiance',
      'max_dni': 'Max Direct Normal Irradiance',
      'max_ghi': 'Max Global Horizontal Irradiance',
      'max_temp': 'Max Temperature',
      'max_temp_ts': 'Max Temperature Timestamp',
      'max_uv': 'Max UV',
      'max_wind_dir': 'Max Wind Direction',
      'max_wind_spd': 'Max Wind Speed',
      'max_wind_spd_ts': 'Max Wind Speed Timestamp',
      'min_temp': 'Min Temperature',
      'min_temp_ts': 'Min Temperature Timestamp',
      'precip': 'Precipitation',
      'precip_gpm': 'Precipitation GPM',
      'pres': 'Pressure',
      'revision_status': 'Revision Status',
      'rh': 'Relative Humidity',
      'slp': 'Sea Level Pressure',
      'snow': 'Snow',
      'snow_depth': 'Snow Depth',
      'solar_rad': 'Solar Radiation',
      't_dhi': 'Total Diffuse Horizontal Irradiance',
      't_dni': 'Total Direct Normal Irradiance',
      't_ghi': 'Total Global Horizontal Irradiance',
      't_solar_rad': 'Total Solar Radiation',
      'temp': 'Temperature',
      'ts': 'Timestamp',
      'wind_dir': 'Wind Direction',
      'wind_gust_spd': 'Wind Gust Speed',
      'wind_spd': 'Wind Speed',
      'lat': 'Latitude',
      'lon': 'Longitude',
      'sources': 'Sources',
      'state_code': 'State Code',
      'station_id': 'Station ID',
      'timezone': 'Timezone',
    };
    return labelMap[key] ?? key; // If key not found in map, use the original key
  }
}
