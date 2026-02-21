import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../services/scheduler_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(medicinesProvider);
    final scheduler = SchedulerService.instance;
    final now = DateTime.now();
    DateTime? next;
    for (final m in meds) {
      final ups = scheduler.upcomingDoses(m, now, count: 1);
      if (ups.isNotEmpty) {
        final cand = ups.first;
        if (next == null || cand.isBefore(next)) next = cand;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('MediMate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Card(
            child: ListTile(
              title: const Text('Next Dose'),
              subtitle: Text(next != null ? next.toLocal().toString() : 'No upcoming doses'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: meds.length,
              itemBuilder: (c, i) {
                final m = meds[i];
                return ListTile(
                  title: Text(m.name),
                  subtitle: Text('${m.amount} ${m.unit} • ${m.times.join(', ')}'),
                  onTap: () => Navigator.of(context).pushNamed('/med/${m.id}'),
                );
              },
            ),
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
