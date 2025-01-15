class Section {
  final String id;
  final String nombre;
  final String horarioInicio;
  final String horarioFin;

  Section({required this.id, required this.nombre, required this.horarioInicio, required this.horarioFin});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      nombre: json['nombre'],
      horarioInicio: json['horarioInicio'],
      horarioFin: json['horarioFin'],
    );
  }
}
