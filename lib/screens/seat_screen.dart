import 'dart:async';
import 'package:flutter/material.dart';
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
  Map<String, Timer> seatTimers = {};
  Map<String, int> timeLeft = {};
  ReservationService? _reservationService;
  int dailyReservations = 0;
  final int maxDailyReservations = 5;
  List<List<bool>> savedSeats = List.generate(4, (_) => List.generate(5, (_) => false));

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

  void _toggleSeatSelection(int row, int column) {
    setState(() {
      if (savedSeats[row][column]) return; // Evitar cambios en sillas guardadas

      if (!seats[row][column]) {
        // Deseleccionar el asiento
        seats[row][column] = true;
        dailyReservations--;
        timeLeft.remove('$row-$column');
        seatTimers['$row-$column']?.cancel();
        seatTimers.remove('$row-$column');
      } else {
        if (dailyReservations >= maxDailyReservations) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Solo puedes hacer $maxDailyReservations reservas por día.')),
          );
          return;
        }

        // Reservar el asiento
        seats[row][column] = false;
        dailyReservations++;
        timeLeft['$row-$column'] = 10; //  5 minutos= 300 en segundos

        final timer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            if (timeLeft['$row-$column']! > 0) {
              timeLeft['$row-$column'] = timeLeft['$row-$column']! - 1;
            } else {
              timer.cancel();
              seats[row][column] = true;
              timeLeft.remove('$row-$column');
              dailyReservations--;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('El tiempo de reserva ha expirado para el asiento ${row + 1}-${column + 1}.')),
              );
            }
          });
        });

        seatTimers['$row-$column'] = timer;
      }
    });
  }

  Future<void> _saveSelection() async {
    try {
      // Simulación de éxito en la llamada al servicio
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        for (int row = 0; row < rows; row++) {
          for (int column = 0; column < columns; column++) {
            if (!seats[row][column]) {
              // Guardar el asiento y marcarlo como ocupado
              savedSeats[row][column] = true;
              timeLeft.remove('$row-$column');
              seatTimers['$row-$column']?.cancel();
              seatTimers.remove('$row-$column');
            }
          }
        }
        dailyReservations = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selección guardada exitosamente.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la selección.')),
      );
    }
  }

  @override
  void dispose() {
    for (final timer in seatTimers.values) {
      timer.cancel();
    }
    super.dispose();
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
      body: Stack(
        children: [
          Container(
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
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: rows * columns,
                      itemBuilder: (context, index) {
                        final row = index ~/ columns;
                        final column = index % columns;

                        return GestureDetector(
                          onTap: () => _toggleSeatSelection(row, column),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/seat.png',
                                width: 100,
                                height: 100,
                                color: savedSeats[row][column]
                                    ? Colors.white
                                    : seats[row][column]
                                    ? Colors.teal
                                    : Colors.white,
                                colorBlendMode: BlendMode.modulate,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${row + 1}-${column + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (savedSeats[row][column])
                                    Text(
                                      'Ocupado',
                                      style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 14,
                                      ),
                                    ),
                                  if (timeLeft.containsKey('$row-$column'))
                                    Text(
                                      '${(timeLeft['$row-$column']! ~/ 60).toString().padLeft(2, '0')}:${(timeLeft['$row-$column']! % 60).toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveSelection,
                    child: Text('Guardar selección'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
