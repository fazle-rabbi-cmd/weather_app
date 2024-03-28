import 'package:flutter/material.dart';

enum AirQuality { good, moderate, unhealthyForSensitiveGroups, unhealthy, veryUnhealthy, hazardous }
enum UVIndex { low, moderate, high, veryHigh, extreme }

class RecommendationWidget extends StatelessWidget {
  final double airQualityIndex;
  final double uvIndex;

  RecommendationWidget({required this.airQualityIndex, required this.uvIndex});

  @override
  Widget build(BuildContext context) {
    AirQuality airQuality = _getAirQuality(airQualityIndex);
    UVIndex uvindex = _getUVIndex(uvIndex);

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Recommendations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            'Air Quality Protection: \n${_getAirQualityRecommendation(airQuality)}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8.0),
          Text(
            'Sun Protection: \n${_getUVRecommendation(uvindex)}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  AirQuality _getAirQuality(double index) {
    if (index >= 0 && index <= 50) return AirQuality.good;
    if (index > 50 && index <= 100) return AirQuality.moderate;
    if (index > 100 && index <= 150) return AirQuality.unhealthyForSensitiveGroups;
    if (index > 150 && index <= 200) return AirQuality.unhealthy;
    if (index > 200 && index <= 300) return AirQuality.veryUnhealthy;
    return AirQuality.hazardous;
  }

  UVIndex _getUVIndex(double index) {
    if (index >= 0 && index <= 2) return UVIndex.low;
    if (index > 2 && index <= 5) return UVIndex.moderate;
    if (index > 5 && index <= 7) return UVIndex.high;
    if (index > 7 && index <= 10) return UVIndex.veryHigh;
    return UVIndex.extreme;
  }

  String _getAirQualityRecommendation(AirQuality airQuality) {
    switch (airQuality) {
      case AirQuality.good: return 'Air quality is good. Enjoy outdoor activities.';
      case AirQuality.moderate: return 'Air quality is moderate. Sensitive individuals should consider reducing prolonged or heavy outdoor exertion.';
      case AirQuality.unhealthyForSensitiveGroups: return 'Air quality is unhealthy for sensitive groups. People with respiratory or heart conditions, children, and older adults should reduce prolonged or heavy outdoor exertion.';
      case AirQuality.unhealthy: return 'Air quality is unhealthy. Everyone should reduce prolonged or heavy outdoor exertion.';
      case AirQuality.veryUnhealthy: return 'Air quality is very unhealthy. Avoid outdoor activities and stay indoors as much as possible.';
      case AirQuality.hazardous: return 'Air quality is hazardous. Avoid outdoor activities and stay indoors.';
      default: return '';
    }
  }

  String _getUVRecommendation(UVIndex uvIndex) {
    switch (uvIndex) {
      case UVIndex.low: return 'UV index is low. Minimal protection required.';
      case UVIndex.moderate: return 'UV index is moderate. Wear sunglasses and use sunscreen.';
      case UVIndex.high: return 'UV index is high. Wear protective clothing, sunglasses, and apply sunscreen.';
      case UVIndex.veryHigh: return 'UV index is very high. Take extra precautions - use sunscreen, wear protective clothing, and limit sun exposure between 10 AM and 4 PM.';
      case UVIndex.extreme: return 'UV index is extreme. Avoid being outside during midday hours, seek shade, and protect yourself with clothing, a wide-brimmed hat, and sunglasses.';
      default: return '';
    }
  }
}
