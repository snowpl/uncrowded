import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_shop/common/colors.dart';
import 'package:safe_shop/common/dimensions.dart';
import 'package:safe_shop/common/fonts.dart';
import 'package:safe_shop/domain/shopping_item.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:safe_shop/services/shopping_list_service.dart';

class AddGroupForm extends StatefulWidget {
  @override
  AddGroupFormState createState() {
    return AddGroupFormState();
  }
}

class AddGroupFormState extends State<AddGroupForm> {
  final _formKey = GlobalKey<FormState>();
  ShoppingItemGroup newGroup = new ShoppingItemGroup();

  @override
  void setState(fn) {
    super.setState(fn);
  }

  void setColor(Color groupColor) {
    setState(() {
      newGroup.groupColor = groupColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          Container(height: large),
          Row(children: [
            Expanded(flex: 1, child: Container()),
            Expanded(
                flex: 4,
                child: Container(
                    child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Group name',
                    fillColor: Colors.white,
                    labelStyle: baseTextStyle,
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
                  },
                ))),
            Expanded(flex: 1, child: Container()),
            Expanded(
                flex: 2,
                child: RaisedButton(
                  onPressed: () {
                    showDialog(
                        context: context, builder: (_) => colorPickerDialog());
                  },
                  child: Icon(Icons.palette, color: Colors.white),
                  color: lighterCardBgColor,
                )),
            Expanded(flex: 1, child: Container()),
          ]),
          Container(height: large),
          Row(children: [
            Expanded(flex: 1, child: Container()),
            Expanded(
                flex: 2,
                child: (RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Close',
                    style: baseTextStyle,
                  ),
                  color: lighterCardBgColor,
                ))),
            Expanded(flex: 1, child: Container()),
            Expanded(
                flex: 2,
                child: (RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      print(newGroup.groupName);
                      BlocProvider.of<ShoppingListBloc>(context)
                        ..add(AddGroup(newGroup));
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Save',
                    style: baseTextStyle,
                  ),
                  color: lighterCardBgColor,
                ))),
            Expanded(flex: 1, child: Container()),
            Expanded(
                flex: 2,
                child: (RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      print(newGroup.groupName);
                      BlocProvider.of<ShoppingListBloc>(context)
                        ..add(AddGroup(newGroup));
                    }
                  },
                  child: Text(
                    'Add more',
                    style: baseTextStyle,
                  ),
                  color: lighterCardBgColor,
                ))),
            Expanded(flex: 1, child: Container()),
          ])
        ]));
  }

  colorPickerDialog() => AlertDialog(
      title: Text("Choose your group color"),
      content: Container(
          height: 300,
          child: MaterialColorPicker(
              onColorChange: (Color color) {
                setColor(color);
              },
              selectedColor: Colors.red)));
}
