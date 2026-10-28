import 'package:flutter/material.dart';

import 'catalog_screen.dart';
import 'history_screen.dart';
import 'patients_screen.dart';
import 'settings_screen.dart';

/// Navigation principale : quatre onglets.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          PatientsScreen(),
          CatalogScreen(),
          HistoryScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE4E9F0))),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.people_alt_outlined),
              selectedIcon: Icon(Icons.people_alt_rounded),
              label: 'Patients',
            ),
            NavigationDestination(
              icon: Icon(Icons.biotech_outlined),
              selectedIcon: Icon(Icons.biotech_rounded),
              label: 'Analyse',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'Historique',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Réglages',
            ),
          ],
        ),
      ),
    );
  }
}
