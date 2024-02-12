import 'package:daily_memo/collections/category.dart';
import 'package:daily_memo/collections/topic.dart';
import 'package:daily_memo/providers/repository_provider.dart';
import 'package:daily_memo/repositories/category_repository.dart';
import 'package:daily_memo/repositories/topic_repository.dart';
import 'package:daily_memo/views/components/elements/edit_category_dialog.dart';
import 'package:daily_memo/views/screens/category_management_screen.dart';
import 'package:daily_memo/views/screens/completed_topic_list_screen.dart';
import 'package:daily_memo/views/screens/report_screen.dart';
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
        useMaterial3: false,
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  final List<String> _categories = ['すべて'];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Widget> _widgetOptions = [
    TopicListScreen(),
    ReportScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final categoryRepository = ref.read(categoryRepositoryProvider);
    categoryRepository.categoryStream.listen((categories) {
      setState(() {
        _categories
          ..clear()
          ..add('すべて')
          ..addAll(categories.map((category) => category.name));
      });
    });
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('メニュー'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTileTheme(
              minLeadingWidth: 10,
              child: ExpansionTile(
                title: const Text(
                  'カテゴリー',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                leading: const Icon(Icons.category),
                children: [
                  ..._categories.map((category) {
                    return ListTile(
                      title: Text(category),
                      dense: true,
                      onTap: () {
                        // todo
                      },
                    );
                  }).toList(),
                  ListTile(
                    title: Text('カテゴリーを追加'),
                    dense: true,
                    leading: Icon(Icons.add),
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => EditCategoryDialog(),
                      );
                    },
                  )
                ],
              ),
            ),
            ListTile(
              minLeadingWidth: 10,
              title: Text('利用済みの話題'),
              dense: true,
              leading: Icon(Icons.check_circle),
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CompletedTopicListScreen(),
                  ),
                );
                // todo: 未完了に戻した後、リストに反映されない
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              title: Text('カテゴリの管理'),
              dense: true,
              leading: Icon(Icons.category),
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CategoryManagementScreen(),
                  ),
                );
                // todo: 未完了に戻した後、リストに反映されない
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
            ),
            Expanded(
              child: BottomNavigationBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                items: [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
                  BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'レポート'),
                ],
                currentIndex: _selectedIndex,
                onTap: _onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _writeSeed(Isar isar) async {
  if (await isar.categorys.count() > 0) return;

  await isar.writeTxn(() async {
    var index = 0;
    await isar.categorys.putAll(
        ['仕事', '友人'].map((category_name) {
          final category = Category()
            ..name = category_name
            ..order = ++index;
          return category;
        }).toList()
    );
  });
}
