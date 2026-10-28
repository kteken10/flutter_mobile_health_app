const _months = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
];

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String formatTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// « Aujourd'hui », « Hier » ou la date.
String formatDay(DateTime d) {
  final now = DateTime.now();
  final days = DateTime(now.year, now.month, now.day)
      .difference(DateTime(d.year, d.month, d.day))
      .inDays;
  return switch (days) {
    0 => 'Aujourd\'hui',
    1 => 'Hier',
    _ => formatDate(d),
  };
}

String formatDateTime(DateTime d) => '${formatDay(d)}, ${formatTime(d)}';
