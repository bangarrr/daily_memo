import 'package:daily_memo/collections/category.dart';
import 'package:daily_memo/providers/repository_provider.dart';
import 'package:daily_memo/views/components/elements/toaster.dart';
import 'package:daily_memo/views/components/topic_list/category_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CreateTopicForm extends ConsumerStatefulWidget {
  final Future<void> Function() createdCallback;
  const CreateTopicForm({Key? key, required this.createdCallback}) : super(key: key);

  @override
  ConsumerState<CreateTopicForm> createState() => _CreateTopicFormState();
}

class _CreateTopicFormState extends ConsumerState<CreateTopicForm> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  Category? _category;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void setCategory(Category? category) {
    setState(() {
      _category = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topicRepository = ref.read(topicRepositoryProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              autofocus: true,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: '話題を入力してください',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryDropdown(
                  focusNode: _focusNode,
                  selectedCategory: _category,
                  selectHandler: setCategory,
                  bottom: 60,
                  horizontalPosition: {
                    'left': 16,
                  },
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_textController.text.isEmpty) return;
                    await topicRepository.addTopic(text: _textController.text, category: _category);

                    _textController.clear();
                    Toaster.show(context: context, message: '追加しました');
                    await widget.createdCallback();
                  },
                  icon: Icon(Icons.add),
                  label: Text('追加'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
