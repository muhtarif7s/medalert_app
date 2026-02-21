import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../services/scheduler_service.dart';

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
      for (final t in list) missed.add({'med': m, 'time': t});
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
              IconButton(onPressed: () {}, icon: const Icon(Icons.check, color: Colors.green)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.close, color: Colors.red)),
            ]),
          );
        },
      ),
    );
  }
}
