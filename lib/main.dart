import 'package:daily_memo/collections/category.dart';
import 'package:daily_memo/collections/topic.dart';
import 'package:daily_memo/providers/repository_provider.dart';
import 'package:daily_memo/repositories/category_repository.dart';
import 'package:daily_memo/repositories/topic_repository.dart';
import 'package:daily_memo/views/components/topic_list/edit_topic_form.dart';
import 'package:daily_memo/views/screens/settings_screen.dart';
import 'package:daily_memo/views/screens/topic_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dirPath = (await getApplicationSupportDirectory()).path;
  final isar = await Isar.open(
    [
      TopicSchema,
      CategorySchema,
    ],
    directory: dirPath,
    inspector: true,
  );

  /* 初回のみデータ書き込み */
  await _writeSeed(isar);

  runApp(
    ProviderScope(
      overrides: [
        topicRepositoryProvider.overrideWithValue(TopicRepository(isar)),
        categoryRepositoryProvider.overrideWithValue(CategoryRepository(isar)),
      ],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '話題メモ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    TopicListScreen(),
    SettingsScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '設定'
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTap,
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
    );
  }
}

Future<void> _writeSeed(Isar isar) async {
  if (await isar.categorys.count() > 0) return;

  await isar.writeTxn(() async {
    await isar.categorys.putAll(['仕事', '友人'].map((category) => Category()..name = category).toList());
  });
}
