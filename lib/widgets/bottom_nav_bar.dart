import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF111827),
      selectedItemColor: const Color(0xFF1E88E5),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'حسابي',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book_outlined),
          label: 'حلول',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront_outlined),
          label: 'المتجر',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          label: 'الكروت',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
      ],
    );
  }
}
