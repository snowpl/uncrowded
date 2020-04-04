enum CrowdedLevel { Empty, Moderate, Crowded }

class OpeningHours {
  String closes;
  String opens;

  OpeningHours({this.closes, this.opens});
}

class Position {
  double latitude;
  double longitude;

  Position({this.latitude, this.longitude});
}

class Shop {
  String id;
  String name;
  double distance;
  CrowdedLevel crowdedLevel;
  String address;
  OpeningHours openingHours;
  bool openNow;
  Position position;

  Shop(
      {this.id,
      this.name,
      this.distance,
      this.address,
      this.openNow,
      this.crowdedLevel,
      this.openingHours,
      this.position});

  factory Shop.fromJson(Map<String, dynamic> json) {
    int currentDay = DateTime.now().weekday;

    List day = json['periods']
        .where((x) => x['open']['day'] == currentDay && x['close']['day'] == currentDay)
        .toList();

    return Shop(
      id: json['place_id'],
      name: json['name'],
      distance: double.parse(json['distance'].toStringAsFixed(1)),
      crowdedLevel: json['distance'] > 2 ? CrowdedLevel.Empty : json['distance'] > 1 ? CrowdedLevel.Moderate : CrowdedLevel.Crowded,
      // obviously not available. Fake different crowded level based on distance.
      address: json['vicinity'],
      openingHours: OpeningHours(
          closes: day.isEmpty ? '' : day[0]['close']['time'] as String,
          opens: day.isEmpty ? '' : day[0]['open']['time'] as String),
      openNow: json['opening_hours']['open_now'],
      position: Position(
          latitude: json['geometry']['location']['lat'],
          longitude: json['geometry']['location']['lng']),
    );
  }
}
