import 'package:flutter/material.dart';
import 'package:safe_shop/common/colors.dart';
import 'package:safe_shop/domain/shop.dart';

class CrowdedModel {
  Color color;
  String text;
  double crowdedLevel;
  Icon icon;

  CrowdedModel({this.icon, this.color, this.text, this.crowdedLevel});
}

CrowdedModel getCrowdedModel(CrowdedLevel level) {
  if(level == CrowdedLevel.Crowded)
    return CrowdedModel(icon: Icon(Icons.block, color: iconErrorColor) ,color: iconErrorColor, text: "Tłum", crowdedLevel: 1.0);
  if(level == CrowdedLevel.Moderate){
    return CrowdedModel(icon: Icon(Icons.change_history, color: iconWarningColor), color: iconWarningColor, text: "Srednie oblozenie", crowdedLevel: 0.66);
  }else{
    return CrowdedModel(icon: Icon(Icons.check, color: iconSuccessColor), color: iconSuccessColor, text: "Bezpiecznie", crowdedLevel: 0.30);
  }
}