import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:safe_shop/view/components/feedback_form.dart';
import 'package:safe_shop/view/components/custom_expansion_tile.dart';
import 'package:safe_shop/common/colors.dart';
import 'package:safe_shop/common/dimensions.dart';
import 'package:safe_shop/common/fonts.dart';
import 'package:safe_shop/domain/shop.dart';

class ShopDetailsModal extends ModalRoute<void> {
  final Shop shop;
  final crowdedModel;

  ShopDetailsModal(this.shop, this.crowdedModel);

  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => mainBgColor.withOpacity(1.0);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: mainBgColor,
        title: Text(FlutterI18n.translate(context, 'views.main.title')),
      ),
      backgroundColor: mainBgColor,
      body: Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.symmetric(horizontal: extraLarge),
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: extraLarge),
                      child: Row(children: <Widget>[
                        crowdedModel.icon,
                        Expanded(
                            child: Text(
                          shop.name,
                          style: headerTextStyle,
                        ))
                      ]),
                    ),
                    Padding(
                        padding: EdgeInsets.only(bottom: extraLarge),
                        child: Text(shop.address, style: subHeaderTextStyle)),
                    Padding(
                        padding: EdgeInsets.only(bottom: extraLarge),
                        child: OpenHourInformation(shop: shop)),
                    Column(children: <Widget>[
                      Container(
                        child: LinearProgressIndicator(
                            backgroundColor: loaderBgColor,
                            value: crowdedModel.crowdedLevel,
                            valueColor:
                                AlwaysStoppedAnimation(crowdedModel.color)),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: medium),
                          child:
                              Text(crowdedModel.text, style: headerTextStyle)),
                    ]),
                  ])),
//          Padding(
//              padding: EdgeInsets.only(top: extraLarge),
//              child: CustomExpansionTile(
//                title: Text(
//                    FlutterI18n.translate(
//                        context, 'views.common.report_problem'),
//                    style: baseTextStyle),
//                backgroundColor: lighterCardBgColor,
//                headerBackgroundColor: cardBgColor,
//                children: <Widget>[
//                  Container(
//                      margin: EdgeInsets.symmetric(
//                          horizontal: large, vertical: medium),
//                      child: FeedbackForm(shop)),
//                ],
//              ))
        ],
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}

void getDetailsSheet(Shop shop, crowdedModel, BuildContext context) {
  Navigator.of(context).push(ShopDetailsModal(shop, crowdedModel));
}

class OpenHourInformation extends StatelessWidget {
  final Shop shop;

  OpenHourInformation({this.shop});

  @override
  build(context) => Row(children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Icon(Icons.directions_walk,
                  color: iconBaseColor, size: mediumIcon),
              Container(width: medium),
              Text(
                '${shop.distance} km',
                style: subHeaderTextStyle,
              )
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              Icon(shop.openNow ? Icons.check : Icons.error_outline,
                  color: shop.openNow ? iconSuccessColor : iconErrorColor,
                  size: largeIcon),
              Container(width: medium),
              Text(
                  FlutterI18n.translate(
                      context,
                      shop.openNow
                          ? 'views.common.opened'
                          : 'views.common.closed'),
                  style: shop.openNow
                      ? subHeaderTextStyle
                      : errorSubHeaderTextStyle),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              Icon(Icons.query_builder, color: iconBaseColor, size: mediumIcon),
              Container(width: medium),
              Text(
                  shop.openNow
                      ? FlutterI18n.translate(
                              context, 'views.common.open_until') +
                          ' ${shop.openingHours.closes}'
                      : FlutterI18n.translate(
                              context, 'views.common.open_from') +
                          ' ${shop.openingHours.opens}',
                  style: subHeaderTextStyle)
            ],
          ),
        ),
      ]);
}
