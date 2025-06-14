import 'shopping_item.dart';

class ShoppingList {
  final String id;
  String name;
  List<ShoppingItem> items;
  DateTime createdAt;

  ShoppingList({
    required this.id,
    required this.name,
    List<ShoppingItem>? items,
    DateTime? createdAt,
  }) : items = items ?? [],
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'],
      name: json['name'],
      items: (json['items'] as List?)
          ?.map((item) => ShoppingItem.fromJson(item))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  void addItem(ShoppingItem item) {
    items.add(item);
  }

  void removeItem(String itemId) {
    items.removeWhere((item) => item.id == itemId);
  }

  void updateItem(String itemId, ShoppingItem updatedItem) {
    final index = items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      items[index] = updatedItem;
    }
  }

  List<ShoppingItem> get unpurchasedItems {
    return items.where((ShoppingItem item) => !item.isPurchased).toList();
  }

  List<ShoppingItem> get purchasedItems {
    return items.where((ShoppingItem item) => item.isPurchased).toList();
  }

  List<ShoppingItem> get sortedItems {
    final unpurchased = unpurchasedItems..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final purchased = purchasedItems..sort((a, b) {
      // 完了時刻順（最新が上）、completedAtがnullの場合はsortOrderで代替
      if (a.completedAt != null && b.completedAt != null) {
        return b.completedAt!.compareTo(a.completedAt!);
      } else if (a.completedAt != null) {
        return -1;
      } else if (b.completedAt != null) {
        return 1;
      } else {
        return a.sortOrder.compareTo(b.sortOrder);
      }
    });
    return [...unpurchased, ...purchased];
  }

  void reorderItems(String movedItemId, String targetItemId) {
    try {
      final movedItem = items.firstWhere((item) => item.id == movedItemId);
      
      // 同じ完了状態のアイテムのみを対象にする
      final sameStatusItems = items.where((ShoppingItem item) => item.isPurchased == movedItem.isPurchased).toList();
      sameStatusItems.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      
      final movedIndexInGroup = sameStatusItems.indexWhere((item) => item.id == movedItemId);
      final targetIndexInGroup = sameStatusItems.indexWhere((item) => item.id == targetItemId);
      
      if (movedIndexInGroup != -1 && targetIndexInGroup != -1 && movedIndexInGroup != targetIndexInGroup) {
        // 新しいソート順序を計算
        int newSortOrder;
        
        // ドラッグ方向を考慮して適切な位置を計算
        int actualTargetIndex = targetIndexInGroup;
        if (movedIndexInGroup < targetIndexInGroup) {
          // 下方向にドラッグ：ターゲットの後ろに挿入
          actualTargetIndex = targetIndexInGroup;
        } else {
          // 上方向にドラッグ：ターゲットの前に挿入  
          actualTargetIndex = targetIndexInGroup;
        }
        
        if (actualTargetIndex == 0 && movedIndexInGroup > targetIndexInGroup) {
          // 最初の位置に移動
          newSortOrder = sameStatusItems[0].sortOrder - 1000;
        } else if (actualTargetIndex == sameStatusItems.length - 1 && movedIndexInGroup < targetIndexInGroup) {
          // 最後の位置に移動
          newSortOrder = sameStatusItems[sameStatusItems.length - 1].sortOrder + 1000;
        } else {
          // 中間位置に移動
          if (movedIndexInGroup < targetIndexInGroup) {
            // 下方向への移動：ターゲットと次のアイテムの間
            if (actualTargetIndex == sameStatusItems.length - 1) {
              newSortOrder = sameStatusItems[actualTargetIndex].sortOrder + 1000;
            } else {
              final currentOrder = sameStatusItems[actualTargetIndex].sortOrder;
              final nextOrder = sameStatusItems[actualTargetIndex + 1].sortOrder;
              newSortOrder = ((currentOrder + nextOrder) / 2).round();
            }
          } else {
            // 上方向への移動：前のアイテムとターゲットの間
            if (actualTargetIndex == 0) {
              newSortOrder = sameStatusItems[0].sortOrder - 1000;
            } else {
              final prevOrder = sameStatusItems[actualTargetIndex - 1].sortOrder;
              final currentOrder = sameStatusItems[actualTargetIndex].sortOrder;
              newSortOrder = ((prevOrder + currentOrder) / 2).round();
            }
          }
        }
        
        // 移動対象のアイテムのsortOrderを更新
        final itemIndex = items.indexWhere((item) => item.id == movedItemId);
        if (itemIndex != -1) {
          items[itemIndex] = items[itemIndex].copyWith(sortOrder: newSortOrder);
        }
      }
    } catch (e) {
      // エラーが発生した場合は何もしない
    }
  }
}