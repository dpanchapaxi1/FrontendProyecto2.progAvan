import 'package:flutter/material.dart';
import '../models/section.dart';
import '../models/user.dart';
import '../services/section_service.dart';

class SectionScreen extends StatefulWidget {
  final User user;

  SectionScreen({required this.user});

  @override
  _SectionScreenState createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen> {
  late Future<List<Section>> _sections;

  @override
  void initState() {
    super.initState();
    _sections = SectionService(widget.user.token).getAllSections();
  }

  void _navigateToSeats(Section section) {
    Navigator.pushNamed(
      context,
      '/seat',
      arguments: {'user': widget.user, 'section': section},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Secciones Disponibles'),
        centerTitle: true,
        backgroundColor: Color(0xFF0000FF), // Azul sólido
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0000FF), Color(0xFF00FFFF)], // Azul eléctrico degradado
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Section>>(
          future: _sections,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar las secciones',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No hay secciones disponibles',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            final sections = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      section.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue[900],
                      ),
                    ),
                    subtitle: Text(
                      '${section.horarioInicio} - ${section.horarioFin}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: Icon(Icons.arrow_forward, color: Colors.blue[700]),
                    onTap: () => _navigateToSeats(section),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
