import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../data/sample_data.dart';
import '../models/analysis.dart';
import 'format.dart';

/// Envoi des résultats par e-mail. Les identifiants SMTP sont fournis au
/// lancement, jamais écrits dans le code :
///   flutter run --dart-define=SMTP_USER=... --dart-define=SMTP_PASSWORD=...
class EmailService {
  static const _host = String.fromEnvironment('SMTP_HOST', defaultValue: 'smtp.gmail.com');
  static const _port = int.fromEnvironment('SMTP_PORT', defaultValue: 587);
  static const _user = String.fromEnvironment('SMTP_USER');
  static const _password = String.fromEnvironment('SMTP_PASSWORD');

  static bool get isConfigured => _user.isNotEmpty && _password.isNotEmpty;

  Future<void> sendResult(Analysis analysis) async {
    if (!isConfigured) {
      throw StateError('Envoi d\'e-mail non configuré');
    }
    final server = SmtpServer(_host, port: _port, username: _user, password: _password);
    final message = Message()
      ..from = Address(_user, 'MediScanAI · $clinicName')
      ..recipients.add(analysis.patient.email)
      ..subject = 'Résultat de votre analyse : ${analysis.disease.name}'
      ..html = _html(analysis);
    await send(message, server);
  }

  String _html(Analysis a) {
    final r = a.result;
    final color = '#${(r.level.color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final values = a.disease.params
        .map((p) => '<tr><td style="padding:6px 0;color:#5F6F86">${p.label}</td>'
            '<td style="padding:6px 0;text-align:right;font-weight:600">${p.format(a.values[p.id]!)}</td></tr>')
        .join();
    final advice = r.recommendations.map((t) => '<li style="margin-bottom:6px">$t</li>').join();
    return '''
<div style="font-family:Arial,sans-serif;max-width:560px;margin:auto;color:#0B1F3A">
  <h2 style="margin:0 0 4px">Bonjour ${a.patient.firstName},</h2>
  <p style="color:#5F6F86;margin:0 0 20px">Voici le résultat de l'analyse « ${a.disease.name} » du ${formatDate(a.date)}.</p>
  <div style="border:1px solid #E4E9F0;border-radius:12px;padding:20px;text-align:center">
    <div style="font-size:40px;font-weight:700;color:$color">${r.percent} %</div>
    <div style="font-weight:600;color:$color">${r.level.label}</div>
  </div>
  <h3>Valeurs relevées</h3>
  <table style="width:100%;border-collapse:collapse">$values</table>
  <h3>Recommandations</h3>
  <ul>$advice</ul>
  <p style="color:#5F6F86;font-size:13px">Ce score est un indicateur d'aide au dépistage et ne remplace pas un diagnostic.
  Votre médecin, $doctorName, reviendra vers vous si nécessaire.</p>
</div>''';
  }
}
