import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../repositories/medicine_repository.dart';

final medicineRepoProvider = Provider<MedicineRepository>((ref) => MedicineRepository.instance);

final medicinesProvider = StateNotifierProvider<MedicineListNotifier, List<Medicine>>((ref) {
  return MedicineListNotifier(ref.read);
});

class MedicineListNotifier extends StateNotifier<List<Medicine>> {
  final Reader read;
  MedicineListNotifier(this.read) : super([]) {
    load();
  }

  Future<void> load() async {
    final repo = read(medicineRepoProvider);
    final list = await repo.getAll();
    state = list;
  }

  Future<void> add(Medicine m) async {
    final repo = read(medicineRepoProvider);
    final id = await repo.insert(m);
    m.id = id;
    state = [...state, m];
  }

  Future<void> remove(int id) async {
    final repo = read(medicineRepoProvider);
    await repo.delete(id);
    state = state.where((e) => e.id != id).toList();
  }
}

// Settings providers: theme and locale
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final localeProvider = StateProvider<Locale?>((ref) => null); // null = system

class SettingsNotifier extends StateNotifier<void> {
  SettingsNotifier() : super(null);
}
