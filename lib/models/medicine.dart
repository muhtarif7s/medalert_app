import 'schedule.dart';

class Medicine {
  int? id;
  String name;
  double amount;
  String unit;
  List<String> times; // stored as HH:mm strings
  Schedule schedule;
  int totalQuantity;
  int remainingQuantity;
  DateTime? startDate;
  DateTime? endDate;

  Medicine({
    this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.times,
    required this.schedule,
    this.totalQuantity = 0,
    this.remainingQuantity = 0,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'amount': amount,
        'unit': unit,
        'times': times.join(','),
        'schedule': schedule.type.name,
        'totalQuantity': totalQuantity,
        'remainingQuantity': remainingQuantity,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      };

  static Medicine fromMap(Map<String, dynamic> m) {
    return Medicine(
      id: m['id'] as int?,
      name: m['name'] ?? '',
      amount: (m['amount'] is num) ? (m['amount'] as num).toDouble() : double.tryParse('${m['amount']}') ?? 0,
      unit: m['unit'] ?? '',
      times: (m['times'] as String? ?? '').split(',').where((s) => s.isNotEmpty).toList(),
      schedule: Schedule(type: ScheduleType.values.firstWhere((e) => e.name == (m['schedule'] ?? 'daily'), orElse: () => ScheduleType.daily)),
      totalQuantity: m['totalQuantity'] ?? 0,
      remainingQuantity: m['remainingQuantity'] ?? 0,
      startDate: m['startDate'] != null ? DateTime.tryParse(m['startDate']) : null,
      endDate: m['endDate'] != null ? DateTime.tryParse(m['endDate']) : null,
    );
  }
}
