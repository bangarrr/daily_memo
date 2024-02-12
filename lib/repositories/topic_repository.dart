import 'dart:async';
import 'package:daily_memo/collections/category.dart';
import 'package:daily_memo/collections/topic.dart';
import 'package:isar/isar.dart';

class TopicRepository {
  final Isar isar;
  final bool sync;

  TopicRepository(this.isar, {this.sync = false});

  FutureOr<List<Topic>> searchTopics({String? categoryName, bool completed = false}) async {
    if (!isar.isOpen) return [];

    final builder = isar.topics
        .filter()
        .completedEqualTo(completed)
        .optional(
          categoryName != null,
          (q) => q.category(
            (q) => q.nameEqualTo(categoryName!),
          ),
        );
    return await builder.findAll();
  }

  FutureOr<void> addTopic({required String text, required Category? category}) {
    if (!isar.isOpen) return Future<void>(() {});

    final now = DateTime.now();
    final topic = Topic()
      ..text = text
      ..category.value = category
      ..order = 0
      ..completed = false
      ..createdAt = now
      ..updatedAt = now;

    return isar.writeTxn(() async {
      await isar.topics.put(topic);
      await topic.category.save();
    });
  }

  FutureOr<void> updateTopic({required Topic topic, required String text, required Category? category}) {
    if (!isar.isOpen) return Future<void>(() {});

    final now = DateTime.now();
    topic
      ..text = text
      ..category.value = category
      ..order = 0
      ..updatedAt = now;

    return isar.writeTxn(() async {
      await isar.topics.put(topic);
      await topic.category.save();
    });
  }

  FutureOr<void> updateTopicStatus(Topic topic, bool status) async {
    if (!isar.isOpen) return Future<void>(() {});

    topic..completed = status;
    return isar.writeTxn(() async => await isar.topics.put(topic));
  }

  FutureOr<bool> deleteTopic(Topic topic) async {
    if (!isar.isOpen) return false;

    return isar.writeTxn(() async {
      return isar.topics.delete(topic.id);
    });
  }
}
