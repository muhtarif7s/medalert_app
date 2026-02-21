class HistoryEntry {
  int? id;
  int medicineId;
  DateTime time;
  String status; // taken, skipped, remind

  HistoryEntry({this.id, required this.medicineId, required this.time, required this.status});

  Map<String, dynamic> toMap() => {
        'id': id,
        'medicineId': medicineId,
        'time': time.toIso8601String(),
        'status': status,
      };

  static HistoryEntry fromMap(Map<String, dynamic> m) => HistoryEntry(
        id: m['id'] as int?,
        medicineId: m['medicineId'] as int,
        time: DateTime.parse(m['time'] as String),
        status: m['status'] as String,
      );
}
