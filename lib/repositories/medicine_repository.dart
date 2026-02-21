import '../models/medicine.dart';
import 'local_db.dart';

class MedicineRepository {
  MedicineRepository._internal();
  static final MedicineRepository instance = MedicineRepository._internal();

  Future<int> insert(Medicine m) async {
    try {
      final id = await LocalDatabase.instance.db.insert('medicines', m.toMap());
      return id;
    } catch (_) {
      return 0;
    }
  }

  Future<List<Medicine>> getAll() async {
    try {
      final rows = await LocalDatabase.instance.db.query('medicines');
      return rows.map((r) => Medicine.fromMap(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> update(Medicine m) async {
    if (m.id == null) return;
    try {
      await LocalDatabase.instance.db.update('medicines', m.toMap(), where: 'id = ?', whereArgs: [m.id]);
    } catch (_) {}
  }

  Future<void> delete(int id) async {
    try {
      await LocalDatabase.instance.db.delete('medicines', where: 'id = ?', whereArgs: [id]);
    } catch (_) {}
  }
}
