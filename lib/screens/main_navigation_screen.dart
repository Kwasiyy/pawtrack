// lib/screens/main_navigation_screen.dart
import 'package:flutter/material.dart';
import 'pet_tips_screen.dart';
import 'pet_list_screen.dart';
import 'add_pet_screen.dart';
import 'reminders_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 1;  // Start with PetListScreen

  // Your five main screens (we'll push AddPet separately)
  final List<Widget> _screens = const [
    PetTipsScreen(),
    PetListScreen(),
    RemindersScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = [
    'Pet Tips',
    'My Pets',
    'Reminders',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: _screens[_selectedIndex],

      // Center FAB for AddPet
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPetScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Raised BottomAppBar with extra notch margin
      bottomNavigationBar: SizedBox(
        height: 64,
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 12,
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left two icons
                Row(
                  children: [
                    _buildIcon(cs, 0, Icons.tips_and_updates_outlined),
                    const SizedBox(width: 32),
                    _buildIcon(cs, 1, Icons.pets_outlined),
                  ],
                ),
                // Right two icons
                Row(
                  children: [
                    _buildIcon(cs, 2, Icons.notifications_outlined),
                    const SizedBox(width: 32),
                    _buildIcon(cs, 3, Icons.person_outline),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ColorScheme cs, int idx, IconData icon) {
    final selected = _selectedIndex == idx;
    return IconButton(
      onPressed: () => _onItemTapped(idx),
      icon: Icon(icon),
      color: selected ? cs.primary : cs.onSurfaceVariant,
    );
  }
}
