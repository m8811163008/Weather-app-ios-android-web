import 'package:test/test.dart';
import 'package:weather_repository/src/models/models.dart';

void main() {
  setUp(() {});
  test('returns correct Weather object', () {
    expect(
      Weather.fromJson(
        <String, dynamic>{
          'temperature': 30,
          'condition': 'snowy',
          'location': 'Tehran',
        },
      ),
      isA<Weather>()
          .having((w) => w.temperature, 'temperature', 30)
          .having((w) => w.condition, 'condition', WeatherCondition.snowy)
          .having((w) => w.location, 'condition', 'Tehran'),
    );
  });
}
