import 'dart:collection';

class ShopDetail {
  String name;
  int distance;
  String hint;
  String closesAt;
  DaysOccupancy safeTime;
  HourOccupancy todayOccupancy;
 
  ShopDetail({this.name, this.distance, this.hint, this.closesAt, this.safeTime, this.todayOccupancy});
}

class DaysOccupancy {
  HashMap<DayOfWeek, HourOccupancy> dayOccupancy;
}

class HourOccupancy {
  HashMap<int, double> hourOccupancy;
}

enum DayOfWeek {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Saturday,
  Sunday
}