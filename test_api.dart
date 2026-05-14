import 'dart:convert';
import 'dart:io';

// Ganti NIM_ANDA dengan NIM kamu yang sebenarnya
const String nim = '123456789';

void main() async {
  final client = HttpClient();

  // 1. Login
  print('=== LOGIN ===');
  final loginReq = await client.postUrl(
      Uri.parse('https://task.itprojects.web.id/api/auth/login'));
  loginReq.headers.set('Content-Type', 'application/json');
  loginReq.headers.set('Accept', 'application/json');
  loginReq.write(jsonEncode({'username': nim, 'password': nim}));
  final loginRes = await loginReq.close();
  final loginBody = await loginRes.transform(utf8.decoder).join();
  print('Status: ${loginRes.statusCode}');
  print('Login Response: $loginBody');

  if (loginRes.statusCode != 200) {
    print('Login gagal, coba ganti NIM di script ini.');
    exit(0);
  }

  final loginJson = jsonDecode(loginBody);
  print('\nLogin JSON keys: ${loginJson.keys.toList()}');
  if (loginJson['data'] != null) {
    print('data keys: ${(loginJson['data'] as Map).keys.toList()}');
  }

  final token = loginJson['data']?['token'] ?? '';
  if (token.isEmpty) {
    print('No token found');
    exit(0);
  }

  // 2. Get Products
  print('\n=== GET PRODUCTS ===');
  final getReq = await client
      .getUrl(Uri.parse('https://task.itprojects.web.id/api/products'));
  getReq.headers.set('Accept', 'application/json');
  getReq.headers.set('Authorization', 'Bearer $token');
  final getRes = await getReq.close();
  final getBody = await getRes.transform(utf8.decoder).join();
  print('Status: ${getRes.statusCode}');
  print('Products Response: $getBody');

  final getJson = jsonDecode(getBody);
  print('\nResponse keys: ${getJson.keys.toList()}');
  if (getJson['data'] != null) {
    final data = getJson['data'];
    print('data type: ${data.runtimeType}');
    if (data is Map) {
      print('data keys: ${data.keys.toList()}');
      if (data['data'] != null) {
        print('data.data type: ${data['data'].runtimeType}');
        if (data['data'] is List && (data['data'] as List).isNotEmpty) {
          print('First item keys: ${(data['data'][0] as Map).keys.toList()}');
          print('First item: ${data['data'][0]}');
        }
      }
    } else if (data is List) {
      print('data is List with ${data.length} items');
      if (data.isNotEmpty) {
        print('First item keys: ${(data[0] as Map).keys.toList()}');
        print('First item: ${data[0]}');
      }
    }
  }

  client.close();
}
