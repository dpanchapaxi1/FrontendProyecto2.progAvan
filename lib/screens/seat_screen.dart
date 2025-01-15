import 'package:flutter/material.dart';
import 'dart:async';
import '../models/section.dart';
import '../models/user.dart';
import '../services/reservation_service.dart';

class SeatScreen extends StatefulWidget {
  final User user;
  final Section section;

  SeatScreen({required this.user, required this.section});

  @override
  _SeatScreenState createState() => _SeatScreenState();
}

class _SeatScreenState extends State<SeatScreen> {
  final int rows = 4;
  final int columns = 5;
  List<List<bool>> seats = List.generate(4, (_) => List.generate(5, (_) => true));
  Map<String, Timer> reservationTimers = {};
  ReservationService? _reservationService;
  int dailyReservations = 0;
  final int maxDailyReservations = 5;

  @override
  void initState() {
    super.initState();
    _reservationService = ReservationService(widget.user.token);
    _reservationService!.listenToSeatUpdates(_updateSeatState);
  }

  void _updateSeatState(Map<String, dynamic> data) {
    setState(() {
      int row = int.parse(data['row']);
      int column = int.parse(data['column']);
      seats[row][column] = false;
    });
  }

  void _reserveSeat(int row, int column) async {
    if (dailyReservations >= maxDailyReservations) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solo puedes hacer $maxDailyReservations reservas por día.')),
      );
      return;
    }

    final reservationData = {
      'row': row.toString(),
      'column': column.toString(),
      'section': widget.section.id,
      'user': widget.user.id,
    };

    try {
      final reservationId = await _reservationService!.reserveSeat(reservationData);
      setState(() {
        seats[row][column] = false;
        dailyReservations++;
      });

      reservationTimers[reservationId] = Timer(Duration(seconds: 30), () async {
        await _reservationService!.cancelReservation(reservationId);
        setState(() {
          seats[row][column] = true;
          dailyReservations--;
        });
        reservationTimers.remove(reservationId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserva cancelada por tiempo expirado.')),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Asiento reservado. Confirma dentro de 30 segundos.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al reservar asiento')));
    }
  }

  void _confirmReservation(String reservationId) async {
    try {
      await _reservationService!.confirmReservation(reservationId);
      reservationTimers[reservationId]?.cancel();
      reservationTimers.remove(reservationId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reserva confirmada exitosamente.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al confirmar reserva.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar Asientos: ${widget.section.nombre}'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0000FF), Color(0xFF00FFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0000FF), Color(0xFF00FFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Horario: ${widget.section.horarioInicio} - ${widget.section.horarioFin}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: rows * columns,
                  itemBuilder: (context, index) {
                    final row = index ~/ columns;
                    final column = index % columns;

                    return GestureDetector(
                      onTap: seats[row][column] ? () => _reserveSeat(row, column) : null,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: seats[row][column] ? Colors.greenAccent : Colors.redAccent,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${row + 1}-${column + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Reservas diarias: $dailyReservations / $maxDailyReservations',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
