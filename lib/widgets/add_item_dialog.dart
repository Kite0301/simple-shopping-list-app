import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialMemo;
  final String title;
  final Function(String title, String memo) onAdd;

  const AddItemDialog({
    super.key,
    this.initialTitle,
    this.initialMemo,
    this.title = 'アイテムを追加',
    required this.onAdd,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  late TextEditingController _titleController;
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _memoController = TextEditingController(text: widget.initialMemo ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'タイトル *',
              hintText: '牛乳',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _memoController,
            decoration: const InputDecoration(
              labelText: 'メモ',
              hintText: '低脂肪のやつ、2本買う',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final memo = _memoController.text.trim();
            
            if (title.isNotEmpty) {
              widget.onAdd(title, memo);
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.initialTitle != null ? '保存' : '追加'),
        ),
      ],
    );
  }
}