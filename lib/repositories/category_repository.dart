import 'dart:async';

import 'package:daily_memo/collections/category.dart';
import 'package:isar/isar.dart';

class CategoryRepository {
  final Isar isar;
  final StreamController<List<Category>> _streamController = StreamController<List<Category>>.broadcast();

  CategoryRepository(this.isar) {
    isar.categorys.where().watch(fireImmediately: true).listen((categoryList) async {
      _streamController.sink.add(categoryList);
    });
  }

  Stream<List<Category>> get categoryStream => _streamController.stream;

  void dispose() {
    _streamController.close();
  }

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