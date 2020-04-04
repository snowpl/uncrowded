import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safe_shop/domain/shop.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_shop/services/location_service.dart';
import 'dart:math' show cos, sqrt, asin;

abstract class ShopsState extends Equatable {
  const ShopsState();

  @override
  get props => [];
}

class ShopsInitialized extends ShopsState {}

class ShopsObtained extends ShopsState {
  final shops;
  ShopsObtained(this.shops);

  @override
  get props => [shops];
}

abstract class ShopsEvent extends Equatable {
  const ShopsEvent();

  @override
  get props => [];
}

class ShopsGetList extends ShopsEvent {}

class ShopsGetListByName extends ShopsEvent {
  final name;
  ShopsGetListByName(this.name);

  @override
  get props => [name];
}

class ShopsGetFilteredList extends ShopsEvent {
  final selected;
  ShopsGetFilteredList(this.selected);

  @override
  get props => [selected];
}

class ShopsBloc extends Bloc<ShopsEvent, ShopsState> {
  final _shopsService = _ShopsService();

  @override
  get initialState => ShopsInitialized();

  @override
  mapEventToState(ShopsEvent event) async* {
    if (event is ShopsGetList) {
      List<Shop> shops = await _shopsService.getShopList();
      yield ShopsObtained(shops);
    } else if (event is ShopsGetListByName) {
      List<Shop> shops = await _shopsService.getShopListByName(event.name);
      yield ShopsObtained(shops);
    } else if (event is ShopsGetFilteredList) {
      List<Shop> shops =
          await _shopsService.getFilteredShopList(event.selected);
      yield ShopsObtained(shops);
    }
  }
}

class _ShopsService {
  final locationService = LocationService();

  final key = 'KEY';

  var httpClient = http.Client();

  Future<List<Shop>> getShopList() async {
    final location = await locationService.getLocation();
    final requestUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

    final response = await httpClient.get('$requestUrl'
        '?location=${location.latitude},${location.longitude}'
        '&radius=5000' // TODO decide about radius of search
        '&type=store'
        '&key=$key');

    if (response.statusCode == 200) {
      List shops =
          json.decode(utf8.decode(response.bodyBytes))['results'] as List;

      for (var i = 0; i < shops.length; i++) {
        List details = await getShopDetails(shops[i]['place_id']);
        shops[i]['periods'] = details;
        shops[i]['distance'] = calculateDistance(
            location.latitude,
            location.longitude,
            shops[i]['geometry']['location']['lat'],
            shops[i]['geometry']['location']['lng']);
      }

      return (shops).map((m) => Shop.fromJson(m)).toList();
    }

    throw Exception('Failed to load shops');
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<List<Shop>> getShopListByName(String search) async {
    var shops = await getShopList();
    return shops
        .where((x) => x.name.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  Future<List<Shop>> getFilteredShopList(List selected) async {
    var shops = await getShopList();

    if (selected.isEmpty) {
      return shops;
    }

    return shops
        .where((x) =>
            (selected.contains(0) ? x.openNow : true) &&
            (selected.contains(1) ? x.distance <= 1.0 : true) &&
            (selected.contains(2)
                ? x.crowdedLevel == CrowdedLevel.Empty
                : true))
        .toList();
  }

  Future<List> getShopDetails(String placeId) async {
    final requestUrl =
        'https://maps.googleapis.com/maps/api/place/details/json';
    final response = await httpClient.get('$requestUrl'
        '?place_id=$placeId'
        '&fields=opening_hours'
        '&key=$key');

    if (response.statusCode == 200) {
      List periods = json.decode(utf8.decode(response.bodyBytes))['result']
          ['opening_hours']['periods'];
      return periods;
    }

    throw Exception('Failed to load shop details');
  }
}
