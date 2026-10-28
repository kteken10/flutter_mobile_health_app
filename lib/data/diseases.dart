import 'package:flutter/material.dart';

import '../models/disease.dart';
import '../models/risk.dart';

// Chaque évaluation additionne des points pour les seuils cliniques franchis
// (ADA, ESC/ESH, OMS) ; le score est leur total ramené entre 0 et 100 %.
// C'est un indicateur d'aide au dépistage, pas un diagnostic.

const metabolism = Category('Métabolisme', Icons.water_drop_rounded, Color(0xFFF59E0B));
const cardio = Category('Cardiologie', Icons.favorite_rounded, Color(0xFFE11D48));
const infectious = Category('Infectiologie', Icons.coronavirus_rounded, Color(0xFF6366F1));
const hematology = Category('Hématologie', Icons.bloodtype_rounded, Color(0xFF9333EA));

const categories = [metabolism, cardio, infectious, hematology];

double _n(ClinicalValues v, String id) => v[id] as double;
bool _b(ClinicalValues v, String id) => v[id] as bool;
int _c(ClinicalValues v, String id) => v[id] as int;
String _f(double x, [int d = 0]) => x.toStringAsFixed(d);

final diabetes = Disease(
  id: 'diabetes',
  image: 'assets/images/diseases/diabetes.png',
  name: 'Diabète de type 2',
  category: metabolism,
  icon: Icons.water_drop_rounded,
  summary: 'Glycémie, HbA1c et facteurs de risque métaboliques.',
  params: const [
    ClinicalParam.number(id: 'glucose', label: 'Glycémie à jeun', unit: 'mg/dL', min: 40, max: 400, initial: 95),
    ClinicalParam.number(id: 'hba1c', label: 'HbA1c', unit: '%', min: 4, max: 14, initial: 5.4, step: 0.1),
    ClinicalParam.number(id: 'bmi', label: 'IMC', unit: 'kg/m²', min: 14, max: 60, initial: 24, step: 0.1),
    ClinicalParam.number(id: 'age', label: 'Âge', unit: 'ans', min: 18, max: 100, initial: 45),
    ClinicalParam.number(id: 'dbp', label: 'Pression diastolique', unit: 'mmHg', min: 40, max: 130, initial: 78),
    ClinicalParam.toggle(id: 'family', label: 'Antécédents familiaux', hint: 'Parent ou fratrie diabétique'),
    ClinicalParam.toggle(id: 'sedentary', label: 'Sédentarité', hint: 'Moins de 150 min d\'activité par semaine'),
  ],
  assess: (v) {
    final glucose = _n(v, 'glucose'), hba1c = _n(v, 'hba1c'), bmi = _n(v, 'bmi');
    return RiskResult(
      factors: [
        if (glucose >= 126)
          RiskFactor('Glycémie à jeun', '${_f(glucose)} mg/dL, au-dessus du seuil du diabète (126)', 35)
        else if (glucose >= 100)
          RiskFactor('Glycémie à jeun', '${_f(glucose)} mg/dL, zone de prédiabète (100 à 125)', 18),
        if (hba1c >= 6.5)
          RiskFactor('HbA1c', '${_f(hba1c, 1)} %, au-dessus du seuil du diabète (6,5 %)', 30)
        else if (hba1c >= 5.7)
          RiskFactor('HbA1c', '${_f(hba1c, 1)} %, zone de prédiabète (5,7 à 6,4 %)', 15),
        if (bmi >= 30)
          RiskFactor('IMC', '${_f(bmi, 1)} kg/m², obésité', 12)
        else if (bmi >= 25)
          RiskFactor('IMC', '${_f(bmi, 1)} kg/m², surpoids', 6),
        if (_n(v, 'age') >= 45) RiskFactor('Âge', '${_f(_n(v, 'age'))} ans, 45 ans ou plus', 8),
        if (_n(v, 'dbp') >= 90) RiskFactor('Pression diastolique', '${_f(_n(v, 'dbp'))} mmHg, 90 ou plus', 5),
        if (_b(v, 'family')) const RiskFactor('Antécédents familiaux', 'Diabète chez un parent proche', 10),
        if (_b(v, 'sedentary')) const RiskFactor('Sédentarité', 'Activité physique insuffisante', 5),
      ],
      recommendations: glucose >= 126 || hba1c >= 6.5
          ? const [
              'Confirmer par un second dosage de glycémie à jeun ou d\'HbA1c.',
              'Orienter vers un bilan diabétologique complet.',
              'Évaluer les complications : rein, rétine, pieds.',
            ]
          : glucose >= 100 || hba1c >= 5.7
              ? const [
                  'Contrôler la glycémie et l\'HbA1c dans 6 mois.',
                  'Conseils hygiéno-diététiques et activité physique régulière.',
                ]
              : const [
                  'Pas de signe biologique de diabète.',
                  'Dépistage à renouveler tous les 3 ans après 45 ans.',
                ],
    );
  },
);

