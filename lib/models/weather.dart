class Weather {
  final double temperature;
  final double? feelsLikeTemperature;
  final String? precipitationType;
  final String? precipitationAmount;
  final double? windSpeed;
  final String? windDirection;
  final double? humidity;
  final double? chanceOfRain;
  final double? aqi;
  final double? uvIndex;
  final double? pressure;
  final double? visibility;
  final String? sunriseTime;
  final String? sunsetTime;
  final DateTime? time;
  final String? locationName;
  final String? zone;
  final double? latitude; // Latitude property
  final double? longitude; // Longitude property
  final String? weatherIconCode; // Weather icon code property

  Weather({
    required this.temperature,
    this.feelsLikeTemperature,
    this.precipitationType,
    this.precipitationAmount,
    this.windSpeed,
    this.windDirection,
    this.humidity,
    this.chanceOfRain,
    this.aqi,
    this.uvIndex,
    this.pressure,
    this.visibility,
    this.sunriseTime,
    this.sunsetTime,
    this.time,
    this.locationName,
    this.zone,
    this.latitude,
    this.longitude,
    this.weatherIconCode, // Include weather icon code property
  });

  static Weather fromJson(Map<String, dynamic> data) {
    return Weather(
      temperature: data['temp']?.toDouble() ?? 0.0,
      feelsLikeTemperature: data['app_temp']?.toDouble() ?? 0.0,
      precipitationType: data['weather']['description'] ?? '',
      precipitationAmount: data['precip']?.toString() ?? '',
      windSpeed: data['wind_spd']?.toDouble() ?? 0.0,
      windDirection: data['wind_cdir'] ?? '',
      humidity: data['rh']?.toDouble() ?? 0.0,
      chanceOfRain: data['pop']?.toDouble() ?? 0.0,
      aqi: data['aqi']?.toDouble() ?? 0.0,
      uvIndex: data['uv']?.toDouble()  ?? 0.0,
      pressure: data['pres']?.toDouble() ?? 0.0,
      visibility: data['vis']?.toDouble() ?? 0.0,
      sunriseTime: data['sunrise'] ?? '',
      sunsetTime: data['sunset'] ?? '',
      locationName: data['city_name'] ?? '',
      zone: data['timezone'] ?? '',
      latitude: data['lat']?.toDouble() ?? 0.0,
      longitude: data['lon']?.toDouble() ?? 0.0,
      weatherIconCode: data['weather']['icon'] ?? '',
      time: data['ob_time'] != null ? DateTime.parse(data['ob_time']) : null,
    );
  }

}