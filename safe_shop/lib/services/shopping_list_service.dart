import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:safe_shop/domain/shopping_item.dart';
import 'package:sqflite/sqflite.dart';

abstract class ShoppingListState extends Equatable {
  const ShoppingListState();

  @override
  get props => [];
}

class ShoppingListInitialized extends ShoppingListState {}

class ShoppingListObtained extends ShoppingListState {
  final List<ShoppingItemGroup> items;
  ShoppingListObtained(this.items);

  @override
  get props => [items];
}

abstract class ShoppingListEvent extends Equatable {
  const ShoppingListEvent();

  @override
  get props => [];
}

class GetShoppingList extends ShoppingListEvent {}

class AddItemToGroup extends ShoppingListEvent {
  final ShoppingItem item;
  AddItemToGroup(this.item);

  @override
  get props => [item];
}

class EditItem extends ShoppingListEvent {
  final ShoppingItem item;
  EditItem(this.item);

  @override
  get props => [item];
}

class AddGroup extends ShoppingListEvent {
  final ShoppingItemGroup group;
  AddGroup(this.group);

  @override
  get props => [group];
}

class EditGroup extends ShoppingListEvent {
  final ShoppingItemGroup item;
  EditGroup(this.item);

  @override
  get props => [item];
}

class RemoveItemFromList extends ShoppingListEvent {
  final int itemId;
  final int groupId;
  RemoveItemFromList(this.itemId, this.groupId);

  @override
  get props => [itemId, groupId];
}

class RemoveGroup extends ShoppingListEvent {
  final int groupId;
  RemoveGroup(this.groupId);

  @override
  get props => [groupId];
}

class ShoppingListBloc extends Bloc<ShoppingListEvent, ShoppingListState> {
  final _service = _ShoppingListService();

  @override
  get initialState => ShoppingListInitialized();

  @override
  mapEventToState(ShoppingListEvent event) async* {
    if (event is GetShoppingList) {
      yield ShoppingListObtained(await _service.getShoppingList());
    }
    if (event is AddGroup) {
      await _service.addShoppingGroup(event.group);
      yield ShoppingListObtained(await _service.getShoppingList());
    }
    if (event is EditGroup) {
      await _service.editShoppingGroup(event.item);
      yield ShoppingListObtained(await _service.getShoppingList());
    }
    if (event is AddItemToGroup) {
      await _service.addShoppingItemToGroup(event.item);
      yield ShoppingListObtained(await _service.getShoppingList());
    }
    if (event is EditItem) {
      await _service.editShoppingItem(event.item);
      yield ShoppingListObtained(await _service.getShoppingList());
    }
    if (event is RemoveItemFromList) {
      await _service.removeShoppingItem(event.itemId, event.groupId);
      yield ShoppingListObtained(await _service.getShoppingList());
    }
    if (event is RemoveGroup) {
      await _service.removeShoppingItemGroup(event.groupId);
      yield ShoppingListObtained(await _service.getShoppingList());
    }
  }
}

class _ShoppingListService {
  var db;
  final httpClient = http.Client();

  _ShoppingListService() {
    openDatabase('duck_uncrowded.db').then((d) async {
      db = d;
      await db.execute(''
          'create table if not exists shopping_list_item_group '
          '(id integer primary key, group_name varchar, group_color integer)');
      await db.execute(''
          'create table if not exists shopping_list_item '
          '(id integer primary key, group_id integer, number_of_items integer, name varchar, description varchar)');
    });
  }

  Future<List<ShoppingItemGroup>> getShoppingList() async {
    final List<ShoppingItemGroup> groups =
        (await db.rawQuery('select * from shopping_list_item_group'))
            .map<ShoppingItemGroup>((m) => ShoppingItemGroup.fromJson(m))
            .toList();
    final List<ShoppingItem> items =
        (await db.rawQuery('select * from shopping_list_item'))
            .map<ShoppingItem>((m) => ShoppingItem.fromJson(m))
            .toList();
    groups.forEach((g) =>
        g.shoppingItems = items.where((i) => g.id == i.groupId).toList());
    return groups;
  }

  Future addShoppingGroup(ShoppingItemGroup group) async {
    final id = await getMaxId('group');
    await db.rawInsert('insert into shopping_list_item_group values ('
        '$id, "${group.groupName}", ${group.groupColor.value}'
        ')');
  }

  Future editShoppingGroup(ShoppingItemGroup group) async {
    await db.rawUpdate('update shopping_list_item_group set '
        'group_name = "${group.groupName}", group_color = ${group.groupColor.value} '
        'where id = ${group.id}'
        '');
  }

  Future addShoppingItemToGroup(ShoppingItem item) async {
    final id = await getMaxId('item');
    await db.rawInsert('insert into shopping_list_item values ('
        '$id, ${item.groupId}, ${item.numberOfItems}, "${item.name}", "${item.description}"'
        ')');
  }

  Future editShoppingItem(ShoppingItem item) async {
    await db.rawUpdate('update shopping_list_item set '
        'name = "${item.name}", description = "${item.description}", number_of_items = ${item.numberOfItems} '
        'where id = ${item.id}'
        '');
  }

  Future removeShoppingItem(int id, int groupId) async {
    await db.rawUpdate(
        'delete from shopping_list_item where id = $id and group_id = $groupId');
  }

  Future removeShoppingItemGroup(int groupId) async {
    await db.rawUpdate(
        'delete from shopping_list_item_group where group_id = $groupId');
  }

  Future<int> getMaxId(String type) async {
    var queryResult;
    switch (type) {
      case 'group':
        queryResult =
            (await db.rawQuery('select max(id) from shopping_list_item_group'));
        break;
      case 'item':
        queryResult =
            (await db.rawQuery('select max(id) from shopping_list_item'));
        break;
      default:
        return 1;
    }
    if (queryResult.length == 1)
      return (queryResult[0]['max(id)'] ?? 0) + 1;
    else
      return 1;
  }
}