final obesity = Disease(
  id: 'obesity',
  image: 'assets/images/diseases/obesity.png',
  name: 'Obésité',
  category: metabolism,
  icon: Icons.monitor_weight_rounded,
  summary: 'IMC calculé et tour de taille selon le sexe.',
  params: const [
    ClinicalParam.number(id: 'weight', label: 'Poids', unit: 'kg', min: 30, max: 250, initial: 78, step: 0.5),
    ClinicalParam.number(id: 'height', label: 'Taille', unit: 'cm', min: 120, max: 220, initial: 172),
    ClinicalParam.number(id: 'waist', label: 'Tour de taille', unit: 'cm', min: 50, max: 180, initial: 88),
    ClinicalParam.choice(id: 'sex', label: 'Sexe', options: ['Femme', 'Homme']),
  ],
  assess: (v) {
    final h = _n(v, 'height') / 100;
    final bmi = _n(v, 'weight') / (h * h);
    final male = _c(v, 'sex') == 1;
    final waist = _n(v, 'waist');
    final (veryHigh, high) = male ? (102.0, 94.0) : (88.0, 80.0);
    return RiskResult(
      note: 'IMC calculé : ${_f(bmi, 1)} kg/m²',
      factors: [
        if (bmi >= 40)
          RiskFactor('IMC', '${_f(bmi, 1)} kg/m², obésité sévère (classe III)', 60)
        else if (bmi >= 35)
          RiskFactor('IMC', '${_f(bmi, 1)} kg/m², obésité classe II', 50)
        else if (bmi >= 30)
          RiskFactor('IMC', '${_f(bmi, 1)} kg/m², obésité classe I', 40)
        else if (bmi >= 25)
          RiskFactor('IMC', '${_f(bmi, 1)} kg/m², surpoids', 20),
        if (waist >= veryHigh)
          RiskFactor('Tour de taille', '${_f(waist)} cm, obésité abdominale (${_f(veryHigh)} cm ou plus)', 30)
        else if (waist >= high)
          RiskFactor('Tour de taille', '${_f(waist)} cm, risque accru (${_f(high)} cm ou plus)', 15),
      ],
      recommendations: bmi >= 30
          ? const [
              'Prise en charge nutritionnelle et objectif de perte de 5 à 10 % du poids.',
              'Rechercher diabète, hypertension et apnée du sommeil.',
            ]
          : bmi >= 25
              ? const [
                  'Conseils alimentaires et activité physique régulière.',
                  'Suivre le poids et le tour de taille à chaque consultation.',
                ]
              : const ['Poids dans les valeurs normales.'],
    );
  },
);

