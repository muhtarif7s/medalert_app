import 'package:intl/intl.dart';
import '../models/medicine.dart';

class SchedulerService {
  SchedulerService._();
  static final SchedulerService instance = SchedulerService._();

  /// Return the next [count] dose DateTimes for a medicine starting from [from].
  List<DateTime> upcomingDoses(Medicine med, DateTime from, {int count = 5}) {
    final out = <DateTime>[];
    DateTime cursor = from;
    while (out.length < count) {
      // For simple schedules, use the listed times each day
      for (final t in med.times) {
        final parts = t.split(':');
        final hh = int.tryParse(parts[0]) ?? 0;
        final mm = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        final candidate = DateTime(cursor.year, cursor.month, cursor.day, hh, mm);
        if (candidate.isAfter(from)) out.add(candidate);
        if (out.length >= count) break;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return out;
  }

  /// Simple missed doses detection for today
  List<DateTime> missedToday(Medicine med, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final out = <DateTime>[];
    for (final t in med.times) {
      final parts = t.split(':');
      final hh = int.tryParse(parts[0]) ?? 0;
      final mm = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      final candidate = DateTime(today.year, today.month, today.day, hh, mm);
      if (candidate.isBefore(now)) out.add(candidate);
    }
    return out;
  }

  String formatTime(String hhmm) {
    try {
      final parts = hhmm.split(':');
      final d = DateTime(1, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat.jm().format(d);
    } catch (_) {
      return hhmm;
    }
  }
}
