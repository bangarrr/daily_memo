import 'package:daily_memo/collections/category.dart';
import 'package:daily_memo/collections/topic.dart';
import 'package:daily_memo/providers/repository_provider.dart';
import 'package:daily_memo/views/components/topic_list/category_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TopicDetailScreen extends ConsumerStatefulWidget {
  final Topic topic;

  const TopicDetailScreen({Key? key, required this.topic}) : super(key: key);

  @override
  ConsumerState<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends ConsumerState<TopicDetailScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  Category? _category;

  @override
  void initState() {
    super.initState();
    _category = widget.topic.category.value;

    // final topicRepository = ref.read(topicRepositoryProvider);
    _textController.text = widget.topic.text;
    // _focusNode.addListener(() async {
    //   if (!_focusNode.hasFocus) {
    //     await topicRepository.updateTopic(topic: widget.topic, text: _textController.text);
    //   }
    // });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topicRepository = ref.read(topicRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: '削除',
                child: Text('削除'),
                onTap: () async {
                  await topicRepository.deleteTopic(widget.topic);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          await topicRepository.updateTopic(
            topic: widget.topic,
            text: _textController.text,
            category: _category,
          );
          return true;
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      filled: false,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  _buildActionRow(
                    icon: Icons.category,
                    text: 'カテゴリー',
                    actionWidget: CategoryDropdown(
                      bottom: 100,
                      horizontalPosition: {
                        'right': 16,
                      },
                      focusNode: _focusNode,
                      selectedCategory: _category,
                      selectHandler: (selected) {
                        setState(() {
                          _category = selected;
                        });
                      },
                    ),
                  ),
                  _buildActionRow(
                    icon: Icons.notifications,
                    text: '通知',
                    actionWidget: Text('通知ウィジェット')
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow({required IconData icon, required String text, required Widget actionWidget}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
          ),
        ),
      ),
      child: Container(
        constraints: BoxConstraints(
          minHeight: 50,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey[600],),
                SizedBox(width: 8),
                Text(text, style: TextStyle(color: Colors.grey[600]),),
              ],
            ),
            actionWidget,
          ],
        ),
      ),
    );
  }
}
