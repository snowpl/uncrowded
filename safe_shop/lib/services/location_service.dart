import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override get props => [];
}

class LocationInitialized extends LocationState {}
class LocationObtained extends LocationState {
  final locationData;
  LocationObtained(this.locationData);

  @override get props => [locationData];
}

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override get props => [];
}

class LocationGet extends LocationEvent {}

class LocationBloc extends Bloc<LocationEvent, LocationState> {

  final _locationService = LocationService();

  @override get initialState => LocationInitialized();

  @override mapEventToState(LocationEvent event) async* {
    if (event is LocationGet) {
      LocationData location = await _locationService.getLocation();
      yield LocationObtained(location);
    }
  }
}

class LocationService {

  final _location = Location();

  onLocationChanged() => _location.onLocationChanged();

  getLocation() async {
    var _serviceEnabled;
    var _permissionGranted;
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {return null;}
    }
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {return null;}
    }
    return await _location.getLocation();
  }
}
