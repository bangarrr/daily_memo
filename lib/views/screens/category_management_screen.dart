import 'package:daily_memo/collections/category.dart';
import 'package:daily_memo/providers/repository_provider.dart';
import 'package:daily_memo/views/components/elements/edit_category_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends ConsumerState<CategoryManagementScreen> {
  final List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() async {
    final categoryRepository = ref.read(categoryRepositoryProvider);
    final categories = await categoryRepository.searchCategories();
    setState(() {
      _categories..clear()..addAll(categories);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryRepository = ref.read(categoryRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('カテゴリを管理する'),
      ),
      body: ReorderableListView.builder(
        itemCount: _categories.length,
        onReorder: (oldIndex, newIndex) async {
          final category1 = _categories[oldIndex];
          final category2 = _categories[newIndex];
          await categoryRepository.swapCategory(category1, category2);
          refresh();
        },
        itemBuilder: (context, index) {
          return ListTile(
            key: Key(_categories[index].id.toString()),
            title: Text(_categories[index].name),
            leading: Icon(Icons.drag_indicator),
            trailing: PopupMenuButton(
              offset: const Offset(-20, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Text('編集'),
                    value: 'edit',
                  ),
                  PopupMenuItem(
                    child: Text('削除'),
                    value: 'delete',
                  ),
                ];
              },
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return EditCategoryDialog(
                          category: _categories[index],
                        );
                      },
                    );
                    break;
                  case 'delete':
                    await categoryRepository.deleteCategory(_categories[index]);
                    break;
                }
                refresh();
              },
            )
          );
        },
      ),
    );
  }
}
