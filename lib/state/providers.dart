import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../repositories/medicine_repository.dart';
import '../services/notification_service.dart';
import '../models/history_entry.dart';
import '../repositories/history_repository.dart';

final medicineRepoProvider = Provider<MedicineRepository>((ref) => MedicineRepository.instance);
final historyRepoProvider = Provider<HistoryRepository>((ref) => HistoryRepository.instance);

final medicinesProvider = StateNotifierProvider<MedicineListNotifier, List<Medicine>>((ref) {
  return MedicineListNotifier(ref);
});

final lowStockProvider = Provider<List<Medicine>>((ref) {
  final meds = ref.watch(medicinesProvider);
  return meds.where((m) => m.refillThreshold > 0 && m.remainingQuantity <= m.refillThreshold).toList();
});

class MedicineListNotifier extends StateNotifier<List<Medicine>> {
  final Ref ref;
  MedicineListNotifier(this.ref) : super([]) {
    load();
  }

  Future<void> load() async {
    final repo = ref.read(medicineRepoProvider);
    final list = await repo.getAll();
    state = list;
  }

  Future<void> add(Medicine m) async {
    final repo = ref.read(medicineRepoProvider);
    final id = await repo.insert(m);
    m.id = id;
    state = [...state, m];
  }

  Future<void> refillToFull(int medicineId) async {
    final repo = ref.read(medicineRepoProvider);
    final idx = state.indexWhere((m) => m.id == medicineId);
    if (idx == -1) return;
    final m = state[idx];
    m.remainingQuantity = m.totalQuantity;
    await repo.update(m);
    final newList = [...state];
    newList[idx] = m;
    state = newList;
  }

  Future<void> remove(int id) async {
    final repo = ref.read(medicineRepoProvider);
    await repo.delete(id);
    state = state.where((e) => e.id != id).toList();
  }

  /// Record a dose action and update inventory when taken.
  Future<void> markDose(int medicineId, DateTime time, String status) async {
    final hrepo = ref.read(historyRepoProvider);
    final repo = ref.read(medicineRepoProvider);
    final entry = HistoryEntry(medicineId: medicineId, time: time, status: status);
    await hrepo.insert(entry);
    // update local state and inventory if taken
    if (status == 'taken') {
      final idx = state.indexWhere((m) => m.id == medicineId);
      if (idx != -1) {
        final m = state[idx];
        if (m.remainingQuantity > 0) m.remainingQuantity -= 1;
        await repo.update(m);
        final newList = [...state];
        newList[idx] = m;
        state = newList;

        // If at or below refill threshold, notify user
        try {
          if (m.refillThreshold > 0 && m.remainingQuantity <= m.refillThreshold) {
            final nid = (m.id ?? 0) * 10 + DateTime.now().millisecondsSinceEpoch.remainder(10);
            await NotificationService().showNotification(
              id: nid,
              title: 'Refill needed: ${m.name}',
              body: 'Remaining ${m.remainingQuantity} of ${m.totalQuantity}',
              payload: null,
            );
          }
        } catch (_) {}
      }
    }
  }
}

// Settings providers: theme and locale
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final localeProvider = StateProvider<Locale?>((ref) => null); // null = system

class SettingsNotifier extends StateNotifier<void> {
  SettingsNotifier() : super(null);
}
