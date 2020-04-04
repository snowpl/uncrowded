
import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:geolocation/geolocation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class GeoSchedulerService {

  final config = BackgroundFetchConfig(
    minimumFetchInterval: 15,
    stopOnTerminate: false,
    enableHeadless: true,
    requiresBatteryNotLow: false,
    requiresCharging: false,
    requiresStorageNotLow: false,
    requiresDeviceIdle: false,
    requiredNetworkType: NetworkType.NONE
  );

  initialize() async {
    await verifyPermission();
    final db = await openDatabase('duck_uncrowded.db');
    await db.execute(''
        'create table if not exists geolocation '
        '(timestamp integer primary key, lat real, lon real)'
    );
    BackgroundFetch.configure(config, sendData);
    BackgroundFetch.registerHeadlessTask(sendData);
    Geolocation.locationUpdates(
      accuracy: LocationAccuracy.best,
      displacementFilter: 100.0,
      inBackground: true,
    ).listen((result) {
      if (result.isSuccessful) {
        db.rawInsert('insert into geolocation values ('
          '${DateTime.now().millisecondsSinceEpoch}, '
          '${result.location.latitude}, '
          '${result.location.longitude})');
      }
    });
  }

  verifyPermission() async {
    final GeolocationResult result = await Geolocation.isLocationOperational();
    if(!result.isSuccessful) {
      await Geolocation.requestLocationPermission(
        permission: const LocationPermission(
          android: LocationPermissionAndroid.fine,
          ios: LocationPermissionIOS.always,
        ),
        openSettingsIfDenied: true,
      );
    }
  }

  static sendData(String taskId) async {
    final db = await openDatabase('duck_uncrowded.db');
    final entries = await db.rawQuery('select * from geolocation');
    final response = await http.put('http://www.mocky.io/v2/fake_path',
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode(entries)
    );
    if (response.statusCode == 202) await db.rawDelete('delete from geolocation');
    BackgroundFetch.finish(taskId);
  }
}
