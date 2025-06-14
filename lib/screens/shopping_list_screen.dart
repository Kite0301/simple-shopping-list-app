import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/shopping_item_tile.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/list_tab_bar.dart';
import '../models/shopping_item.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShoppingListProvider>(context, listen: false).initialize();
    });
  }

  List<Map<String, dynamic>> _buildListItems(currentList) {
    final List<Map<String, dynamic>> listItems = [];
    
    // ソート済みアイテムを取得
    final sortedItems = currentList.sortedItems;
    
    // 未完了アイテムを追加
    final unpurchasedItems = sortedItems.where((ShoppingItem item) => !item.isPurchased).toList();
    for (final item in unpurchasedItems) {
      listItems.add({'type': 'item', 'item': item});
    }
    
    // 完了済みアイテムがある場合は区切り線を追加
    final purchasedItems = sortedItems.where((ShoppingItem item) => item.isPurchased).toList();
    if (purchasedItems.isNotEmpty) {
      listItems.add({'type': 'divider'});
      
      // 完了済みアイテムを追加
      for (final item in purchasedItems) {
        listItems.add({'type': 'item', 'item': item});
      }
    }
    
    return listItems;
  }

  void _onReorder(int oldIndex, int newIndex, ShoppingListProvider provider) {
    final listItems = _buildListItems(provider.currentShoppingList!);
    
    // インデックスの境界チェック
    if (oldIndex >= listItems.length || newIndex >= listItems.length) {
      return;
    }
    
    final movedItem = listItems[oldIndex];
    
    // 区切り線は移動できない
    if (movedItem['type'] == 'divider') {
      return;
    }
    
    // newIndexの調整
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    // 調整後の境界チェック
    if (newIndex >= listItems.length || newIndex < 0) {
      return;
    }
    
    final targetItem = listItems[newIndex];
    
    // 区切り線を跨いだ移動は許可しない
    if (targetItem['type'] == 'divider') {
      return;
    }
    
    final item = movedItem['item'] as ShoppingItem;
    final targetItemObj = targetItem['item'] as ShoppingItem;
    
    // 同じ完了状態内での移動のみ許可
    if (item.isPurchased == targetItemObj.isPurchased) {
      provider.reorderItems(item.id, targetItemObj.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final currentList = provider.currentShoppingList;
        if (currentList == null) {
          return const Scaffold(
            body: Center(
              child: Text('リストが見つかりません'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('買い物リスト'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: ListTabBar(
                lists: provider.shoppingLists,
                currentIndex: provider.currentListIndex,
                onTabChanged: provider.setCurrentListIndex,
                onAddList: _showAddListDialog,
                onEditList: _showEditListDialog,
                onDeleteList: _showDeleteListDialog,
              ),
            ),
          ),
          body: currentList.items.isEmpty
              ? const Center(
                  child: Text(
                    'アイテムがありません\n下の＋ボタンで追加してください',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _buildListItems(currentList).length,
                  onReorder: (oldIndex, newIndex) => _onReorder(oldIndex, newIndex, provider),
                  itemBuilder: (context, index) {
                    final listItem = _buildListItems(currentList)[index];
                    
                    if (listItem['type'] == 'divider') {
                      return Container(
                        key: ValueKey('divider'),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Divider(thickness: 2, color: Colors.grey[400])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '完了済み',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(thickness: 2, color: Colors.grey[400])),
                          ],
                        ),
                      );
                    } else {
                      final item = listItem['item'] as ShoppingItem;
                      return ShoppingItemTile(
                        key: ValueKey(item.id),
                        item: item,
                        onToggle: () => provider.toggleItemPurchased(item.id),
                        onEdit: () => _showEditItemDialog(item.id, item.title, item.memo),
                        onDelete: () => provider.deleteItem(item.id),
                      );
                    }
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddItemDialog,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        onAdd: (title, memo) {
          Provider.of<ShoppingListProvider>(context, listen: false)
              .addItem(title, memo);
        },
      ),
    );
  }

  void _showEditItemDialog(String itemId, String currentTitle, String currentMemo) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        initialTitle: currentTitle,
        initialMemo: currentMemo,
        title: 'アイテムを編集',
        onAdd: (title, memo) {
          Provider.of<ShoppingListProvider>(context, listen: false)
              .updateItem(itemId, title, memo);
        },
      ),
    );
  }

  void _showAddListDialog() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.add, color: Colors.green),
              const SizedBox(width: 8),
              const Text('新しいリストを追加'),
            ],
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'リスト名',
                hintText: 'ドラッグストア、コンビニなど',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.list),
              ),
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'リスト名を入力してください';
                }
                if (value.trim().length > 20) {
                  return 'リスト名は20文字以内で入力してください';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                if (formKey.currentState!.validate()) {
                  Provider.of<ShoppingListProvider>(context, listen: false)
                      .addShoppingList(value.trim());
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Provider.of<ShoppingListProvider>(context, listen: false)
                      .addShoppingList(controller.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }

  void _showEditListDialog(int index) {
    final provider = Provider.of<ShoppingListProvider>(context, listen: false);
    final controller = TextEditingController(text: provider.shoppingLists[index].name);
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.edit, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('リスト名を編集'),
            ],
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'リスト名',
                hintText: 'スーパー、ドラッグストアなど',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.list),
              ),
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'リスト名を入力してください';
                }
                if (value.trim().length > 20) {
                  return 'リスト名は20文字以内で入力してください';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                if (formKey.currentState!.validate()) {
                  provider.updateShoppingListName(index, value.trim());
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  provider.updateShoppingListName(index, controller.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteListDialog(int index) {
    final provider = Provider.of<ShoppingListProvider>(context, listen: false);
    if (provider.shoppingLists.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('最低1つのリストが必要です'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final list = provider.shoppingLists[index];
    final itemCount = list.items.length;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              const Text('リストを削除'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('「${list.name}」を削除しますか？'),
              const SizedBox(height: 8),
              if (itemCount > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'このリストには$itemCount個のアイテムが含まれています。削除すると元に戻せません。',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.deleteShoppingList(index);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('「${list.name}」を削除しました'),
                    action: SnackBarAction(
                      label: '元に戻す',
                      onPressed: () {
                        // 元に戻す機能は複雑なので、とりあえずメッセージのみ
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('元に戻す機能は今後実装予定です')),
                        );
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }
}