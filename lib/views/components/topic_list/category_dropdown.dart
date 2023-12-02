import 'package:daily_memo/collections/category.dart';
import 'package:daily_memo/providers/repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CategoryDropdown extends ConsumerStatefulWidget {
  final FocusNode focusNode;
  final Category? selectedCategory;
  final Function(Category? selected) selectHandler;

  const CategoryDropdown(
      {Key? key, required this.focusNode, required this.selectedCategory, required this.selectHandler})
      : super(key: key);

  @override
  ConsumerState<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends ConsumerState<CategoryDropdown> {
  final List<Category> _categories = [];
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final categoryRepository = ref.read(categoryRepositoryProvider);
    (() async {
      _categories.addAll(await categoryRepository.searchCategories());
    })();
  }

  @override
  Widget build(BuildContext context) {
    final categoryRepository = ref.read(categoryRepositoryProvider);

    return PopupMenuButton<dynamic>(
      onOpened: () {
        widget.focusNode.requestFocus();
      },
      itemBuilder: (BuildContext context) {
        final categoryList =
            _categories.map((category) => PopupMenuItem(child: Text(category.name), value: category)).toList();
        return [
          PopupMenuItem(child: Text('カテゴリなし'), value: Category()),
          ...categoryList,
          PopupMenuItem(
            child: Row(
              children: [
                Icon(Icons.add),
                Text('新規追加'),
              ],
            ),
            value: 'add',
            onTap: () async {
              widget.focusNode.unfocus();
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text('新しいカテゴリを追加する'),
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
                        if (_textController.text.isNotEmpty) {
                          await categoryRepository.addCategory(_textController.text);
                          setState(() async {
                            _categories.clear();
                            _categories.addAll(await categoryRepository.searchCategories());
                            widget.selectHandler(_categories.last);
                            Navigator.of(context).pop();
                          });
                        }
                      },
                      child: Text('保存'),
                    ),
                  ],
                ),
              );
            },
          )
        ];
      },
      position: PopupMenuPosition.under,
      offset: Offset(0, -200),
      onSelected: (dynamic value) {
        if (value is Category) {
          widget.focusNode.requestFocus();
          widget.selectHandler(value.name == null ? null : value);
        }
      },
      constraints: BoxConstraints.loose(Size(160, 200)),
      child: Chip(
        label: Text(widget.selectedCategory?.name ?? 'カテゴリなし'),
      ),
    );
  }
}
