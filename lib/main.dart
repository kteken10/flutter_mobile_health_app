import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/login_screen.dart';
import 'services/clinic.dart';
import 'theme.dart';

void main() => runApp(MediScanApp(clinic: Clinic()));

class MediScanApp extends StatelessWidget {
  const MediScanApp({super.key, required this.clinic});

  final Clinic clinic;

  @override
  Widget build(BuildContext context) {
    return ClinicScope(
      clinic: clinic,
      child: MaterialApp(
        title: 'MediScanAI',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const LoginScreen(),
      ),
    );
  }
}
