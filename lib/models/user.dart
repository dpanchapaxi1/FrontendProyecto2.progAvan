class User {
  final String id;
  final String nombre;
  final String token;

  User({required this.id, required this.nombre, required this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombre: json['nombre'],
      token: json['token'],
    );
  }
}
