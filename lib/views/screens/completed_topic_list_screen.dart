import 'package:daily_memo/collections/topic.dart';
import 'package:daily_memo/providers/repository_provider.dart';
import 'package:daily_memo/views/screens/topic_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class CompletedTopicListScreen extends ConsumerStatefulWidget {
  const CompletedTopicListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CompletedTopicListScreen> createState() => _CompletedTopicListScreenState();
}

class _CompletedTopicListScreenState extends ConsumerState<CompletedTopicListScreen> {
  final List<Topic> topics = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    searchTopics();
  }

  Future<void> searchTopics({String? categoryName}) async {
    final topicRepository = ref.read(topicRepositoryProvider);
    final topics = await topicRepository.searchTopics(completed: true);
    setState(() {
      this.topics
        ..clear()
        ..addAll(topics);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('利用済みの話題'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                topics.isNotEmpty
                    ? Expanded(child: _buildList(topics, _currentIndex))
                    : Expanded(
                  child: Center(
                    child: Text('利用した話題はまだありません'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Topic> topics, int index) {
    final topicRepository = ref.read(topicRepositoryProvider);

    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) {
        return Divider(height: 3);
      },
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return Slidable(
          key: ValueKey(topic.id),
          endActionPane: ActionPane(
            extentRatio: 0.2,
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                icon: Icons.redo,
                label: '戻す',
                backgroundColor: Colors.grey.shade400,
                onPressed: (BuildContext context) async {
                  await topicRepository.updateTopicStatus(topic, false);
                  await searchTopics();
                },
              ),
            ],
          ),
          child: Card(
            child: ListTile(
              title: Text(
                topic.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(topic.category?.value?.name ?? 'すべて', style: TextStyle(color: Colors.blue),),
                  Text(DateFormat('yyyy年MM月dd日').format(topic.createdAt)),
                ],
              ),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: topic)),
                );
                searchTopics();
              },
            ),
          ),
        );
      },
    );
  }
}