final hypertension = Disease(
  id: 'hypertension',
  image: 'assets/images/diseases/hypertension.png',
  name: 'Hypertension artérielle',
  category: cardio,
  icon: Icons.favorite_rounded,
  summary: 'Pression artérielle, fréquence cardiaque et facteurs associés.',
  params: const [
    ClinicalParam.number(id: 'sbp', label: 'Pression systolique', unit: 'mmHg', min: 70, max: 250, initial: 128),
    ClinicalParam.number(id: 'dbp', label: 'Pression diastolique', unit: 'mmHg', min: 40, max: 150, initial: 82),
    ClinicalParam.number(id: 'hr', label: 'Fréquence cardiaque', unit: 'bpm', min: 30, max: 200, initial: 72),
    ClinicalParam.number(id: 'chol', label: 'Cholestérol total', unit: 'mg/dL', min: 100, max: 400, initial: 190),
    ClinicalParam.number(id: 'age', label: 'Âge', unit: 'ans', min: 18, max: 100, initial: 50),
    ClinicalParam.toggle(id: 'smoker', label: 'Tabagisme actif'),
  ],
  assess: (v) {
    final sbp = _n(v, 'sbp'), dbp = _n(v, 'dbp'), chol = _n(v, 'chol');
    final bp = '${_f(sbp)}/${_f(dbp)} mmHg';
    final crisis = sbp >= 180 || dbp >= 110;
    final htn = sbp >= 140 || dbp >= 90;
    return RiskResult(
      factors: [
        if (crisis)
          RiskFactor('Pression artérielle', '$bp, hypertension de grade 3', 70)
        else if (htn)
          RiskFactor('Pression artérielle', '$bp, hypertension (140/90 ou plus)', 45)
        else if (sbp >= 130 || dbp >= 85)
          RiskFactor('Pression artérielle', '$bp, normale haute', 22)
        else if (sbp >= 120)
          RiskFactor('Pression artérielle', '$bp, légèrement élevée', 8),
        if (_n(v, 'age') >= 55) RiskFactor('Âge', '${_f(_n(v, 'age'))} ans, 55 ans ou plus', 10),
        if (_b(v, 'smoker')) const RiskFactor('Tabagisme', 'Fumeur actif', 10),
        if (chol >= 240)
          RiskFactor('Cholestérol total', '${_f(chol)} mg/dL, élevé (240 ou plus)', 10)
        else if (chol >= 200)
          RiskFactor('Cholestérol total', '${_f(chol)} mg/dL, limite (200 à 239)', 5),
        if (_n(v, 'hr') > 100) RiskFactor('Fréquence cardiaque', '${_f(_n(v, 'hr'))} bpm, tachycardie', 5),
      ],
      recommendations: crisis
          ? const [
              'Contrôler la pression sans délai et rechercher une atteinte d\'organe.',
              'Envisager une prise en charge urgente.',
            ]
          : htn
              ? const [
                  'Confirmer par automesure ou MAPA sur plusieurs jours.',
                  'Bilan : créatinine, kaliémie, ECG, bilan lipidique.',
                  'Réduire le sel, l\'alcool, et arrêter le tabac.',
                ]
              : const [
                  'Contrôler la pression lors de la prochaine consultation.',
                  'Maintenir une activité physique régulière.',
                ],
    );
  },
);

