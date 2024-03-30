import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mine/models/weather.dart';

class HourlyForecastWidget extends StatefulWidget {
  final List<Weather> hourlyForecast;

  const HourlyForecastWidget({
    Key? key,
    required this.hourlyForecast,
  }) : super(key: key);

  @override
  _HourlyForecastWidgetState createState() => _HourlyForecastWidgetState();
}

class _HourlyForecastWidgetState extends State<HourlyForecastWidget> {
  String _selectedElement = 'Temperature';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
          child: Text(
            'Hourly Forecast',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: DropdownButton<String>(
            value: _selectedElement,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedElement = newValue!;
              });
            },
            items: <String>['Temperature', 'Humidity', 'Pressure', 'Chance of Rain']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Card(
            elevation: 4,
            child: Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  lineBarsData: _generateLineChartBarData(),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blue.withOpacity(0.8),
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final index = barSpot.x.toInt();
                          final weather = widget.hourlyForecast[index];
                          return LineTooltipItem(
                            '${_formatValue(weather, _selectedElement)}',
                            TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  minY: 0,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (_selectedElement == 'Temperature')
                Icon(Icons.thermostat, color: Colors.blue, size: 16),
              if (_selectedElement == 'Humidity')
                Icon(Icons.water_drop, color: Colors.blue, size: 16),
              if (_selectedElement == 'Pressure')
                Icon(Icons.bar_chart, color: Colors.blue, size: 16),
              if (_selectedElement == 'Chance of Rain')
                Icon(Icons.umbrella, color: Colors.blue, size: 16),
              SizedBox(width: 4),
              Text(_selectedElement, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatValue(Weather weather, String element) {
    switch (element) {
      case 'Temperature':
        return '${weather.temperature.toStringAsFixed(1)} °C';
      case 'Humidity':
        return '${weather.humidity ?? 'N/A'}%';
      case 'Pressure':
        return '${weather.pressure ?? 'N/A'} hPa';
      case 'Chance of Rain':
        return '${weather.chanceOfRain ?? 'N/A'}%';
      default:
        return 'N/A';
    }
  }

  List<LineChartBarData> _generateLineChartBarData() {
    return [
      LineChartBarData(
        spots: _generateSpots(widget.hourlyForecast, _selectedElement),
        isCurved: true,
        color: Colors.blue,
        barWidth: 4,
        dotData: FlDotData(show: false),
      ),
    ];
  }

  List<FlSpot> _generateSpots(List<Weather> hourlyForecast, String element) {
    return hourlyForecast.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final weather = entry.value;
      double value;
      switch (element) {
        case 'Temperature':
          value = weather.temperature;
          break;
        case 'Humidity':
          value = weather.humidity ?? 0;
          break;
        case 'Pressure':
          value = weather.pressure ?? 0;
          break;
        case 'Chance of Rain':
          value = weather.chanceOfRain ?? 0;
          break;
        default:
          value = 0;
      }
      return FlSpot(index, value);
    }).toList();
  }
}
