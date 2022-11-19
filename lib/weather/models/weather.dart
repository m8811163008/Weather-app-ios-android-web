import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

part 'weather.g.dart';

enum TemperatureUnits { Celsius, Fahrenheit }

extension TemperatureUnitsX on TemperatureUnits {
  bool get isCelsius => this == TemperatureUnits.Celsius;

  bool get isFahrenheit => this == TemperatureUnits.Fahrenheit;
}

@JsonSerializable()
class Temperature extends Equatable {
  factory Temperature.fromJson(Map<String, dynamic> json) =>
      _$TemperatureFromJson(json);
  final double value;

  const Temperature({required this.value});

  Map<String, dynamic> toJson() => _$TemperatureToJson(this);

  @override
  List<Object> get props => [value];
}

/// The goal of our weather model is to keep track of weather data
/// displayed by our app, as well as temperature settings( Celsius
/// or Fahrenheit).
@JsonSerializable()
class Weather extends Equatable {
  const Weather({
    required this.condition,
    required this.temperature,
    required this.lastUpdate,
    required this.location,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  factory Weather.fromRepository(weather_repository.Weather weather) {
    return Weather(
        condition: weather.condition,
        temperature: Temperature(value: weather.temperature),
        lastUpdate: DateTime.now(),
        location: weather.location);
  }

  static Weather empty = Weather(
      condition: WeatherCondition.unknown,
      temperature: Temperature(value: 0),
      lastUpdate: DateTime(0),
      location: '--');

  final WeatherCondition condition;
  final Temperature temperature;
  final DateTime lastUpdate;
  final String location;

  @override
  List<Object> get props => [condition, temperature, lastUpdate, location];

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  Weather copyWith({
    WeatherCondition? condition,
    Temperature? temperature,
    DateTime? lastUpdate,
    String? location,
  }) {
    return Weather(
      condition: condition ?? this.condition,
      temperature: temperature ?? this.temperature,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      location: location ?? this.location,
    );
  }
}
