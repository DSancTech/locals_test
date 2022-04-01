import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:locals_test/user.dart';

/// Locals Test API calls
class LocalsApi {
  static const baseURL = 'https://app-test.rr-qa.seasteaddigital.com';
  static const loginURL = baseURL + '/app_api/auth.php';
  static const feedURL = baseURL + '/api/v1/posts/feed/global.json';

  Future<LocalsUser> login(String email, String password, String id) async {
    final response = await http.post(
      Uri.parse(loginURL),
      body: <String, String>{
        'email': email,
        'password': password,
        'device_id': id,
      },
    );
    if (response.statusCode == 200) {
      return LocalsUser.fromJson(jsonDecode(response.body)['result']);
    } else {
      throw Exception('Login Failed.');
    }
  }

  Future<List<dynamic>> getFeed(String auth, String id, String order, int lastPageId) async {
    final response = await http.post(
      Uri.parse(feedURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-APP-AUTH-TOKEN': auth,
        'X-DEVICE-ID': id,
      },
      body: jsonEncode({
        'data': {
          'page_size': 10,
          'order': order.toLowerCase(),
          'lpid': lastPageId,
        }
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Error Loading Feed.');
    }
  }
}

/// Test Constants which were provided.
class LocalsTestConstants {
  final String email = 'testlocals0@gmail.com';
  final String password = 'jahubhsgvd23';
  final String deviceID = '7789e3ef-c87f-49c5-a2d3-5165927298f0';
  final List<String> feedOrder = ['Recent', 'Oldest'];
}