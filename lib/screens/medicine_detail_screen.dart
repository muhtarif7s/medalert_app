import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';

class MedicineDetailScreen extends ConsumerWidget {
  final int medicineId;
  const MedicineDetailScreen({super.key, required this.medicineId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(medicinesProvider);
    final medList = meds.where((m) => m.id == medicineId).toList();
    if (medList.isEmpty) {
      return Scaffold(appBar: AppBar(title: const Text('Medicine')), body: const Center(child: Text('Not found')));
    }
    final med = medList.first;
    return Scaffold(
      appBar: AppBar(title: Text(med.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Dosage: ${med.amount} ${med.unit}'),
          const SizedBox(height: 8),
          Text('Times: ${med.times.join(', ')}'),
          const SizedBox(height: 8),
          Text('Remaining: ${med.remainingQuantity}/${med.totalQuantity}'),
          const SizedBox(height: 12),
          Row(children: [
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(medicinesProvider.notifier).markDose(med.id!, DateTime.now(), 'taken');
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked taken')));
              },
              icon: const Icon(Icons.check),
              label: const Text('Take dose'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(medicinesProvider.notifier).refillToFull(med.id!);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refilled to full')));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refill'),
            ),
          ]),
        ]),
      ),
    );
  }
}
