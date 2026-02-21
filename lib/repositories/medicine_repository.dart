import '../models/medicine.dart';
import 'local_db.dart';

class MedicineRepository {
  MedicineRepository._internal();
  static final MedicineRepository instance = MedicineRepository._internal();

  Future<int> insert(Medicine m) async {
    final id = await LocalDatabase.instance.db.insert('medicines', m.toMap());
    return id;
  }

  Future<List<Medicine>> getAll() async {
    final rows = await LocalDatabase.instance.db.query('medicines');
    return rows.map((r) => Medicine.fromMap(r)).toList();
  }

  Future<void> update(Medicine m) async {
    if (m.id == null) return;
    await LocalDatabase.instance.db.update('medicines', m.toMap(), where: 'id = ?', whereArgs: [m.id]);
  }

  Future<void> delete(int id) async {
    await LocalDatabase.instance.db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }
}
