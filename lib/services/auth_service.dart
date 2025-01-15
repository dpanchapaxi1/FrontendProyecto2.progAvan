import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/constants.dart';

class AuthService {
  Future<User> login(String id, String nombre) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id, 'nombre': nombre}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson({
        'id': id,
        'nombre': nombre,
        'token': data['token'],
      });
    } else {
      throw Exception('Error al iniciar sesión');
    }
  }
}
