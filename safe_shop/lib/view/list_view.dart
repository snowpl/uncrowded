import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:safe_shop/common/colors.dart';
import 'package:safe_shop/common/dimensions.dart';
import 'package:safe_shop/common/fonts.dart';
import 'package:safe_shop/domain/crowded_model.dart';
import 'package:safe_shop/domain/shop.dart';
import 'package:safe_shop/services/shop_service.dart';
import 'package:safe_shop/view/components/details.dart';

class ShopList extends StatefulWidget {
  @override
  createState() => _ShopListState();
}

class _ShopListState extends State<ShopList> {
  List<Shop> shops = [];
  bool loading = true;

  @override
  initState() {
    super.initState();
    BlocProvider.of<ShopsBloc>(context)..add(ShopsGetList());
    BlocProvider.of<ShopsBloc>(context)
      ..listen((state) {
        if (state is ShopsObtained) {
          setState(() {
            loading = false;
            shops = state.shops;
          });
        }
      });
  }

  _getFilters(context) => [
        FlutterI18n.translate(context, 'views.common.filters.open_now'),
        FlutterI18n.translate(context, 'views.common.filters.nearby'),
        FlutterI18n.translate(context, 'views.common.filters.safe')
      ];

  var selected = [];

  @override
  build(context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Positioned(top: 0, left: 0, right: 0, child: createSearchComponent()),
        Positioned(top: 55, left: 0, right: 0, child: createChipFilters()),
        Positioned(
            top: 105, left: 0, right: 0, bottom: 0, child: createShopList()),
      ],
    );
  }

  Padding createSearchComponent() => Padding(
      padding: EdgeInsets.symmetric(vertical: medium, horizontal: extraLarge),
      child: TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText:
                FlutterI18n.translate(context, 'views.common.search.hint'),
          ),
          textInputAction: TextInputAction.send,
          onSubmitted: (val) => BlocProvider.of<ShopsBloc>(context)
            ..add(ShopsGetListByName(val))));

  Container createShopList() => Container(
        child: loading
            ? Center(
                child: SizedBox(
                child: CircularProgressIndicator(),
                height: 50.0,
                width: 50.0,
              ))
            : ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: shops.length,
                itemBuilder: (_, index) => createShopItem(shops[index]),
              ),
      );

  Container createChipFilters() => Container(
      height: 30,
      margin:
          EdgeInsets.only(top: large, bottom: small, left: large, right: large),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _getFilters(context).length,
          itemBuilder: (BuildContext context, int index) => Padding(
              padding: EdgeInsets.only(left: medium, right: medium),
              child: FilterChip(
                  label: Text(
                    _getFilters(context)[index],
                  ),
                  onSelected: (bool value) {
                    loading = true;
                    if (selected.contains(index)) {
                      selected.remove(index);
                    } else {
                      selected.add(index);
                    }

                    BlocProvider.of<ShopsBloc>(context)
                      ..add(ShopsGetFilteredList(selected));

                    setState(() {});
                  },
                  selected: selected.contains(index),
                  selectedColor: Colors.green,
                  labelStyle: baseTextStyle,
                  checkmarkColor: Colors.white,
                  backgroundColor: notSelectedItemColor,
                  showCheckmark: true))));

  Card createShopItem(Shop shop) => Card(
      elevation: medium,
      margin: EdgeInsets.symmetric(horizontal: large, vertical: medium),
      color: cardBgColor,
      child: makeListTile(shop));

  GestureDetector makeListTile(Shop shop) {
    var crowdedModel = getCrowdedModel(shop.crowdedLevel);
    return GestureDetector(
        onTap: () => getDetailsSheet(shop, crowdedModel,
            context), // details sheet shall be produced after call for place details
        child: Container(
            margin: EdgeInsets.symmetric(vertical: medium, horizontal: large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(height: large),
                CrowdedInformation(crowdedModel: crowdedModel, name: shop.name),
                Container(height: large),
                Text(shop.address, style: subHeaderTextStyle),
                Container(height: small),
                OpenHourInformation(shop: shop)
              ],
            )));
  }
}

class OpenHourInformation extends StatelessWidget {
  final Shop shop;

  OpenHourInformation({this.shop});

  @override
  build(context) => Row(children: <Widget>[
        Icon(Icons.directions_walk, color: iconBaseColor, size: 15),
        Container(width: medium),
        Text(
          '${shop.distance} km',
          style: regularTextStyle,
        ),
        Container(width: large),
        Icon(shop.openNow ? Icons.check : Icons.error_outline,
            color: shop.openNow ? iconSuccessColor : iconErrorColor,
            size: 20.0),
        Container(width: medium),
        Text(
            FlutterI18n.translate(context,
                shop.openNow ? 'views.common.opened' : 'views.common.closed'),
            style: shop.openNow ? regularTextStyle : errorTextStyleSmall),
        Container(width: medium),
        Icon(Icons.query_builder, color: iconBaseColor, size: 20),
        Container(width: medium),
        Text(
            shop.openNow
                ? FlutterI18n.translate(context, 'views.common.open_until') +
                    ' ${shop.openingHours.closes}'
                : FlutterI18n.translate(context, 'views.common.open_from') +
                    ' ${shop.openingHours.opens}',
            style: regularTextStyle)
      ]);
}

class CrowdedInformation extends StatelessWidget {
  final CrowdedModel crowdedModel;
  final String name;

  CrowdedInformation({this.crowdedModel, this.name});

  @override
  build(context) => Row(
        children: <Widget>[
          Expanded(flex: 1, child: crowdedModel.icon),
          Expanded(
              flex: 4,
              child: Text(
                name,
                style: headerTextStyle,
              )),
          Expanded(
              flex: 4,
              child: Column(
                children: <Widget>[
                  Container(
                    child: LinearProgressIndicator(
                        backgroundColor: loaderBgColor,
                        value: crowdedModel.crowdedLevel,
                        valueColor: AlwaysStoppedAnimation(crowdedModel.color)),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: large, top: medium),
                      child:
                          Text(crowdedModel.text, style: subHeaderTextStyle)),
                ],
              )),
          Expanded(
            flex: 2,
            child: Icon(Icons.keyboard_arrow_right,
                color: iconBaseColor, size: 30.0),
          )
        ],
      );
}
