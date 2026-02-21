import 'local_db.dart';
import '../models/history_entry.dart';

class HistoryRepository {
  HistoryRepository._internal();
  static final HistoryRepository instance = HistoryRepository._internal();

  Future<int> insert(HistoryEntry e) async {
    try {
      return await LocalDatabase.instance.db.insert('history', e.toMap());
    } catch (_) {
      return 0;
    }
  }

  Future<List<HistoryEntry>> getAll() async {
    try {
      final rows = await LocalDatabase.instance.db.query('history', orderBy: 'time DESC');
      return rows.map((r) => HistoryEntry.fromMap(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<HistoryEntry>> getForMedicine(int medicineId) async {
    try {
      final rows = await LocalDatabase.instance.db.query('history', where: 'medicineId = ?', whereArgs: [medicineId], orderBy: 'time DESC');
      return rows.map((r) => HistoryEntry.fromMap(r)).toList();
    } catch (_) {
      return [];
    }
  }
}
