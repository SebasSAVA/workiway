import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workiway/utils/constants.dart';
import 'package:workiway/screens/provider/payments_screen.dart';
import 'package:workiway/screens/provider/reservations_screen.dart';
import 'package:workiway/screens/provider/profile_screen.dart';

class ProviderBottomNavigation extends StatefulWidget {
  const ProviderBottomNavigation({super.key});

  @override
  _ProviderBottomNavigationState createState() =>
      _ProviderBottomNavigationState();
}

class _ProviderBottomNavigationState extends State<ProviderBottomNavigation> {
  int activePageIndex = 0; // Pestaña activa

  // Lista de pantallas
  List<Widget> pages = [
    PaymentsScreen(),
    ProviderReservationsScreen(),
    ProviderProfileScreen(),
  ];

  // Títulos correspondientes al AppBar de cada pantalla
  List<String> appBarTitles = [
    'Pagos',
    'Reservas',
    'Perfil',
  ];

  void setActivePage(int index) {
    setState(() {
      activePageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[activePageIndex]),
        automaticallyImplyLeading: false, // Elimina el botón "back"
      ),
      body: pages[activePageIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        height: ScreenUtil().setHeight(65.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getBottomWidgetItem(
              Ionicons.md_cash,
              activePageIndex == 0,
              () => setActivePage(0),
            ),
            getBottomWidgetItem(
              Ionicons.md_calendar,
              activePageIndex == 1,
              () => setActivePage(1),
            ),
            getBottomWidgetItem(
              Ionicons.md_person,
              activePageIndex == 2,
              () => setActivePage(2),
            ),
          ],
        ),
      ),
    );
  }
}

Widget getBottomWidgetItem(
    IconData icon, bool isActive, VoidCallback onPressed) {
  return Container(
    height: ScreenUtil().setHeight(62.0),
    width: ScreenUtil().setWidth(62.0),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isActive ? Constants.primaryColor : Colors.transparent,
    ),
    child: IconButton(
      icon: Icon(
        icon,
        color: isActive ? Colors.white : const Color.fromRGBO(156, 166, 201, 1),
      ),
      onPressed: onPressed,
    ),
  );
}
