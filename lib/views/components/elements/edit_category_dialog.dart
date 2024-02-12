import 'package:daily_memo/collections/category.dart';
import 'package:daily_memo/providers/repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EditCategoryDialog extends ConsumerStatefulWidget {
  final Category? category;

  const EditCategoryDialog({Key? key, Category? this.category}) : super(key: key);

  @override
  ConsumerState<EditCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<EditCategoryDialog> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.category?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final categoryRepository = ref.read(categoryRepositoryProvider);

    return AlertDialog(
      title: Text(widget.category == null ? '新しいカテゴリを追加する' : 'カテゴリを編集する'),
      content: TextField(
        controller: _textController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'カテゴリ名を入力',
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('キャンセル'),
        ),
        TextButton(
          onPressed: () async {
            if (_textController.text.isEmpty) return;

            widget.category != null ?
              await categoryRepository.updateCategory(widget.category!, _textController.text) :
              await categoryRepository.addCategory(_textController.text);
            Navigator.of(context).pop();
          },
          child: Text('保存'),
        ),
      ],
    );
  }
}
