import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediscanai/data/diseases.dart';
import 'package:mediscanai/main.dart';
import 'package:mediscanai/models/risk.dart';
import 'package:mediscanai/services/clinic.dart';

void main() {
  group('Évaluation des risques', () {
    test('valeurs normales : risque faible sans facteur', () {
      final r = diabetes.assess(diabetes.defaults..['age'] = 30.0);
      expect(r.factors, isEmpty);
      expect(r.level, RiskLevel.low);
    });

    test('glycémie et HbA1c au-dessus des seuils : risque élevé', () {
      final r = diabetes.assess(diabetes.defaults
        ..['glucose'] = 140.0
        ..['hba1c'] = 7.0);
      expect(r.level, RiskLevel.high);
      expect(r.factors.first.label, 'Glycémie à jeun');
    });

    test('obésité : IMC calculé à partir du poids et de la taille', () {
      final r = obesity.assess({'weight': 100.0, 'height': 170.0, 'waist': 80.0, 'sex': 1});
      expect(r.note, contains('34.6'));
      expect(r.level, RiskLevel.moderate);
    });

    test('le score ne dépasse jamais 100 %', () {
      final r = covid.assess({
        'temp': 39.5, 'spo2': 90.0, 'cough': true,
        'dyspnea': true, 'anosmia': true, 'contact': true,
      });
      expect(r.percent, 100);
    });
  });

  testWidgets('connexion puis liste des patients', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MediScanApp(clinic: Clinic()));
    expect(find.text('Bon retour, docteur'), findsOneWidget);

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Amina Mballa'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
