import 'dart:async';

import 'package:daily_memo/collections/category.dart';
import 'package:isar/isar.dart';

class CategoryRepository {
  final Isar isar;

  CategoryRepository(this.isar);

  FutureOr<List<Category>> searchCategories() async {
    if (!isar.isOpen) return [];
    return await isar.categorys.where().findAll();
  }

  FutureOr<void> addCategory(String name) async {
    if (!isar.isOpen) return Future<void>(() {});

    final category = Category()..name = name;
    return isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
  }
}