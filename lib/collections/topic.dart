import 'package:daily_memo/collections/category.dart';
import 'package:isar/isar.dart';

part 'topic.g.dart';

@collection
class Topic {
  Id id = Isar.autoIncrement;
  late String text;
  final category = IsarLink<Category>();
  late int order;
  late bool completed;
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;
}
