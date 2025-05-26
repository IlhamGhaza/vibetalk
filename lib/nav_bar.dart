import 'package:flutter/material.dart';

import 'presentation/contact/contact_page.dart';
import 'presentation/conversation/conversation_page.dart';
import 'presentation/profile/profile_page.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
    int _selectedIndex = 0;

  // List halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const ConversationPage(),
    const ContactPage(),
    const ProfilePage(),
  ];

  // Animasi perpindahan halaman
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
   final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 65,
          elevation: 0,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: colorScheme.surface,
          indicatorColor: colorScheme.primaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 500),
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: _selectedIndex == 0
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.home_rounded,
                color: colorScheme.primary,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.contacts_outlined,
                color: _selectedIndex == 1
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.contacts_rounded,
                color: colorScheme.primary,
              ),
              label: 'Contact',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline_rounded,
                color: _selectedIndex == 1
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: colorScheme.primary,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
