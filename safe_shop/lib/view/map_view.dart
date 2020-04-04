import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe_shop/domain/crowded_model.dart';
import 'package:safe_shop/view/components/details.dart';
import 'package:safe_shop/services/location_service.dart';
import 'package:safe_shop/services/shop_service.dart';

class ShopMapView extends StatefulWidget {

  @override createState() => _ShopMapViewState();
}

class _ShopMapViewState extends State<ShopMapView> {
  
  var _screenSize;

  final _controller = Completer<GoogleMapController>();

  var _current = CameraPosition(target: LatLng(0, 0), zoom: 15,);
  var _markers = Set<Marker>();

  @override didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
  }

  @override initState() {
    super.initState();
    BlocProvider.of<LocationBloc>(context)..add(LocationGet());
    BlocProvider.of<LocationBloc>(context)..listen((state) async {
      if (state is LocationObtained) {
        if (state.locationData == null) { /* do something */ return; }
        final zoom = await (await _controller.future).getZoomLevel();
        setState(() {
          _current = CameraPosition(
            target: LatLng(state.locationData.latitude, state.locationData.longitude),
            zoom: zoom,
          );
        });
      }
    });
    BlocProvider.of<ShopsBloc>(context)..listen((state) {
      if (state is ShopsObtained) {
        setState(() {
          _markers = Set();
          state.shops.forEach((shop) => _markers.add(Marker(
            markerId: MarkerId(shop.id),
            position: LatLng(shop.position.latitude, shop.position.longitude,),
            onTap: () => getDetailsSheet(shop, getCrowdedModel(shop.crowdedLevel), context),
          ),),);
        });
      }
    });
  }

  @override build(context) => Stack(children: <Widget>[
    GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _current,
      onMapCreated: (controller) => _controller.complete(controller),
      compassEnabled: true,
      mapToolbarEnabled: true,
      buildingsEnabled: true,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      zoomGesturesEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      markers: _markers,
    ),
    Positioned(
      top: _screenSize.height / 15,
      left: _screenSize.width / 15,
      right: _screenSize.width / 15,
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: FlutterI18n.translate(context, 'views.common.search.hint'),
        ),
        textInputAction: TextInputAction.send,
        onSubmitted: (val) => BlocProvider.of<ShopsBloc>(context)..add(ShopsGetListByName(val))
      ),
    ),
  ],);
}
