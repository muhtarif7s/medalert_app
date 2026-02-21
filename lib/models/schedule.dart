enum ScheduleType { daily, weekdays, everyXHours, custom }

class Schedule {
  ScheduleType type;
  // for everyXHours
  int? everyHours;
  // for weekdays: list of ints 1(Mon)-7(Sun)
  List<int>? weekdays;

  Schedule({required this.type, this.everyHours, this.weekdays});
}
