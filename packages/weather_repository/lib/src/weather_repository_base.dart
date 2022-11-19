import 'package:open_meteo_api/open_meteo_api.dart' hide Weather;
import 'package:weather_repository/weather_repository.dart';

/// The goal of repository layer is to create an interface which
/// abstract the data layer.
///
/// This class has a dependency on open_meteo_api and expose a
/// method get weather of given city.
/// Consumers of the [WeatherRepository] are not privy to the
/// underlying implementation details such as the fact that two
/// network requests are made to the metaweather API.
/// The goal of [WeatherRepository] is to separate the `What` from
/// the `How` --  in other words, we want to have a way to fetch
/// weather for a given city, but don't care about how or where
/// that data is coming from.
class WeatherRepository {
  WeatherRepository([OpenMeteoClientApi? weatherApi])
      : _weatherApi = weatherApi ?? OpenMeteoClientApi();

  final OpenMeteoClientApi _weatherApi;

  Future<Weather> getWeather(String cityName) async {
    final location = await _weatherApi.locationSearch(cityName);
    final weather =
        await _weatherApi.getWeather(location.latitude, location.longitude);
    return Weather(
        temperature: weather.temperature,
        condition: weather.weatherCode.toInt().toCondition,
        location: cityName);
    throw UnimplementedError();
  }
}

extension on int {
  WeatherCondition get toCondition {
    switch (this) {
      case 0:
        return WeatherCondition.clear;
      case 1:
      case 2:
      case 3:
      case 45:
      case 48:
        return WeatherCondition.cloudy;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
      case 95:
      case 96:
      case 99:
        return WeatherCondition.rainy;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return WeatherCondition.snowy;
      default:
        return WeatherCondition.unknown;
    }
  }
}
