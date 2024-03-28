import 'package:flutter/material.dart';
import 'package:mine/models/weather.dart';

class DailyForecastWidget extends StatefulWidget {
  final List<Weather> dailyForecast;

  const DailyForecastWidget({Key? key, required this.dailyForecast}) : super(key: key);

  @override
  _DailyForecastWidgetState createState() => _DailyForecastWidgetState();
}

class _DailyForecastWidgetState extends State<DailyForecastWidget> {
  bool _isCelsius = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Forecast',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              IconButton(
                icon: Icon(Icons.swap_horiz),
                onPressed: () => setState(() => _isCelsius = !_isCelsius),
              ),
            ],
          ),
          SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.dailyForecast
                  .map((weather) => _buildForecastCard(weather, DateTime.now().add(Duration(days: widget.dailyForecast.indexOf(weather)))))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(Weather weather, DateTime forecastDate) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatDate(forecastDate)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              if (_getPrecipitationIcon(weather.precipitationType) != null)
                _buildWeatherIcon(_getPrecipitationIcon(weather.precipitationType)!),
              SizedBox(width: 8),
              Text(
                _isCelsius ? '${weather.temperature.toStringAsFixed(1)}°C' : '${_celsiusToFahrenheit(weather.temperature).toStringAsFixed(1)}°F',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Condition: ${weather.precipitationType}',
            style: TextStyle(color: Colors.grey[800], fontSize: 16),
          ),
        ],
      ),
    );
  }

  double _celsiusToFahrenheit(double celsius) => (celsius * 9 / 5) + 32;

  String _formatDate(DateTime date) => '${_getWeekday(date.weekday)}, ${date.day}/${date.month}';

  String _getWeekday(int weekday) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[(weekday - 1) % 7];
  }

  String? _getPrecipitationIcon(String? precipitationType) {
    if (precipitationType != null) {
      switch (precipitationType.toLowerCase()) {
        case 'thunderstorm with light rain':
          return 'https://www.weatherbit.io/static/img/icons/t01d.png'; // Replace with rain icon URL
        case 'thunderstorm with rain':
          return 'https://www.weatherbit.io/static/img/icons/t02d.png';
        case 'thunderstorm with heavy rain':
          return 'https://www.weatherbit.io/static/img/icons/t03d.png';
        case 'thunderstorm with light drizzle':
          return 'https://www.weatherbit.io/static/img/icons/t04d.png'; // Replace with rain icon URL
        case 'thunderstorm with drizzle':
          return 'https://www.weatherbit.io/static/img/icons/t04d.png';
        case 'thunderstorm with heavy drizzle':
          return 'https://www.weatherbit.io/static/img/icons/t04d.png';
        case 'thunderstorm with Hail':
          return 'https://www.weatherbit.io/static/img/icons/t05d.png'; // Replace with rain icon URL
        case 'light Drizzle':
          return 'https://www.weatherbit.io/static/img/icons/d01d.png';
        case 'drizzle':
          return 'https://www.weatherbit.io/static/img/icons/d02d.png';
        case 'heavy drizzle':
          return 'https://www.weatherbit.io/static/img/icons/d03d.png'; // Replace with rain icon URL
        case 'light rain':
          return 'https://www.weatherbit.io/static/img/icons/r01d.png';
        case 'moderate rain':
          return 'https://www.weatherbit.io/static/img/icons/r02d.png';
        case 'heavy rain':
          return 'https://www.weatherbit.io/static/img/icons/r03d.png'; // Replace with rain icon URL
        case 'freezing rain':
          return 'https://www.weatherbit.io/static/img/icons/f01d.png';
        case 'light shower rain':
          return 'https://www.weatherbit.io/static/img/icons/r04d.png';
        case 'shower rain':
          return 'https://www.weatherbit.io/static/img/icons/r05d.png'; // Replace with rain icon URL
        case 'heavy shower rain':
          return 'https://www.weatherbit.io/static/img/icons/r06d.png';
        case 'light snow':
          return 'https://www.weatherbit.io/static/img/icons/s01d.png';
        case 'snow':
          return 'https://www.weatherbit.io/static/img/icons/s02d.png'; // Replace with rain icon URL
        case 'heavy snow':
          return 'https://www.weatherbit.io/static/img/icons/s03d.png';
        case 'mix snow/rain':
          return 'https://www.weatherbit.io/static/img/icons/s04d.png';
        case 'sleet':
          return 'https://www.weatherbit.io/static/img/icons/s05d.png'; // Replace with rain icon URL
        case 'heavy sleet':
          return 'https://www.weatherbit.io/static/img/icons/s05d.png';
        case 'snow shower':
          return 'https://www.weatherbit.io/static/img/icons/s01d.png';
        case 'heavy snow shower':
          return 'https://www.weatherbit.io/static/img/icons/s02d.png';
        case 'flurries':
          return 'https://www.weatherbit.io/static/img/icons/s06d.png';
        case 'mist':
          return 'https://www.weatherbit.io/static/img/icons/a01d.png';
        case 'smoke':
          return 'https://www.weatherbit.io/static/img/icons/a02d.png';
        case 'haze':
          return 'https://www.weatherbit.io/static/img/icons/a03d.png';
        case '	sand/dust':
          return 'https://www.weatherbit.io/static/img/icons/a04d.png';
        case 'fog':
          return 'https://www.weatherbit.io/static/img/icons/a05d.png';
        case 'freezing fog':
          return 'https://www.weatherbit.io/static/img/icons/a06d.png';
        case 'clear sky':
          return 'https://www.weatherbit.io/static/img/icons/c01d.png';
        case 'few clouds':
          return 'https://www.weatherbit.io/static/img/icons/c02d.png';
        case 'scattered clouds':
          return 'https://www.weatherbit.io/static/img/icons/c02d.png';
        case 'broken clouds':
          return 'https://www.weatherbit.io/static/img/icons/c03d.png';
        case 'overcast clouds':
          return 'https://www.weatherbit.io/static/img/icons/c04d.png';

      // Add more cases as needed for other precipitation types
        default:
          return null; // Return null for unknown types or when no icon is available
      }
    }
    return null;
  }

  Widget _buildWeatherIcon(String url) {
    return Image(
      image: NetworkImage(url),
      width: 50,
      height: 50,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
          );
        }
      },
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Icon(Icons.error),
    );
  }
}
