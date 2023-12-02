import 'dart:async';
import 'package:daily_memo/collections/category.dart';
import 'package:daily_memo/collections/topic.dart';
import 'package:isar/isar.dart';

class TopicRepository {
  final Isar isar;
  final bool sync;
  final StreamController<List<Topic>> _streamController =
      StreamController<List<Topic>>.broadcast();


  TopicRepository(this.isar, {this.sync = false}) {
    isar.topics
        .filter()
        .completedEqualTo(false)
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true)
        .listen((topicList) async {
      if (!isar.isOpen) return;
      if (_streamController.isClosed) return;
      _streamController.sink.add(topicList);
    });
  }

  Stream<List<Topic>> get topicStream => _streamController.stream;

  void dispose() {
    _streamController.close();
  }

  FutureOr<List<Topic>> searchTopics() async {
    if (!isar.isOpen) return [];

    final builder = isar.topics.where().sortByUpdatedAtDesc();
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

  FutureOr<void> updateTopic({required Topic topic, required String text}) {
    if (!isar.isOpen) return Future<void>(() {});

    final now = DateTime.now();
    topic
      ..text = text
      ..order = 0
      ..updatedAt = now;

    return isar.writeTxn(() async {
      await isar.topics.put(topic);
    });
  }

  FutureOr<void> completeTopic(Topic topic) async {
    if (!isar.isOpen) return Future<void>(() {});

    topic..completed = true;
    return isar.writeTxn(() async => await isar.topics.put(topic));
  }

  FutureOr<bool> deleteTopic(Topic topic) async {
    if (!isar.isOpen) return false;

    return isar.writeTxn(() async {
      return isar.topics.delete(topic.id);
    });
  }
}
