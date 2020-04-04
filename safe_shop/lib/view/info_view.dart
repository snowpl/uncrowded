
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:safe_shop/domain/virus_information.dart';
import 'package:safe_shop/view/components/custom_expansion_tile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/colors.dart';
import '../common/dimensions.dart';
import '../common/fonts.dart';

class InfoView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: mainBgColor,
      child: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(extraLarge),
            child: Center(child: Text(FlutterI18n.translate(context, 'views.info.title'), style: errorHeaderTextStyle)),
          ),
          createExpansionTile(InformationEnum.Symptons),
          Container(height: small, color: mainBgColor),
          createExpansionTile(InformationEnum.Prevention),
          Container(height: small, color: mainBgColor),
          createExpansionTile(InformationEnum.TreatmentSelfCare),
          Container(height: small, color: mainBgColor),
          createExpansionTile(InformationEnum.TreatmentMedical)
        ],
      )
    );
  }

  createExpansionTile(InformationEnum informationType){
  var info = getInformationData(informationType);
  return CustomExpansionTile(
            title: Text(info.title, style: baseTextStyle),  
            backgroundColor: lighterCardBgColor,
            headerBackgroundColor: cardBgColor,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: large, vertical: medium),
                child: Text(info.subTitle, style: baseTextStyle)
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: large, vertical: medium),
                child: info.information
              ),
              ReadMoreButton(link: info.link)
            ],
          );
  }
}

class ReadMoreButton extends StatelessWidget {
  final String link;

  ReadMoreButton({this.link});

  @override
  Widget build(BuildContext context) {
    return Container(
                width: 150,
                child: FlatButton(
                child: Row(
                  children: [
                    Icon(Icons.public),
                    Text(FlutterI18n.translate(context, 'views.info.read_more')),                
                  ]), 
                onPressed: () {
                  launchURL(link);
                },
                color: Colors.white,            
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                  Radius.circular(large),
                ),
              )
              ));
  }
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    //TODO: somehow show user information about error
  }
}
