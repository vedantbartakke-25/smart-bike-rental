// services/api_service.dart — Centralized HTTP client for backend API calls
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Change this to your machine's IP when testing on a physical device
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator → localhost

  static const _storage = FlutterSecureStorage();

  // ── Token helpers ────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<void> saveUserId(int id) async {
    await _storage.write(key: 'user_id', value: id.toString());
  }

  static Future<int?> getUserId() async {
    final val = await _storage.read(key: 'user_id');
    return val != null ? int.tryParse(val) : null;
  }

  static Future<void> clearToken() async {
    await _storage.deleteAll();
  }

  // ── Authorization header helper ──────────────────────────────
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ────────────────────────────────────────────────────────────
  // AUTH
  // ────────────────────────────────────────────────────────────

  /// Register a new user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'phone': phone, 'password': password}),
    );
    return _handleResponse(response);
  }

  /// Login with email + password, returns JWT token
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  // ────────────────────────────────────────────────────────────
  // BIKES
  // ────────────────────────────────────────────────────────────

  /// Get all available bikes
  static Future<List<dynamic>> getAllBikes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bikes'),
      headers: await _authHeaders(),
    );
    final data = _handleResponse(response);
    return data['bikes'] as List<dynamic>;
  }

  /// Get single bike by ID
  static Future<Map<String, dynamic>> getBikeById(int bikeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bikes/$bikeId'),
      headers: await _authHeaders(),
    );
    final data = _handleResponse(response);
    return data['bike'] as Map<String, dynamic>;
  }

  // ────────────────────────────────────────────────────────────
  // BOOKINGS
  // ────────────────────────────────────────────────────────────

  /// Create a new booking
  static Future<Map<String, dynamic>> createBooking({
    required int bikeId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'bike_id': bikeId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      }),
    );
    return _handleResponse(response);
  }

  /// Get bookings for a specific user
  static Future<List<dynamic>> getUserBookings(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/user/$userId'),
      headers: await _authHeaders(),
    );
    final data = _handleResponse(response);
    return data['bookings'] as List<dynamic>;
  }

  // ────────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────────

  /// Parse HTTP response; throw on error
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw Exception(body['error'] ?? 'Request failed (${response.statusCode})');
  }
}
