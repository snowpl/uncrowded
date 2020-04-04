import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'dimensions.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override get props => [];
}

class DefaultTheme extends ThemeState {
  final ThemeData themeData;

  DefaultTheme(this.themeData);

  @override get props => [themeData];
}

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override get props => [];
}

class SetDefaultTheme extends ThemeEvent {}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {

  static final defaultThemeData = ThemeData(
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(large),),
      ),
    ),
    backgroundColor: mainBgColor,
    canvasColor: mainBgColor
  );

  @override get initialState => DefaultTheme(defaultThemeData);

  @override mapEventToState(ThemeEvent event) async* {
    if (event is SetDefaultTheme) { yield DefaultTheme(defaultThemeData); }
  }
}
