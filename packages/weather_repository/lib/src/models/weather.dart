import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather.g.dart';

enum WeatherCondition {
  clear,
  rainy,
  cloudy,
  snowy,
  unknown,
}

/// The weather model for business cases.
@JsonSerializable()
class Weather extends Equatable {
  final double temperature;
  final WeatherCondition condition;
  final String location;

  const Weather({
    required this.temperature,
    required this.condition,
    required this.location,
  });

  @override
  List<Object> get props => [temperature, condition, location];

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);
}
