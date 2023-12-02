import 'dart:ffi';

import 'package:daily_memo/collections/topic.dart';
import 'package:daily_memo/providers/repository_provider.dart';
import 'package:daily_memo/repositories/topic_repository.dart';
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

  @override
  void initState() {
    super.initState();

    final topicRepository = ref.read(topicRepositoryProvider);
    _textController.text = widget.topic.text;
    _focusNode.addListener(() async {
      if (!_focusNode.hasFocus) {
        await topicRepository.updateTopic(topic: widget.topic, text: _textController.text);
      }
    });
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [],
              )
            ],
          ),
        ),
      ),
    );
  }
}
