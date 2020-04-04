import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:safe_shop/view/shopping_list_view.dart';

import 'view/info_view.dart';
import 'view/list_view.dart';
import 'view/map_view.dart';
import 'common/colors.dart';

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;

  static List<Widget> _widgets = <Widget>[ShopList(), ShopMapView(), ShoppingCart(), InfoView()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override build(context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainBgColor,
        title: Text(FlutterI18n.translate(context, 'views.main.title')),
      ),
      body: Center(child: _widgets.elementAt(_selectedIndex),),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            activeIcon: IconShadowWidget(Icon(Icons.list, color: iconBaseColor), shadowColor: iconBaseColor,),
            title: Text(FlutterI18n.translate(context, 'views.main.tabs.list')),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            activeIcon: IconShadowWidget(Icon(Icons.map, color: iconBaseColor), shadowColor: iconBaseColor,),
            title: Text(
              FlutterI18n.translate(context, 'views.main.tabs.map'),
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            activeIcon: IconShadowWidget(Icon(Icons.shopping_basket, color: iconBaseColor), shadowColor: iconBaseColor,),
            title: Text(FlutterI18n.translate(context, 'views.main.tabs.shoppingList'))
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            activeIcon: IconShadowWidget(Icon(Icons.info, color: iconBaseColor), shadowColor: iconBaseColor,),
            title: Text(FlutterI18n.translate(context, 'views.main.tabs.info'))
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedIconTheme: IconThemeData(opacity: 1, color: notSelectedItemColor),
        unselectedItemColor: notSelectedItemColor,
        selectedIconTheme: IconThemeData(opacity: 0.7, color: Colors.amber[50], size: 30),
        selectedItemColor: Colors.amber[50],
        onTap: _onItemTapped,
      ),
    );
  }
}