import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:safe_shop/common/colors.dart';
import 'package:safe_shop/common/dimensions.dart';
import 'package:safe_shop/common/fonts.dart';
import 'package:safe_shop/domain/shopping_item.dart';
import 'package:safe_shop/services/shopping_list_service.dart';

import 'components/add_group_form.dart';
import 'components/add_product_form.dart';

class ShoppingCart extends StatefulWidget {
  @override
  createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  List<ShoppingItemGroup> shoppingGroups = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ShoppingListBloc>(context)..add(GetShoppingList());
    BlocProvider.of<ShoppingListBloc>(context)
      ..listen((state) {
        if (state is ShoppingListObtained) {
          print(state.items[0].shoppingItems[0].description);
          setState(() => shoppingGroups = state.items);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: mainBgColor,
        floatingActionButton: createActionButtonMenu(),
        body: ListView.builder(
          itemCount: shoppingGroups.length,
          itemBuilder: (_, index) => createGroup(shoppingGroups[index]),
        ));
  }

  createGroup(ShoppingItemGroup itemGroup) => Container(
      child: Container(
          margin: EdgeInsets.all(large),
          child: Stack(children: [
            Positioned(
              top: 15,
              child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    itemGroup.groupName,
                    style: TextStyle(color: itemGroup.groupColor),
                  )),
            ),
            Positioned(
                child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: medium, horizontal: extraLarge),
                    foregroundDecoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: itemGroup.groupColor,
                                width: extraSmall))),
                    child: createProductList(itemGroup))),
          ])));

  createProductList(ShoppingItemGroup itemGroup) => ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: itemGroup.shoppingItems?.length ?? 0,
        itemBuilder: (_, index) => createShoppingListCard(
            itemGroup.shoppingItems[index], itemGroup.id, itemGroup.groupColor),
      );

  createShoppingListCard(ShoppingItem item, int groupId, Color groupColor) =>
      Card(
          elevation: medium,
          margin: EdgeInsets.symmetric(horizontal: small, vertical: medium),
          color: cardBgColor,
          child: Container(
              foregroundDecoration: BoxDecoration(
                border: Border.all(color: groupColor, width: extraSmall),
                borderRadius: BorderRadius.all(Radius.circular(large)),
              ),
              padding:
                  EdgeInsets.symmetric(vertical: medium, horizontal: small),
              child: GestureDetector(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: Icon(
                            Icons.check_circle_outline,
                            color: Colors.grey,
                          )),
                      Expanded(
                          flex: 2,
                          child: Text(item.name, style: baseTextStyle)),
                      Expanded(
                          flex: 2,
                          child: Text('Ilość: ${item.numberOfItems}',
                              style: baseTextStyle)),
                      Expanded(
                          flex: 3,
                          child: Text(
                              isNull(item.description) ? '' : item.description,
                              style: baseTextStyle)),
                    ]),
                onTap: () => BlocProvider.of<ShoppingListBloc>(context)
                  ..add(RemoveItemFromList(item.id, groupId)),
                onLongPress: () => print('Edit the item'),
              )));

  isNull(String item) => item == null || item == '' || item == 'null';

  SpeedDial createActionButtonMenu() => SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        visible: true,
        closeManually: false,
        curve: Curves.easeIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.4,
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
            label: 'Produkt',
            labelStyle: speedDialLabelTextStyle,
            onTap: () => {
              showModalBottomSheet(
                  context: context,
                  builder: (builder) {
                    return Container(
                        height: 400,
                        child: Center(
                            child:
                                MyCustomForm(shoppingGroups: shoppingGroups)));
                  })
            },
          ),
          SpeedDialChild(
              child: Icon(Icons.menu),
              backgroundColor: Colors.red,
              label: 'Nowa grupa',
              labelStyle: speedDialLabelTextStyle,
              onTap: () => {
                    showModalBottomSheet(
                        context: context,
                        builder: (builder) {
                          return Container(
                              height: 400,
                              child: Center(child: AddGroupForm()));
                        })
                  })
        ],
      );
}
