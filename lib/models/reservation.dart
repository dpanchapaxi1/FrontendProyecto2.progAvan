class Reservation {
  final String id;
  final String column;
  final String row;
  final bool estado;
  final bool confirmacion;
  final String seccion;
  final String usuario;

  Reservation({
    required this.id,
    required this.column,
    required this.row,
    required this.estado,
    required this.confirmacion,
    required this.seccion,
    required this.usuario,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      column: json['column'],
      row: json['row'],
      estado: json['estado'],
      confirmacion: json['confirmacion'],
      seccion: json['seccion'],
      usuario: json['usuario'],
    );
  }
}
