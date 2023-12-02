import 'package:daily_memo/collections/topic.dart';
import 'package:daily_memo/providers/repository_provider.dart';
import 'package:daily_memo/repositories/topic_repository.dart';
import 'package:daily_memo/views/components/topic_list/edit_topic_form.dart';
import 'package:daily_memo/views/screens/topic_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class TopicListScreen extends ConsumerStatefulWidget {
  const TopicListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends ConsumerState<TopicListScreen> {
  final List<Topic> topics = [];
  final List<Topic> archivedTopics = [];

  @override
  void initState() {
    super.initState();

    final topicRepository = ref.read(topicRepositoryProvider);
    topicRepository.topicStream.listen(_refresh);
  }

  void _refresh(List<Topic> topics) {
    if (!mounted) return;

    setState(() {
      this.topics
        ..clear()
        ..addAll(topics);
    });
  }

  void _refreshArchive(List<Topic> topics) {
    if (!mounted) return;

    setState(() {
      this.archivedTopics
        ..clear()
        ..addAll(topics);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('話題一覧'),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text('有効'),
                ),
                Tab(
                  child: Text('アーカイブ'),
                ),
              ],
              isScrollable: false,
            ),
          ),
          body: TabBarView(
            children: [
              _buildList(topics),
              _buildList(archivedTopics),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) => EditTopicForm(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Topic> topics) {
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
                icon: Icons.check_circle,
                label: '完了',
                backgroundColor: Colors.green,
                onPressed: (BuildContext context) async {
                  await topicRepository.completeTopic(topic);
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
              subtitle: Text(DateFormat('yyyy-MM-dd').format(topic.updatedAt)),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: topic)));
              },
            ),
          ),
        );
      },
    );
  }
}
