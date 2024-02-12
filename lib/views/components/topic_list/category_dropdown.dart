import 'package:daily_memo/collections/category.dart';
import 'package:daily_memo/providers/repository_provider.dart';
import 'package:daily_memo/views/components/elements/edit_category_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CategoryDropdown extends ConsumerStatefulWidget {
  final FocusNode focusNode;
  final Category? selectedCategory;
  final Function(Category? selected) selectHandler;
  final int bottom;
  final Map<String, double> horizontalPosition;

  const CategoryDropdown({Key? key, required this.focusNode, required this.selectedCategory, required this.selectHandler, required this.bottom, required this.horizontalPosition})
      : super(key: key);

  @override
  ConsumerState<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends ConsumerState<CategoryDropdown> {
  final List<Category> _categories = [];

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

    return GestureDetector(
      child: Chip(
        label: Text(widget.selectedCategory?.name ?? 'カテゴリなし'),
      ),
      onTap: () {
        _showDropdown(context);
      },
    );
  }

  void _showDropdown(BuildContext context) {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          overlayEntry?.remove();
        },
        child: Stack(
          children: [
            Container(
              color: Colors.transparent,
            ),
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom + widget.bottom,
              left: widget.horizontalPosition['left'] ?? null,
              right: widget.horizontalPosition['right'] ?? null,
              child: Material(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 160,
                  constraints: BoxConstraints(
                    minHeight: 50,
                    maxHeight: 200,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        dense: true,
                        title: Text('カテゴリなし'),
                        textColor: widget.selectedCategory == null ? Colors.blue : null,
                        onTap: () {
                          widget.selectHandler(null);
                          overlayEntry?.remove();
                        },
                      ),
                      ..._categories.map(
                        (category) => ListTile(
                          dense: true,
                          title: Text(category.name),
                          textColor: widget.selectedCategory?.id == category.id ? Colors.blue : null,
                          onTap: () {
                            widget.selectHandler(category);
                            overlayEntry?.remove();
                          },
                        ),
                      ),
                      ListTile(
                        dense: true,
                        minLeadingWidth: 0,
                        leading: Icon(Icons.add),
                        title: Text('新規追加'),
                        textColor: Colors.blue,
                        iconColor: Colors.blue,
                        onTap: () async {
                          overlayEntry?.remove();
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => EditCategoryDialog(),
                          );
                          setState(() async {
                            _categories.clear();
                            _categories.addAll(await ref.read(categoryRepositoryProvider).searchCategories());
                            widget.selectHandler(_categories.last);
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }
}
