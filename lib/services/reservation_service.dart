import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/constants.dart';

class ReservationService {
  final String token;
  final IO.Socket _socket;

  ReservationService(this.token)
      : _socket = IO.io(
    baseUrl,
    IO.OptionBuilder().setTransports(['websocket']).build(),
  ) {
    _socket.connect();
  }

  Future<String> reserveSeat(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reservations/reserve'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al reservar asiento');
    }

    final responseData = json.decode(response.body);
    _socket.emit('seat_reserved', data);
    return responseData['reservationId']; // Retorna el ID de la reserva
  }

  Future<void> confirmReservation(String reservationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reservations/confirm/$reservationId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al confirmar la reserva');
    }
  }

  Future<void> cancelReservation(String reservationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/reservations/cancel/$reservationId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al cancelar la reserva');
    }
  }

  void listenToSeatUpdates(Function(Map<String, dynamic>) callback) {
    _socket.on('seat_reserved', (data) {
      callback(data);
    });
  }
}
