import 'package:flutter/material.dart';

import '../data/diseases.dart';
import '../data/sample_data.dart';
import '../services/email_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _reminders = true;

  void _showMethod() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            const Text('Méthode de calcul', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text(
              'Chaque analyse compare les valeurs saisies aux seuils des recommandations '
              'cliniques (ADA pour le diabète, ESC/ESH pour l\'hypertension, OMS pour l\'obésité '
              'et l\'anémie). Chaque seuil franchi ajoute des points ; le score est leur total, '
              'de 0 à 100 %.',
              style: TextStyle(height: 1.45),
            ),
            const SizedBox(height: 16),
            for (final level in const [
              ('Moins de 30 %', 'Risque faible', AppColors.low),
              ('30 à 59 %', 'Risque modéré', AppColors.moderate),
              ('60 % et plus', 'Risque élevé', AppColors.high),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: level.$3, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Text(level.$2, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(level.$1, style: const TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const Text('Pathologies couvertes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 10),
            for (final d in diseases)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    IconTile(d.icon, d.category.color, size: 34),
                    const SizedBox(width: 12),
                    Expanded(child: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    Text('${d.params.length} paramètres', style: const TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Text('Réglages', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 20),
            const AppCard(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  Avatar('CM', size: 56),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doctorName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        SizedBox(height: 3),
                        Text(doctorSpecialty, style: TextStyle(color: AppColors.muted)),
                        SizedBox(height: 2),
                        Text(clinicName, style: TextStyle(color: AppColors.muted, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _Header('Préférences'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _switch(Icons.notifications_none_rounded, 'Notifications', 'Résultats à risque élevé',
                      _notifications, (v) => setState(() => _notifications = v)),
                  const Divider(indent: 60),
                  _switch(Icons.event_repeat_rounded, 'Rappels de suivi', 'Contrôles à planifier',
                      _reminders, (v) => setState(() => _reminders = v)),
                  const Divider(indent: 60),
                  const _Tile(Icons.language_rounded, 'Langue', trailing: 'Français'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _Header('Résultats'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _Tile(
                    Icons.mail_outline_rounded,
                    'Envoi par e-mail',
                    trailingWidget: EmailService.isConfigured
                        ? const Pill('Configuré', color: AppColors.low, background: AppColors.lowSoft)
                        : const Pill('Non configuré', color: AppColors.muted, background: Color(0xFFEEF2F6)),
                  ),
                  const Divider(indent: 60),
                  _Tile(Icons.functions_rounded, 'Méthode de calcul', onTap: _showMethod),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _Header('À propos'),
            const AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _Tile(Icons.info_outline_rounded, 'Version', trailing: '2.0.0'),
                  Divider(indent: 60),
                  _Tile(Icons.shield_outlined, 'Données', trailing: 'Stockées sur l\'appareil'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.high,
                side: const BorderSide(color: AppColors.highSoft),
                backgroundColor: AppColors.surface,
              ),
              onPressed: () => Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switch(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
      child: Row(
        children: [
          IconTile(icon, AppColors.primary, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(text.toUpperCase(),
          style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.icon, this.title, {this.trailing, this.trailingWidget, this.onTap});

  final IconData icon;
  final String title;
  final String? trailing;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            IconTile(icon, AppColors.primary, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
            if (trailing != null) Text(trailing!, style: const TextStyle(color: AppColors.muted)),
            ?trailingWidget,
            if (onTap != null) const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
