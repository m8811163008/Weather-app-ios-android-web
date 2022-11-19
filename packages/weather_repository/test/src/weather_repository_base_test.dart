import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart' as open_meteo_api;
import 'package:test/test.dart';
import 'package:weather_repository/src/models/models.dart';
import 'package:weather_repository/src/weather_repository_base.dart';

class MockOpenMeteoApi extends Mock
    implements open_meteo_api.OpenMeteoClientApi {}

class MockLocation extends Mock implements open_meteo_api.Location {}

class MockWeather extends Mock implements open_meteo_api.Weather {}

void main() {
  late final MockOpenMeteoApi mockOpenMeteoApi;
  late final WeatherRepository sut;

  setUpAll(() {
    mockOpenMeteoApi = MockOpenMeteoApi();
    sut = WeatherRepository(mockOpenMeteoApi);
  });

  group('WeatherRepository', () {
    group('Constructor', () {
      test(
          'Instantiates the internal state of weather repository when it is not injected',
          () {
        expect(WeatherRepository(), isNotNull);
      });
    });
    group('getWeather', () {
      final city = 'Tehran';
      final longitude = 1.123;
      final latitude = 1.235;

      test('calls open meteo api with correct city', () async {
        try {
          await sut.getWeather(city);
        } catch (_) {}
        verify(() => mockOpenMeteoApi.locationSearch(city)).called(1);
      });

      test('throws when locationSearch fails', () async {
        final exception = Exception('opps');
        when(() => mockOpenMeteoApi.locationSearch(any<String>()))
            .thenThrow(exception);
        expect(() async => sut.getWeather(city), throwsA(exception));
      });

      test('calls with correct longitude and latitude', () async {
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => mockOpenMeteoApi.locationSearch(any<String>()))
            .thenAnswer((_) async => location);
        try {
          await sut.getWeather(city);
        } catch (_) {}
        verify(() => mockOpenMeteoApi.getWeather(latitude, longitude))
            .called(1);
      });

      test('throws when getWeather fails', () {
        final exception = Exception('abc');
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => mockOpenMeteoApi.locationSearch(any<String>()))
            .thenAnswer((_) async => location);
        when(() => mockOpenMeteoApi.getWeather(any<double>(), any<double>()))
            .thenThrow(exception);
        expect(() async => sut.getWeather(city), throwsA(exception));
      });

      test('returns correct weather(clear)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.longitude).thenReturn(longitude);
        when(() => location.latitude).thenReturn(latitude);
        when(() => weather.temperature).thenReturn(43.0);
        when(() => weather.weatherCode).thenReturn(0.0);
        when(() => mockOpenMeteoApi.locationSearch(any<String>()))
            .thenAnswer((_) async => location);
        when(() => mockOpenMeteoApi.getWeather(any<double>(), any<double>()))
            .thenAnswer((_) async => weather);

        final actual = await sut.getWeather(city);

        expect(
            actual,
            isA<Weather>()
                .having((p0) => p0.location, 'location', city)
                .having((p0) => p0.temperature, 'temperature', 43.0)
                .having(
                    (p0) => p0.condition, 'condition', WeatherCondition.clear));
      });

      test('returns correct weather(snowy)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.longitude).thenReturn(longitude);
        when(() => location.latitude).thenReturn(latitude);
        when(() => weather.temperature).thenReturn(43.0);
        when(() => weather.weatherCode).thenReturn(73.0);
        when(() => mockOpenMeteoApi.locationSearch(any<String>()))
            .thenAnswer((_) async => location);
        when(() => mockOpenMeteoApi.getWeather(any<double>(), any<double>()))
            .thenAnswer((_) async => weather);

        final actual = await sut.getWeather(city);

        expect(
            actual,
            isA<Weather>()
                .having((p0) => p0.location, 'location', city)
                .having((p0) => p0.temperature, 'temperature', 43.0)
                .having(
                    (p0) => p0.condition, 'condition', WeatherCondition.snowy));
      });

      test('returns correct weather(unknown)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.longitude).thenReturn(longitude);
        when(() => location.latitude).thenReturn(latitude);
        when(() => weather.temperature).thenReturn(43.0);
        when(() => weather.weatherCode).thenReturn(-1);
        when(() => mockOpenMeteoApi.locationSearch(any<String>()))
            .thenAnswer((_) async => location);
        when(() => mockOpenMeteoApi.getWeather(any<double>(), any<double>()))
            .thenAnswer((_) async => weather);

        final actual = await sut.getWeather(city);

        expect(
            actual,
            isA<Weather>()
                .having((p0) => p0.location, 'location', city)
                .having((p0) => p0.temperature, 'temperature', 43.0)
                .having((p0) => p0.condition, 'condition',
                    WeatherCondition.unknown));
      });
    });
  });
}
