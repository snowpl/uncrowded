import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:safe_shop/services/shopping_list_service.dart';

import 'common/theme_bloc.dart';
import 'main_view.dart';
import 'services/geo_scheduler_service.dart';
import 'services/location_service.dart';
import 'services/shop_service.dart';
import 'services/feedback_service.dart';

void main() async {
  final flutterI18nDelegate = FlutterI18nDelegate(
      useCountryCode: false,
      fallbackFile: 'en',
      path: 'assets/i18n',
      forcedLocale: Locale('pl'));
  WidgetsFlutterBinding.ensureInitialized();
  await flutterI18nDelegate.load(null);

  runApp(MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()..add(SetDefaultTheme()),),
        BlocProvider<LocationBloc>(create: (context) => LocationBloc(),),
        BlocProvider<ShopsBloc>(create: (context) => ShopsBloc(),),
        BlocProvider<ShoppingListBloc>(create: (context) => ShoppingListBloc()),
        BlocProvider<FeedbackBloc>(create: (context) => FeedbackBloc(),),
      ],
      child: MyApp(flutterI18nDelegate)
  ));
  GeoSchedulerService().initialize();
}

class MyApp extends StatelessWidget {

  final FlutterI18nDelegate flutterI18nDelegate;

  MyApp(this.flutterI18nDelegate);

  @override build(context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) => MaterialApp(
        theme: (state as DefaultTheme).themeData,
        home: MyStatefulWidget(),
        localizationsDelegates: [
          flutterI18nDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
      ),
    );
  }
}
