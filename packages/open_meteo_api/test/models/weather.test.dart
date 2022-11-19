import 'dart:convert';

import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:test/scaffolding.dart';
import 'package:test/test.dart';

import '../fixtures/fixture.dart';

void main() {
  test('fromJson', () {
    // final String response = fixture('weather_fixture.json');
    final matcher = Weather(temperature: 15.7, weatherCode: 0);
    //act
    final actual = Weather.fromJson(jsonDecode(fixture('weather.json')));
    //verify interactions with mockObjects

    //assert
    expect(actual, equals(matcher));
  });
}
