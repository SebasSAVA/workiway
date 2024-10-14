import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workiway/utils/constants.dart';
import 'package:workiway/screens/customer/services_screen.dart';
import 'package:workiway/screens/customer/products_screen.dart';
import 'package:workiway/screens/customer/reservations_screen.dart';
import 'package:workiway/screens/customer/profile_screen.dart';

class CustomerBottomNavigation extends StatefulWidget {
  const CustomerBottomNavigation({super.key});

  @override
  _CustomerBottomNavigationState createState() =>
      _CustomerBottomNavigationState();
}

class _CustomerBottomNavigationState extends State<CustomerBottomNavigation> {
  int activePageIndex = 0; // Track active page index

  List<Widget> pages = [
    ServicesScreen(),
    ProductsScreen(),
    CustomerReservationsScreen(),
    CustomerProfileScreen(),
  ];

  List<String> appBarTitles = [
    'Servicios',
    'Productos',
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
        backgroundColor: const Color(0xFF438ef9), // Fondo azul
        title: Text(
          appBarTitles[activePageIndex],
          style: const TextStyle(color: Colors.white), // Título en blanco
        ),
        automaticallyImplyLeading: false,
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
              Ionicons.md_briefcase,
              activePageIndex == 0,
              () => setActivePage(0),
            ),
            getBottomWidgetItem(
              Ionicons.md_cart,
              activePageIndex == 1,
              () => setActivePage(1),
            ),
            getBottomWidgetItem(
              Ionicons.md_calendar,
              activePageIndex == 2,
              () => setActivePage(2),
            ),
            getBottomWidgetItem(
              Ionicons.md_person,
              activePageIndex == 3,
              () => setActivePage(3),
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
