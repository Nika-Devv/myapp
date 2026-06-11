import 'package:dio/dio.dart';
import '../models/weather_forecast.dart';

class WeatherController {
  static const String _baseUrl = 'http://10.10.1.149:5049';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<List<WeatherForecast>> fetchWeatherForecasts() async {
    try {
      final response = await _dio.get('/WeatherForecast');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => WeatherForecast.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to load weather data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print(e);
      throw Exception(
        'Error connecting to API: ${e.message}',
      );
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}