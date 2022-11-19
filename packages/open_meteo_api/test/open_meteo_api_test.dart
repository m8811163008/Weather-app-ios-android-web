import 'dart:io';

import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:open_meteo_api/src/open_meteo_client_api.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'fixtures/fixture.dart';

class MockHttpClient extends Mock implements Client {}

class MockUri extends Mock implements Uri {}

void main() {
  late final MockHttpClient mockClient;
  late final OpenMeteoClientApi sut;
  const tName = 'tehran';
  const authority = 'geocoding-api.open-meteo.com';
  setUpAll(() {
    mockClient = MockHttpClient();
    sut = OpenMeteoClientApi(mockClient);
    registerFallbackValue(MockUri());
  });
  group('locationSearch', () {
    // v1/search/?name=(query)

    test('should return a Location when call to api status code is 200',
        () async {
      //arrange
      final matcherLocation = Location(
          id: 112931, name: 'Tehran', latitude: 35.69439, longitude: 51.42151);
      // final actualUri = Uri.parse('$domain/v1/search/?name=$tName&count=1');
      final uri =
          Uri.https(authority, '/v1/search', {'name': 'tehran', 'count': '1'});

      final response = Response(fixture('search_fixture.json'), 200, headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
      });

      when(() => mockClient.get(any())).thenAnswer((_) async => response);

      //act
      final actualLocation = await sut.locationSearch(tName);

      //verify interactions with mockObjects
      verify(() => mockClient.get(uri)).called(1);

      //assert
      expect(actualLocation, matcherLocation);
    });

    test(
        'should return a SyntaxException when call to api status code is 200 but result is empty',
        () async {
      //arrange
      final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search',
          {'name': 'tehran', 'count': '1'});
      final response = Response(fixture('not_found_location.json'), 200,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
          });

      when(() => mockClient.get(any())).thenAnswer((_) async => response);

      //assert
      await expectLater(
          sut.locationSearch(tName), throwsA(isA<LocationNotFoundException>()));

      //verify interactions with mockObjects
      verify(() => mockClient.get(uri)).called(1);
    });

    test(
        'should return a ServerException when call to api status code is not 200',
        () async {
      //arrange
      final response = Response(fixture('not_found_location.json'), 400,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
          });

      when(() => mockClient.get(any())).thenAnswer((_) async => response);

      //assert
      await expectLater(
          sut.locationSearch(tName), throwsA(isA<LocationRequestFailure>()));
    });
  });

  group('getWeather', () {
    const tLatitude = 35.69439;
    const tLongitude = 51.42151;

    const _baseUrlWeather = 'api.open-meteo.com';
    final tUri = Uri.https(_baseUrlWeather, '/v1/forecast', {
      'latitude': tLatitude.toString(),
      'longitude': tLongitude.toString(),
      'current_weather': 'true',
    });
    test('should return weather when call response code is 200', () async {
      final tResponse = Response(fixture('weather_fixture.json'), 200);
      final matcherWeather = Weather(temperature: 15.7, weatherCode: 0);
      //arrange
      when(() => mockClient.get(any()))
          .thenAnswer((invocation) async => tResponse);
      //act
      final actualWeather = await sut.getWeather(tLatitude, tLongitude);

      // verify

      verify(() => mockClient.get(tUri)).called(1);

      // assert
      expect(actualWeather, equals(matcherWeather));
    });
    test(
        'should throws WeatherRequestFailure when call response code is not 200',
        () async {
      //arrange
      final response = Response(fixture('not_found_location.json'), 200,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
          });
      when(() => mockClient.get(any())).thenAnswer((_) async => response);
      //assert
      await expectLater(sut.getWeather(tLatitude, tLongitude),
          throwsA(isA<WeatherNotFound>()));

      //verify interactions with mockObjects
      verify(() => mockClient.get(tUri)).called(1);
    });
    test(
        'should throws WeatherNotFound when call response code is 200 but response is empty',
        () async {
      //arrange
      final response = Response(fixture('not_found_location.json'), 400,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
          });

      when(() => mockClient.get(any())).thenAnswer((_) async => response);

      //assert
      await expectLater(sut.getWeather(tLatitude, tLongitude),
          throwsA(isA<WeatherRequestFailure>()));
    });
  });
}
