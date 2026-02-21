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
          // Low stock alert
          Consumer(builder: (context, ref, _) {
            final low = ref.watch(lowStockProvider);
            if (low.isEmpty) return const SizedBox.shrink();
            return Card(
              color: Colors.orange[50],
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: const Text('Low stock'),
                subtitle: Text(low.map((m) => '${m.name} (${m.remainingQuantity})').join(', ')),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () async {
                    // refill the first low-stock item to full for demo
                    final first = low.first;
                    await ref.read(medicinesProvider.notifier).refillToFull(first.id!);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refilled')));
                  },
                ),
              ),
            );
          }),

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
                  trailing: IconButton(
                    icon: const Icon(Icons.inventory_2),
                    onPressed: () async {
                      await ref.read(medicinesProvider.notifier).refillToFull(m.id!);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refilled')));
                    },
                  ),
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
