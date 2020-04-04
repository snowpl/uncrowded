
import 'package:flutter/material.dart';

import 'colors.dart';

final baseTextStyle = TextStyle(color: baseFontColor);

final headerTextStyle = baseTextStyle.copyWith(
  color: baseFontColor,
  fontSize: 18.0,
  fontWeight: FontWeight.w600
);

final errorTextStyleSmall = regularTextStyle.copyWith(
  color: fontErrorColor,
  fontWeight: FontWeight.bold
);

final errorHeaderTextStyle = headerTextStyle.copyWith(
  color: fontErrorColor
);

final errorSubHeaderTextStyle = subHeaderTextStyle.copyWith(
  color: fontErrorColor
);

final regularTextStyle = baseTextStyle.copyWith(
  color: baseFontColor,
  fontSize: 9.0,
  fontWeight: FontWeight.w400
);

final subHeaderTextStyle = regularTextStyle.copyWith(
  fontSize: 12.0
);

final speedDialLabelTextStyle = headerTextStyle.copyWith(
  color: mainBgColor
);
