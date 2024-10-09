import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workiway/screens/auth/home_screen.dart';
import 'package:workiway/screens/auth/login_screen.dart';
import 'package:workiway/screens/auth/register_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/auth/reset_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase aquí
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workiway',
      theme: ThemeData(
        primaryColor: Color(0xFF438ef9),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es'), // Español
        const Locale(
            'en'), // Inglés (puedes agregar más idiomas si es necesario)
      ],
      locale: const Locale('es'), // Establecer el español como predeterminado
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/reset-password': (context) => ResetPasswordScreen(),
      },
    );
  }
}
