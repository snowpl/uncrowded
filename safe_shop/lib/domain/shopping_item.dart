import 'package:flutter/material.dart';

class ShoppingItemGroup{
  String groupName;
  int id;
  Color groupColor;
  List<ShoppingItem> shoppingItems;

  ShoppingItemGroup({this.groupColor, this.groupName, this.id, this.shoppingItems});

  factory ShoppingItemGroup.fromJson(Map<String, dynamic> json) {
    return ShoppingItemGroup(
      id: json['id'],
      groupName: json['group_name'],
      groupColor: Color(json['group_color']),
    );
  }
}

class ShoppingItem {
  int id;
  String name;
  String description;
  int numberOfItems;
  int groupId;

  ShoppingItem({this.id, this.name, this.description, this.numberOfItems, this.groupId});

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      groupId: json['group_id'],
      name: json['name'],
      description: json['description'] ?? '',
      numberOfItems: json['number_of_items'],
    );
  }
}