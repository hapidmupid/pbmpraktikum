import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';
import '../models/login_response.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  // ─── Token Management ───────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ─── Auth Headers ───────────────────────────────────────────────────

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─── Login ──────────────────────────────────────────────────────────

  static Future<LoginResponse> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(body);
      if (loginResponse.token != null) {
        await saveToken(loginResponse.token!);
      }
      return loginResponse;
    } else {
      final message = body['message'] ?? 'Login gagal. Periksa kembali NIM Anda.';
      throw Exception(message);
    }
  }

  // ─── Get Products (FIXED) ───────────────────────────────────────────

  static Future<List<Product>> getProducts() async {
    final url = Uri.parse('$baseUrl/api/products');
    final headers = await _authHeaders();

    final response = await http.get(url, headers: headers);
    final body = jsonDecode(response.body);

    // Debug: print raw response
    print('GET /api/products status: ${response.statusCode}');
    print('GET /api/products response: $body');

    if (response.statusCode == 200) {
      // FIX: Handle response structure {success: true, data: {products: [...]}}
      if (body['success'] == true && body['data'] != null) {
        final data = body['data'];
        
        // Case 1: data is a Map with 'products' key
        if (data is Map<String, dynamic> && data.containsKey('products')) {
          final productsList = data['products'];
          if (productsList is List) {
            return productsList.map((item) => Product.fromJson(item)).toList();
          }
        }
        
        // Case 2: data is directly a List
        if (data is List) {
          return data.map((item) => Product.fromJson(item)).toList();
        }
        
        // Case 3: data is a single product object
        if (data is Map<String, dynamic>) {
          return [Product.fromJson(data)];
        }
      }
      
      // Fallback: try to handle if response body itself is List
      if (body is List) {
        return body.map((item) => Product.fromJson(item)).toList();
      }
      
      return [];
    } else {
      throw Exception(body['message'] ?? 'Gagal memuat produk.');
    }
  }

  // ─── Create Product (Draft) ─────────────────────────────────────────

  static Future<Product> createProduct({
    required String name,
    required int price,
    required String description,
  }) async {
    final url = Uri.parse('$baseUrl/api/products');
    final headers = await _authHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );

    final body = jsonDecode(response.body);
    print('POST /api/products response: $body');

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle response with {success: true, data: {...}}
      if (body['success'] == true && body['data'] != null) {
        return Product.fromJson(body['data']);
      }
      // Handle direct product object
      if (body['id'] != null) {
        return Product.fromJson(body);
      }
      return Product(name: name, price: price, description: description);
    } else {
      throw Exception(body['message'] ?? 'Gagal menambahkan produk.');
    }
  }

  // ─── Delete Product (Soft Delete) ───────────────────────────────────

  static Future<void> deleteProduct(int productId) async {
    final url = Uri.parse('$baseUrl/api/products/$productId');
    final headers = await _authHeaders();

    final response = await http.delete(url, headers: headers);
    final body = jsonDecode(response.body);

    print('DELETE /api/products/$productId response: $body');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(body['message'] ?? 'Gagal menghapus produk.');
    }
  }

  // ─── Submit Final Task (FIXED) ──────────────────────────────────────

  static Future<Map<String, dynamic>> submitTask({
    required String name,
    required int price,
    required String description,
    required String githubUrl,
  }) async {
    final url = Uri.parse('$baseUrl/api/products/submit');
    final headers = await _authHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );

    final body = jsonDecode(response.body);
    print('POST /api/products/submit response: $body');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'Gagal submit tugas.');
    }
  }

  // ─── Logout ─────────────────────────────────────────────────────────

  static Future<void> logout() async {
    await deleteToken();
  }
}