import 'package:flutter/material.dart';
import 'package:bottom_bar/bottom_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mediscanai/screens/home.dart';
import 'package:mediscanai/screens/history_tracking.dart';
import 'package:mediscanai/screens/prediction.dart';
import 'package:mediscanai/screens/settings_screen.dart';
import 'package:mediscanai/model/patient.dart';
import 'package:mediscanai/data/patients_list.dart';
import 'package:mediscanai/ui/add_patient_modal.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  final String doctorName = "Dr. Smith";

  // Liste des écrans pour la navigation
  final List<Widget> _screens = [
    const FirstScreen(),
    const PredictionScreen(
      patientEmail: "",
      patientName: "",
      doctorName: "Dr. Smith",
    ),
    const HistoryTrackingScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          /// APPROCHE 1: Avec PageView (décommentez cette section)
          PageView(
            controller: _pageController,
            children: _screens,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
          ),

       

          // Barre de navigation en bas
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              
              ),
              child: BottomBar(
                backgroundColor: Colors.transparent,
                selectedIndex: _currentPage,
                onTap: (int index) {
                  /// APPROCHE 1: Avec PageView
                  // _pageController.jumpToPage(index);
                  
                  /// APPROCHE 2: Avec navigation manuelle
                  setState(() => _currentPage = index);
                },
                items: _buildBottomBarItems(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  List<BottomBarItem> _buildBottomBarItems() {
    return [
      BottomBarItem(
        icon: SvgPicture.asset(
          'assets/home.svg',
          height: 20,
          width: 20,
          color: _currentPage == 0 
              ? const Color.fromARGB(255, 23, 92, 210)
              : Colors.grey,
        ),
        title: const Text('Accueil'),
        activeColor: const Color.fromARGB(255, 23, 92, 210),
      ),
      BottomBarItem(
        icon: SvgPicture.asset(
          'assets/brain.svg',
          height: 24,
          width: 24,
          color: _currentPage == 1
              ? const Color.fromARGB(255, 23, 92, 210)
              : Colors.grey,
        ),
        title: const Text('Prédictions'),
        activeColor: const Color.fromARGB(255, 23, 92, 210),
      ),
      BottomBarItem(
        icon: SvgPicture.asset(
          'assets/history.svg',
          height: 24,
          width: 24,
          color: _currentPage == 2
              ? const Color.fromARGB(255, 23, 92, 210)
              : Colors.grey,
        ),
        title: const Text('Historique'),
        activeColor: const Color.fromARGB(255, 23, 92, 210),
      ),
      BottomBarItem(
        icon: Icon(
          Icons.settings,
          color: _currentPage == 3
              ? const Color.fromARGB(255, 23, 92, 210)
              : Colors.grey,
        ),
        title: const Text('Paramètres'),
        activeColor: const Color.fromARGB(255, 23, 92, 210),
      ),
    ];
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showAddPatientDialog(context),
      backgroundColor: const Color.fromARGB(255, 132, 177, 254),
      foregroundColor: Colors.white,
      elevation: 6,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: const Icon(Icons.add),
    );
  }

  void _showAddPatientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddPatientModal(
        onPatientAdded: (Patient newPatient) {
          setState(() => patients.add(newPatient));
          _showSuccessSnackbar(context, newPatient.name);
        },
        doctorName: doctorName,
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String patientName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('$patientName ajouté avec succès'),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: const Color.fromARGB(255, 76, 175, 80),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}