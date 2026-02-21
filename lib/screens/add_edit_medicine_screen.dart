import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicine.dart';
import '../models/schedule.dart';
import '../state/providers.dart';
import '../services/notification_service.dart';
import '../services/scheduler_service.dart';

class AddEditMedicineScreen extends ConsumerStatefulWidget {
  const AddEditMedicineScreen({super.key});

  @override
  ConsumerState<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends ConsumerState<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _unit = TextEditingController(text: 'mg');
  final _times = TextEditingController(text: '08:00,20:00');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => (v ?? '').isEmpty ? 'Required' : null),
            TextFormField(controller: _amount, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            TextFormField(controller: _unit, decoration: const InputDecoration(labelText: 'Unit')),
            TextFormField(controller: _times, decoration: const InputDecoration(labelText: 'Times (comma separated HH:mm)')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final med = Medicine(
                  name: _name.text.trim(),
                  amount: double.tryParse(_amount.text) ?? 1.0,
                  unit: _unit.text.trim(),
                  times: _times.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                  schedule: Schedule(type: ScheduleType.daily),
                  totalQuantity: 0,
                  remainingQuantity: 0,
                );
                await ref.read(medicinesProvider.notifier).add(med);
                // schedule next dose notification
                try {
                  final ups = SchedulerService.instance.upcomingDoses(med, DateTime.now(), count: 1);
                  if (ups.isNotEmpty) {
                    final next = ups.first;
                    if (med.id != null) {
                      final nid = med.id! * 1000 + next.millisecondsSinceEpoch.remainder(1000);
                      await NotificationService().scheduleNotification(id: nid, title: 'Time to take ${med.name}', body: '${med.amount} ${med.unit}', scheduledDate: next);
                    }
                  }
                } catch (_) {}
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            )
          ]),
        ),
      ),
    );
  }
}
