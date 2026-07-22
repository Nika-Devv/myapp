import 'package:dio/dio.dart';

class AuthController {
  // Use your computer's local Wi-Fi IP address so physical devices and emulators can connect
  static const String _baseUrl = 'http://10.10.1.152:30033';

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

  /// Attempts to log in with [username] and [password].
  /// Returns the access token if successful, or throws an exception on failure.
  Future<String> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/oauth/token',
        data: {
          'phoneNumber': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['accessToken'] != null) {
          return data['accessToken'];
        } else {
          throw Exception("Invalid response format: Missing access token");
        }
      } else {
        throw Exception("Login failed. Status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Server Error: ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        throw Exception("Network error: ${e.message}");
      }
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}
