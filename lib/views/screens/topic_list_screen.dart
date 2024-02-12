import 'package:daily_memo/collections/topic.dart';
import 'package:daily_memo/providers/repository_provider.dart';
import 'package:daily_memo/views/components/topic_list/create_topic_form.dart';
import 'package:daily_memo/views/screens/topic_detail_screen.dart';
import 'package:flutter/material.dart';
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
          : GestureDetector(
              /* 端末で要挙動チェック */
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (details) async {
                final targetIndex = details.velocity.pixelsPerSecond.dx > 0
                    ? (_currentIndex == 0 ? _categories.length - 1 : _currentIndex - 1)
                    : (_currentIndex == _categories.length - 1 ? 0 : _currentIndex + 1);
                final category = _categories.elementAt(targetIndex);
                await searchTopics(categoryName: category == 'すべて' ? null : category);

                setState(() {
                  _tabController?.animateTo(targetIndex);
                  _currentIndex = targetIndex;
                });
              },
              child: Stack(
                children: [
                  Column(
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
                                  constraints: BoxConstraints(minWidth: 80, maxWidth: 120),
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
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      child: const Icon(Icons.add),
                      onPressed: () async {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) => CreateTopicForm(
                            createdCallback: () async {
                              final category = _categories.elementAt(_currentIndex);
                              await searchTopics(categoryName: category == 'すべて' ? null : category);
                            },
                          ),
                        );
                        final category = _categories.elementAt(_currentIndex);
                        searchTopics(categoryName: category == 'すべて' ? null : category);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildList(List<Topic> topics, int index) {
    final topicRepository = ref.read(topicRepositoryProvider);

    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) {
      },
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return Card(
          key: Key(topic.id.toString()),
          child: ListTile(
            leading: IconButton(
              icon: Icon(topic.completed ? Icons.check_circle : Icons.radio_button_unchecked),
              onPressed: () async {
                final status = !topic.completed;
                await topicRepository.updateTopicStatus(topic, status);
                setState(() {
                  topics[index].completed = status;
                });
              }
            ),
            title: Text(
              topic.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    topic.category?.value?.name ?? 'カテゴリなし',
                    style: TextStyle(color: Colors.blue),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 16),
                Text(DateFormat('yyyy年MM月dd日').format(topic.createdAt)),
              ],
            ),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: topic)),
              );
              final category = _categories.elementAt(_currentIndex);
              searchTopics(categoryName: category == 'すべて' ? null : category);
            },
          ),
        );
      },
    );
  }
}