final covid = Disease(
  id: 'covid',
  image: 'assets/images/diseases/covid.png',
  name: 'Covid-19',
  category: infectious,
  icon: Icons.coronavirus_rounded,
  summary: 'Symptômes, température, saturation et exposition.',
  params: const [
    ClinicalParam.number(id: 'temp', label: 'Température', unit: '°C', min: 35, max: 42, initial: 37, step: 0.1),
    ClinicalParam.number(id: 'spo2', label: 'Saturation (SpO₂)', unit: '%', min: 80, max: 100, initial: 98),
    ClinicalParam.toggle(id: 'cough', label: 'Toux'),
    ClinicalParam.toggle(id: 'dyspnea', label: 'Essoufflement'),
    ClinicalParam.toggle(id: 'anosmia', label: 'Perte de l\'odorat ou du goût'),
    ClinicalParam.toggle(id: 'contact', label: 'Contact avec un cas confirmé', hint: 'Dans les 14 derniers jours'),
  ],
  assess: (v) {
    final temp = _n(v, 'temp'), spo2 = _n(v, 'spo2');
    return RiskResult(
      factors: [
        if (temp >= 38)
          RiskFactor('Température', '${_f(temp, 1)} °C, fièvre', 25)
        else if (temp >= 37.5)
          RiskFactor('Température', '${_f(temp, 1)} °C, fébricule', 10),
        if (spo2 < 94)
          RiskFactor('Saturation', '${_f(spo2)} %, désaturation (moins de 94 %)', 30)
        else if (spo2 < 96)
          RiskFactor('Saturation', '${_f(spo2)} %, limite basse', 10),
        if (_b(v, 'anosmia')) const RiskFactor('Anosmie ou agueusie', 'Symptôme évocateur', 25),
        if (_b(v, 'dyspnea')) const RiskFactor('Essoufflement', 'Symptôme respiratoire', 20),
        if (_b(v, 'cough')) const RiskFactor('Toux', 'Symptôme respiratoire', 15),
        if (_b(v, 'contact')) const RiskFactor('Exposition', 'Contact avec un cas confirmé', 15),
      ],
      recommendations: spo2 < 94
          ? const ['Désaturation : évaluation hospitalière recommandée.', 'Test PCR et surveillance rapprochée.']
          : const [
              'Proposer un test antigénique ou PCR.',
              'Isolement en attendant le résultat.',
              'Surveiller la saturation et l\'essoufflement.',
            ],
    );
  },
);

final anemia = Disease(
  id: 'anemia',
  image: 'assets/images/diseases/anemia.png',
  name: 'Anémie',
  category: hematology,
  icon: Icons.bloodtype_rounded,
  summary: 'Hémoglobine selon le sexe et signes cliniques.',
  params: const [
    ClinicalParam.number(id: 'hb', label: 'Hémoglobine', unit: 'g/dL', min: 4, max: 20, initial: 13.5, step: 0.1),
    ClinicalParam.choice(id: 'sex', label: 'Sexe', options: ['Femme', 'Homme']),
    ClinicalParam.number(id: 'hr', label: 'Fréquence cardiaque', unit: 'bpm', min: 30, max: 200, initial: 74),
    ClinicalParam.toggle(id: 'fatigue', label: 'Fatigue persistante'),
    ClinicalParam.toggle(id: 'pallor', label: 'Pâleur cutanéo-muqueuse'),
  ],
  assess: (v) {
    final hb = _n(v, 'hb');
    final limit = _c(v, 'sex') == 1 ? 13.0 : 12.0;
    return RiskResult(
      factors: [
        if (hb < 8)
          RiskFactor('Hémoglobine', '${_f(hb, 1)} g/dL, anémie sévère (moins de 8)', 75)
        else if (hb < 11)
          RiskFactor('Hémoglobine', '${_f(hb, 1)} g/dL, anémie modérée (8 à 10,9)', 50)
        else if (hb < limit)
          RiskFactor('Hémoglobine', '${_f(hb, 1)} g/dL, anémie légère (moins de ${_f(limit)})', 30),
        if (_b(v, 'fatigue')) const RiskFactor('Fatigue', 'Fatigue persistante', 10),
        if (_b(v, 'pallor')) const RiskFactor('Pâleur', 'Signe clinique d\'anémie', 10),
        if (_n(v, 'hr') > 100) RiskFactor('Fréquence cardiaque', '${_f(_n(v, 'hr'))} bpm, tachycardie', 5),
      ],
      recommendations: hb < limit
          ? const [
              'Compléter par NFS, ferritine, vitamine B12 et folates.',
              'Rechercher une cause de saignement ou de carence.',
            ]
          : const ['Hémoglobine dans les valeurs normales.'],
    );
  },
);

final diseases = [diabetes, obesity, hypertension, covid, anemia];
