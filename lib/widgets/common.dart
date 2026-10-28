import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/analysis.dart';
import '../models/disease.dart';
import '../models/patient.dart';
import '../models/risk.dart';
import '../services/format.dart';
import '../theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Icône dans un carré arrondi teinté.
class IconTile extends StatelessWidget {
  const IconTile(this.icon, this.color, {super.key, this.size = 44});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

const _avatarColors = [
  Color(0xFF0D9488), Color(0xFF6366F1), Color(0xFFE11D48),
  Color(0xFFF59E0B), Color(0xFF0EA5E9), Color(0xFF9333EA),
];

/// Portrait rond, ou initiales sur fond teinté quand il n'y a pas de photo.
class Avatar extends StatelessWidget {
  const Avatar(this.initials, {super.key, this.size = 46, this.photo});

  Avatar.of(Patient patient, {super.key, this.size = 46})
      : initials = patient.initials,
        photo = patient.photo;

  final String initials;
  final double size;
  final String? photo;

  @override
  Widget build(BuildContext context) {
    final color = _avatarColors[initials.codeUnits.fold<int>(0, (s, c) => s + c) % _avatarColors.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
      child: photo != null
          ? Image.asset(photo!, width: size, height: size, fit: BoxFit.cover)
          : Text(
              initials,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: size * 0.34),
            ),
    );
  }
}

/// Illustration d'une pathologie sur un carré arrondi teinté de sa catégorie.
class DiseaseArt extends StatelessWidget {
  const DiseaseArt(this.disease, {super.key, this.size = 44});

  final Disease disease;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        color: disease.category.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Image.asset(disease.image, fit: BoxFit.contain),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, required this.color, required this.background, this.icon});

  final String label;
  final Color color;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class RiskBadge extends StatelessWidget {
  const RiskBadge(this.result, {super.key});

  final RiskResult result;

  @override
  Widget build(BuildContext context) {
    final level = result.level;
    return Pill('${result.percent} % · ${level.shortLabel}', color: level.color, background: level.softColor);
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key});

  final PatientStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (status) {
      PatientStatus.critical => (AppColors.high, AppColors.highSoft),
      PatientStatus.treatment => (AppColors.moderate, AppColors.moderateSoft),
      PatientStatus.stable => (AppColors.low, AppColors.lowSoft),
      PatientStatus.followUp => (AppColors.muted, const Color(0xFFEEF2F6)),
    };
    return Pill(status.label, color: color, background: background);
  }
}

/// Ligne d'historique : maladie, patient ou date, et niveau de risque.
class AnalysisTile extends StatelessWidget {
  const AnalysisTile(this.analysis, {super.key, this.showPatient = true, this.onTap});

  final Analysis analysis;
  final bool showPatient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final a = analysis;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          DiseaseArt(a.disease),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showPatient ? a.patient.fullName : a.disease.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  showPatient ? '${a.disease.name} · ${formatTime(a.date)}' : formatDateTime(a.date),
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          RiskBadge(a.result),
        ],
      ),
    );
  }
}

/// Jauge en arc de cercle : 0 à 100 %, couleur du niveau de risque.
class RiskGauge extends StatelessWidget {
  const RiskGauge(this.result, {super.key, this.size = 220});

  final RiskResult result;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: result.score),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox(
        width: size,
        height: size * 0.8,
        child: CustomPaint(
          painter: _GaugePainter(value, result.level.color),
          child: Align(
            // Centre du cercle : la moitié de la largeur, soit 0,25 dans la hauteur.
            alignment: const Alignment(0, 0.25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(value * 100).round()} %',
                  style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: -1),
                ),
                Text(
                  result.level.label,
                  style: TextStyle(color: result.level.color, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.value, this.color);

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final radius = size.width / 2 - stroke;
    final rect = Rect.fromCircle(center: Offset(size.width / 2, size.width / 2), radius: radius);
    const start = math.pi * 0.8;
    const sweep = math.pi * 1.4;
    final track = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, track);
    if (value > 0) {
      canvas.drawArc(rect, start, sweep * value, false, track..color = color);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value || old.color != color;
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          IconTile(icon, AppColors.muted, size: 56),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}
