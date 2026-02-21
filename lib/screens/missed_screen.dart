import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../services/scheduler_service.dart';
import '../services/notification_service.dart';

class MissedScreen extends ConsumerWidget {
  const MissedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(medicinesProvider);
    final now = DateTime.now();
    final scheduler = SchedulerService.instance;
    final missed = <Map<String, dynamic>>[];
    for (final m in meds) {
      final list = scheduler.missedToday(m, now);
      for (final t in list) {
        missed.add({'med': m, 'time': t});
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Missed Doses')),
      body: ListView.builder(
        itemCount: missed.length,
        itemBuilder: (c, i) {
          final row = missed[i];
          final m = row['med'];
          final time = row['time'] as DateTime;
          return ListTile(
            title: Text(m.name),
            subtitle: Text(time.toLocal().toString()),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                onPressed: () async {
                  await ref.read(medicinesProvider.notifier).markDose(m.id!, time, 'taken');
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked taken')));
                },
                icon: const Icon(Icons.check, color: Colors.green),
              ),
              IconButton(
                onPressed: () async {
                  await ref.read(medicinesProvider.notifier).markDose(m.id!, time, 'skipped');
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked skipped')));
                },
                icon: const Icon(Icons.close, color: Colors.red),
              ),
              IconButton(
                onPressed: () async {
                  // schedule remind later using scheduler and notification service
                  final next = SchedulerService.instance.remindLater(DateTime.now(), minutes: 10);
                  final payload = {
                    'action': 'remind',
                    'medicineId': m.id,
                    'time': next.toIso8601String(),
                  };
                  final nid = (m.id ?? 0) * 1000 + next.millisecondsSinceEpoch.remainder(1000);
                  await NotificationService().scheduleNotification(id: nid, title: 'Reminder: ${m.name}', body: 'Reminder to take ${m.name}', scheduledDate: next, payload: jsonEncode(payload));
                  await ref.read(medicinesProvider.notifier).markDose(m.id!, next, 'remind');
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Will remind you later')));
                },
                icon: const Icon(Icons.alarm, color: Colors.orange),
              ),
            ]),
          );
        },
      ),
    );
  }
}
