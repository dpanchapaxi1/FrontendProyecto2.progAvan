import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/section.dart';
import '../utils/constants.dart';

class SectionService {
  final String token;

  SectionService(this.token);

  Future<List<Section>> getAllSections() async {
    final response = await http.get(
      Uri.parse('$baseUrl/secciones/all'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((section) => Section.fromJson(section)).toList();
    } else {
      throw Exception('Error al obtener las secciones');
    }
  }
}
