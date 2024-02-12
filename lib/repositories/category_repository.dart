import 'dart:async';

import 'package:daily_memo/collections/category.dart';
import 'package:isar/isar.dart';

class CategoryRepository {
  final Isar isar;
  final StreamController<List<Category>> _streamController = StreamController<List<Category>>.broadcast();

  CategoryRepository(this.isar) {
    isar.categorys.where().sortByOrder().watch(fireImmediately: true).listen((categoryList) async {
      _streamController.sink.add(categoryList);
    });
  }

  Stream<List<Category>> get categoryStream => _streamController.stream;

  void dispose() {
    _streamController.close();
  }

  FutureOr<List<Category>> searchCategories() async {
    if (!isar.isOpen) return [];
    return await isar.categorys.where().sortByOrder().findAll();
  }

  FutureOr<void> addCategory(String name) async {
    if (!isar.isOpen) return Future<void>(() {});

    final lastCategory = await isar.categorys.where().sortByOrderDesc().findFirst();
    final order = lastCategory?.order ?? 0;

    final category = Category()
      ..name = name
      ..order = order + 1;
    return isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
  }

  FutureOr<void> updateCategory(Category category, String name) async {
    if (!isar.isOpen) return Future<void>(() {});

    category.name = name;
    return isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
  }

  FutureOr<void> deleteCategory(Category category) async {
    if (!isar.isOpen) return Future<void>(() {});

    return isar.writeTxn(() async {
      await isar.categorys.delete(category.id);
      final targetCategories = await isar.categorys.filter().orderGreaterThan(category.order).findAll();
      for (final targetCategory in targetCategories) {
        targetCategory.order -= 1;
      }
      await isar.categorys.putAll(targetCategories);
    });
  }

  FutureOr<void> swapCategory(Category category1, Category category2) async {
    if (!isar.isOpen) return Future<void>(() {});

    final tempOrder = category1.order;
    category1.order = category2.order;
    category2.order = tempOrder;
    return isar.writeTxn(() async {
      await isar.categorys.put(category1);
      await isar.categorys.put(category2);
    });
  }
}