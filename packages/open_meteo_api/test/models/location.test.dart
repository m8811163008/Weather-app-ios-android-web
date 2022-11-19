import 'dart:convert';

import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:test/scaffolding.dart';
import 'package:test/test.dart';

import '../fixtures/fixture.dart';

void main() {
  group('fromJson', () {
    test('should return a Location from a given json text', () {
      final jsonText = fixture('location.text');
      final matcher = Location(
          id: 6683528, name: 'Tehrān', latitude: 35.75, longitude: 51.5148);
      final actual = Location.fromJson(jsonDecode(jsonText));
      expect(
        actual,
        isA<Location>()
            .having((p0) => p0.id, 'id', 6683528)
            .having((p0) => p0.latitude, 'latitude', 35.75)
            .having((p0) => p0.longitude, 'longitude', 51.5148),
      );
    });
  });
}
