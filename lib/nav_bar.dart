import 'package:flutter/material.dart';

import 'presentation/contact/page/contact_page.dart';
import 'presentation/conversation/conversation_page.dart';
import 'presentation/profile/page/profile_page.dart';
import 'core/utils/responsif_helper.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

// Helper class untuk data item navigasi
class _NavigationItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  _NavigationItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  // List halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const ConversationPage(),
    const ContactPage(),
    const ProfilePage(),
  ];

  // Data untuk item navigasi
  final List<_NavigationItemData> _navItemData = [
    _NavigationItemData(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavigationItemData(
      icon: Icons.contacts_outlined,
      selectedIcon: Icons.contacts_rounded,
      label: 'Contact',
    ),
    _NavigationItemData(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
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
    final isMobile = ResponsiveHelper.isMobile(context);

    List<NavigationDestination> buildBottomNavDestinations() {
      return _navItemData.asMap().entries.map((entry) {
        int idx = entry.key;
        _NavigationItemData item = entry.value;
        return NavigationDestination(
          icon: Icon(
            item.icon,
            color: _selectedIndex == idx
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          selectedIcon: Icon(item.selectedIcon, color: colorScheme.primary),
          label: item.label,
        );
      }).toList();
    }

    List<NavigationRailDestination> buildNavRailDestinations() {
      return _navItemData.asMap().entries.map((entry) {
        int idx = entry.key;
        _NavigationItemData item = entry.value;
        return NavigationRailDestination(
          icon: Icon(
            item.icon,
            color: _selectedIndex == idx
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          selectedIcon: Icon(item.selectedIcon, color: colorScheme.primary),
          label: Text(item.label),
        );
      }).toList();
    }

    Widget bottomNavBarWidget() {
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(
                alpha: 0.1,
              ), // Menggunakan withOpacity
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
          destinations: buildBottomNavDestinations(),
        ),
      );
    }

    Widget navigationRailWidget() {
      return NavigationRail(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        labelType: NavigationRailLabelType.all,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        elevation: 4,
        minWidth: 80,
        destinations: buildNavRailDestinations(),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile) navigationRailWidget(),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? bottomNavBarWidget() : null,
    );
  }
}
