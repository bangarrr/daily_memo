import 'package:daily_memo/collections/category.dart';
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

class _TopicListScreenState extends ConsumerState<TopicListScreen> with TickerProviderStateMixin {
  final List<Topic> topics = [];
  final List<String> _categories = ['すべて'];
  TabController? _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  void initialize() {
    searchTopics();
    final categoryRepository = ref.read(categoryRepositoryProvider);
    categoryRepository.categoryStream.listen((categories) {
      setState(() {
        _categories
          ..clear()
          ..add('すべて')
          ..addAll(categories.map((category) => category.name));
        _tabController = TabController(length: categories.length + 1, vsync: this);
      });
    });
  }

  Future<void> searchTopics({String? categoryName}) async {
    final topicRepository = ref.read(topicRepositoryProvider);
    final topics = await topicRepository.searchTopics(categoryName: categoryName);
    setState(() {
      this.topics
        ..clear()
        ..addAll(topics);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: _tabController == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.purple),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabs: _categories
                          .map(
                            (category) => ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 80),
                              child: Tab(text: category),
                            ),
                          )
                          .toList(),
                      onTap: (index) async {
                        final category = _categories.elementAt(index);
                        await searchTopics(categoryName: category == 'すべて' ? null : category);
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                  ),
                  topics.isNotEmpty
                      ? Expanded(child: _buildList(topics, _currentIndex))
                      : Expanded(
                          child: Center(
                            child: Text('話題がありません'),
                          ),
                        ),
                ],
              ));
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
              subtitle: Text(DateFormat('yyyy年MM月dd日').format(topic.createdAt)),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: topic)),
                );
                final category = _categories.elementAt(_currentIndex);
                searchTopics(categoryName: category == 'すべて' ? null : category);
              },
            ),
          ),
        );
      },
    );
  }
}
