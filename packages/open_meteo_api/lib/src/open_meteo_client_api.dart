import 'dart:convert';

import 'package:http/http.dart';
import 'package:open_meteo_api/open_meteo_api.dart';

/// Exception thrown when location request fails.
class LocationRequestFailure implements Exception {}

/// Exception thrown when location is not found.
class LocationNotFoundException implements Exception {}

/// Exception thrown when weather requests fails with status code other than 200.
class WeatherRequestFailure implements Exception {}

/// Exception thrown when weather did not contain `current_weather` key.
class WeatherNotFound implements Exception {}

/// A class to get weather api
class OpenMeteoClientApi {
  Client _client;
  static const _baseUrlLocation = 'geocoding-api.open-meteo.com';
  static const _baseUrlWeather = 'api.open-meteo.com';

  OpenMeteoClientApi([Client? client]) : _client = client ?? Client();

  /// Finds a [Location] at `/v1/search/?name=(query)`.
  ///
  /// If can not find the location throws a [LocationNotFoundException].
  Future<Location> locationSearch(String query) async {
    // final uri = Uri.parse('$_domain/search/?name=$query');
    final uri = Uri.https(
        _baseUrlLocation, '/v1/search', {'name': query, 'count': '1'});
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw LocationRequestFailure();
    }
    final responseMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (!responseMap.containsKey('results')) throw LocationNotFoundException();
    final results = responseMap['results'] as List;
    if (results.isEmpty) throw LocationNotFoundException();
    return Location.fromJson(results.first);
  }

  Future<Weather> getWeather(double latitude, double longitude) async {
    final uri = Uri.https(_baseUrlWeather, '/v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current_weather': 'true'
    });
    final response = await _client.get(uri);
    if (response.statusCode != 200) throw WeatherRequestFailure();
    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    if (!responseJson.containsKey('current_weather')) throw WeatherNotFound();
    final weatherJson = responseJson['current_weather'] as Map<String, dynamic>;
    final weather = Weather.fromJson(weatherJson);
    return weather;
  }
}
