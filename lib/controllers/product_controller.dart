import 'package:dio/dio.dart';
import '../models/product.dart';

class ProductController {
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

  /// Fetches the list of active products using the provided [token]
  Future<List<Product>> fetchActiveProducts(String token) async {
    try {
      final response = await _dio.post(
        '/api/app/product/list',
        data: {},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData is Map<String, dynamic> && responseData['data'] != null) {
          final List<dynamic> dataList = responseData['data'];
          return dataList.map((item) => Product.fromJson(item)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception("Failed to fetch products: ${response.statusCode}");
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

  Future<void> createProduct(Product product, String token) async {
    try {
      final response = await _dio.post(
        '/api/app/product/create',
        data: product.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to create product: ${response.statusCode}");
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

  Future<void> updateProduct(Product product, String token) async {
    try {
      final response = await _dio.post(
        '/api/app/product/update',
        data: product.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update product: ${response.statusCode}");
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
