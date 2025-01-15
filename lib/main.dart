import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/section_screen.dart';
import 'screens/seat_screen.dart';
import 'models/user.dart';
import 'models/section.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reserva de Asientos',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/section': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as User;
          return SectionScreen(user: args);
        },
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/seat') {
          final args = settings.arguments as Map<String, dynamic>;
          final user = args['user'] as User;
          final section = args['section'] as Section;
          return MaterialPageRoute(
            builder: (context) => SeatScreen(user: user, section: section),
          );
        }
        return null;
      },
    );
  }
}
