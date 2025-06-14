import 'package:flutter/material.dart';
import '../models/shopping_list.dart';

class ListTabBar extends StatelessWidget {
  final List<ShoppingList> lists;
  final int currentIndex;
  final Function(int) onTabChanged;
  final VoidCallback onAddList;
  final Function(int) onEditList;
  final Function(int) onDeleteList;

  const ListTabBar({
    super.key,
    required this.lists,
    required this.currentIndex,
    required this.onTabChanged,
    required this.onAddList,
    required this.onEditList,
    required this.onDeleteList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _createTabController(context),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: lists.map((list) => Tab(
                child: GestureDetector(
                  onLongPress: () => _showTabOptions(context, lists.indexOf(list)),
                  child: Text(list.name),
                ),
              )).toList(),
              onTap: onTabChanged,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAddList,
            tooltip: '新しいリストを追加',
          ),
        ],
      ),
    );
  }

  TabController _createTabController(BuildContext context) {
    return TabController(
      length: lists.length,
      vsync: Scaffold.of(context),
      initialIndex: currentIndex,
    );
  }

  void _showTabOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '「${lists[index].name}」の操作',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('名前を変更'),
                onTap: () {
                  Navigator.pop(context);
                  onEditList(index);
                },
              ),
              if (lists.length > 1)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('削除'),
                  onTap: () {
                    Navigator.pop(context);
                    onDeleteList(index);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

}