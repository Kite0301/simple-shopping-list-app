import 'package:flutter/material.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../services/storage_service.dart';

class ShoppingListProvider extends ChangeNotifier {
  List<ShoppingList> _shoppingLists = [];
  int _currentListIndex = 0;
  final StorageService _storageService = StorageService();
  bool _isLoading = true;

  List<ShoppingList> get shoppingLists => _shoppingLists;
  int get currentListIndex => _currentListIndex;
  bool get isLoading => _isLoading;

  ShoppingList? get currentShoppingList {
    if (_shoppingLists.isEmpty || _currentListIndex >= _shoppingLists.length) {
      return null;
    }
    return _shoppingLists[_currentListIndex];
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _shoppingLists = await _storageService.loadShoppingLists();
      _currentListIndex = await _storageService.getCurrentListIndex();
      
      if (_currentListIndex >= _shoppingLists.length) {
        _currentListIndex = 0;
      }
    } catch (e) {
      _shoppingLists = [
        ShoppingList(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'スーパー',
        )
      ];
      _currentListIndex = 0;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveData() async {
    await _storageService.saveShoppingLists(_shoppingLists);
    await _storageService.saveCurrentListIndex(_currentListIndex);
  }

  void setCurrentListIndex(int index) {
    if (index >= 0 && index < _shoppingLists.length) {
      _currentListIndex = index;
      _saveData();
      notifyListeners();
    }
  }

  Future<void> addShoppingList(String name) async {
    final newList = ShoppingList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _shoppingLists.add(newList);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateShoppingListName(int index, String newName) async {
    if (index >= 0 && index < _shoppingLists.length) {
      _shoppingLists[index].name = newName;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteShoppingList(int index) async {
    if (index >= 0 && index < _shoppingLists.length && _shoppingLists.length > 1) {
      _shoppingLists.removeAt(index);
      if (_currentListIndex >= _shoppingLists.length) {
        _currentListIndex = _shoppingLists.length - 1;
      }
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> addItem(String title, String memo) async {
    final currentList = currentShoppingList;
    if (currentList != null) {
      final newItem = ShoppingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        memo: memo,
      );
      currentList.addItem(newItem);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> updateItem(String itemId, String title, String memo) async {
    final currentList = currentShoppingList;
    if (currentList != null) {
      final itemIndex = currentList.items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final updatedItem = currentList.items[itemIndex].copyWith(
          title: title,
          memo: memo,
        );
        currentList.updateItem(itemId, updatedItem);
        await _saveData();
        notifyListeners();
      }
    }
  }

  Future<void> toggleItemPurchased(String itemId) async {
    final currentList = currentShoppingList;
    if (currentList != null) {
      final itemIndex = currentList.items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final item = currentList.items[itemIndex];
        final newPurchasedState = !item.isPurchased;
        final updatedItem = item.copyWith(
          isPurchased: newPurchasedState,
          completedAt: newPurchasedState ? DateTime.now() : null,
        );
        currentList.updateItem(itemId, updatedItem);
        await _saveData();
        notifyListeners();
      }
    }
  }

  Future<void> deleteItem(String itemId) async {
    final currentList = currentShoppingList;
    if (currentList != null) {
      currentList.removeItem(itemId);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> reorderItems(String movedItemId, String targetItemId) async {
    final currentList = currentShoppingList;
    if (currentList != null) {
      currentList.reorderItems(movedItemId, targetItemId);
      await _saveData();
      notifyListeners();
    }
  }

}