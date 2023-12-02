import 'package:daily_memo/repositories/category_repository.dart';
import 'package:daily_memo/repositories/topic_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final topicRepositoryProvider = Provider<TopicRepository>((_) {
  throw UnimplementedError("アプリケーション起動時にmainでawaitして生成したインスタンスを使用する");
});

final categoryRepositoryProvider = Provider<CategoryRepository>((_) {
  throw UnimplementedError("アプリケーション起動時にmainでawaitして生成したインスタンスを使用する");
});