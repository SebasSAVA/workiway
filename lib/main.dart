import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Importa ScreenUtil
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workiway/screens/auth/home_screen.dart';
import 'package:workiway/screens/auth/login_screen.dart';
import 'package:workiway/screens/auth/register_screen.dart';
import 'package:workiway/screens/auth/reset_password_screen.dart';

// Pantallas para cliente
import 'package:workiway/screens/customer/services_screen.dart';
import 'package:workiway/screens/customer/products_screen.dart';
import 'package:workiway/screens/customer/reservations_screen.dart';
import 'package:workiway/screens/customer/profile_screen.dart';

// Pantallas para proveedor
import 'package:workiway/screens/provider/payments_screen.dart';
import 'package:workiway/screens/provider/reservations_screen.dart';
import 'package:workiway/screens/provider/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase aquí

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Inicializa ScreenUtil aquí
      designSize: const Size(360, 690), // Tamaño de referencia del diseño
      minTextAdapt: true, // Para ajustar el tamaño del texto
      splitScreenMode: true, // Activa el modo de pantalla dividida
      builder: (context, child) {
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
            const Locale('en'), // Inglés
          ],
          locale:
              const Locale('es'), // Establecer el español como predeterminado
          initialRoute: '/home', // O la ruta que desees como inicial
          routes: {
            '/home': (context) => HomeScreen(),
            '/login': (context) => LoginScreen(),
            '/register': (context) => RegisterScreen(),
            '/reset-password': (context) => ResetPasswordScreen(),
            '/customer-services': (context) =>
                ServicesScreen(), // Pantalla de servicios del cliente
            '/provider-reservations': (context) =>
                ProviderReservationsScreen(), // Pantalla de reservas del proveedor
          },
        );
      },
    );
  }
}
