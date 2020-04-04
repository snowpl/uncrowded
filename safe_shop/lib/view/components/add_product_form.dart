import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_shop/common/colors.dart';
import 'package:safe_shop/common/dimensions.dart';
import 'package:safe_shop/common/fonts.dart';
import 'package:safe_shop/domain/shopping_item.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:safe_shop/services/shopping_list_service.dart';

class MyCustomForm extends StatefulWidget {
  final List<ShoppingItemGroup> shoppingGroups;

  MyCustomForm({this.shoppingGroups});
  @override
  MyCustomFormState createState() {
    return MyCustomFormState(shoppingGroups: shoppingGroups);
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  final List<ShoppingItemGroup> shoppingGroups;
  ShoppingItemGroup newGroup = new ShoppingItemGroup();
  ShoppingItem shoppingItem = new ShoppingItem(numberOfItems: 0, groupId: 1);
  Color chosenGroupColor = Colors.white;

  MyCustomFormState({this.shoppingGroups});

  @override
  void setState(fn) {
    super.setState(fn);
  }

  void setColor(Color groupColor) {
    setState(() {
      newGroup.groupColor = groupColor;
    });
  }

  void add() {
    setState(() {
      shoppingItem.numberOfItems++;
    });
  }

  void minus() {
    setState(() {
      if (shoppingItem.numberOfItems != 0) shoppingItem.numberOfItems--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          Container(
              margin: EdgeInsets.all(large),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Product name',
                  fillColor: Colors.white,
                  labelStyle: baseTextStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(),
                  ),
                ),
                onFieldSubmitted: (String value) {
                  shoppingItem.name = value;
                },
              )),
          Text(
            'Quantity',
            style: headerTextStyle,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                shape: CircleBorder(),
                onPressed: minus,
                child: Icon(IconData(0xe15b, fontFamily: 'MaterialIcons'),
                    color: Colors.black),
              ),
              Text('${shoppingItem.numberOfItems}',
                  style: TextStyle(fontSize: 36.0, color: Colors.white)),
              RaisedButton(
                shape: CircleBorder(),
                onPressed: add,
                child: Icon(
                  Icons.add,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Container(
              margin: EdgeInsets.all(large),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Opis',
                  fillColor: Colors.white,
                  labelStyle: baseTextStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(),
                  ),
                ),
                onFieldSubmitted: (String value) {
                  shoppingItem.description = value;
                },
              )),
          createDropDown(shoppingGroups),
          RaisedButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                BlocProvider.of<ShoppingListBloc>(context)
                  ..add(AddGroup(newGroup));
                BlocProvider.of<ShoppingListBloc>(context)
                  ..add(AddItemToGroup(shoppingItem));
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Add',
              style: baseTextStyle,
            ),
            color: lighterCardBgColor,
          )
        ]));
  }

  createDropDown(List<ShoppingItemGroup> shoppingGroups) {
    if (shoppingGroups.length > 0) {
      return DropdownButton(
          items: shoppingGroups
              .map((x) => DropdownMenuItem(
                  value: x.id, child: Text(x.groupName, style: baseTextStyle)))
              .toList(),
          onChanged: (int value) {
            shoppingItem.groupId = value;
          },
          underline: Container(),
          value: 1,
          style: TextStyle(color: Colors.purple),
          icon: Icon(Icons.arrow_drop_down, color: iconBaseColor));
    }
    return Row(children: [
      Expanded(flex: 1, child: Container()),
      Expanded(
          flex: 4,
          child: Container(
              child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Group name',
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(),
              ),
            ),
            onChanged: (String value) {
              newGroup.groupName = value;
            },
            onSaved: (String value) {
              newGroup.groupName = value;
              shoppingItem.groupId = 1;
            },
          ))),
      Expanded(flex: 1, child: Container()),
      Expanded(
          flex: 2,
          child: RaisedButton(
            onPressed: () {
              showDialog(context: context, builder: (_) => colorPickerDialog());
            },
            child: Icon(Icons.palette, color: Colors.white),
            color: lighterCardBgColor,
          )),
      Expanded(flex: 1, child: Container()),
    ]);
  }

  colorPickerDialog() => AlertDialog(
      title: Text("Choose your group color"),
      content: Container(
          height: 200,
          child: MaterialColorPicker(
              onColorChange: (Color color) {
                setColor(color);
              },
              selectedColor: Colors.red)));
}
