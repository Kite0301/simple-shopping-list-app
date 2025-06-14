import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_list.dart';

class StorageService {
  static const String _shoppingListsKey = 'shopping_lists';
  static const String _currentListIndexKey = 'current_list_index';

  Future<List<ShoppingList>> loadShoppingLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? listsJson = prefs.getString(_shoppingListsKey);
      
      if (listsJson == null) {
        final defaultList = ShoppingList(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'スーパー',
        );
        await saveShoppingLists([defaultList]);
        return [defaultList];
      }

      final List<dynamic> listData = json.decode(listsJson);
      return listData.map((data) => ShoppingList.fromJson(data)).toList();
    } catch (e) {
      final defaultList = ShoppingList(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'スーパー',
      );
      return [defaultList];
    }
  }

  Future<void> saveShoppingLists(List<ShoppingList> lists) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String listsJson = json.encode(lists.map((list) => list.toJson()).toList());
      await prefs.setString(_shoppingListsKey, listsJson);
    } catch (e) {
      throw Exception('Failed to save shopping lists: $e');
    }
  }

  Future<int> getCurrentListIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentListIndexKey) ?? 0;
  }

  Future<void> saveCurrentListIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentListIndexKey, index);
  }
}