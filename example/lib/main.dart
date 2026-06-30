import 'package:example/database.dart';
import 'package:example/task.dart';
import 'package:example/task_dao.dart';
import 'package:flutter/material.dart';

import 'input_field.dart';
import 'task_list_tile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database =
      await $FloorFlutterDatabase
          .databaseBuilder('flutter_database.db')
          .build();
  final dao = database.taskDao;

  runApp(FloorApp(dao));
}

class FloorApp extends StatelessWidget {
  final TaskDao dao;

  const FloorApp(this.dao, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floor Community Demo',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: HomePage(title: 'Floor Community Demo', dao: dao),
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;
  final TaskDao dao;

  const HomePage({super.key, required this.title, required this.dao});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  TaskStatus? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,

        actions: <Widget>[
          PopupMenuButton<int>(
            itemBuilder: (context) {
              return List.generate(
                TaskStatus.values.length +
                    1, //Uses increment to handle All types
                (index) {
                  return PopupMenuItem<int>(
                    value: index,
                    child: Text(index == 0 ? 'All' : _getMenuType(index).title),
                  );
                },
              );
            },
            onSelected: (index) {
              setState(() {
                _selectedType = index == 0 ? null : _getMenuType(index);
              });
            },
          ),
        ],

        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 12),
          child: ColoredBox(
            color: const Color.fromARGB(255, 188, 152, 249),
            child: Align(
              alignment: Alignment.center,
              child: StreamBuilder(
                stream: widget.dao.findUniqueMessagesCountAsStream(),
                builder: (_, snapshot) => Text('You have added total : ${snapshot.data ?? 0} Tasks'),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TasksListView(dao: widget.dao, selectedType: _selectedType),
            TasksTextField(dao: widget.dao),
          ],
        ),
      ),
    );
  }

  TaskStatus _getMenuType(int index) => TaskStatus.values[index - 1];
}

class TasksListView extends StatelessWidget {
  final TaskDao dao;
  final TaskStatus? selectedType;

  const TasksListView({
    super.key,
    required this.dao,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<List<Task>>(
        stream:
            selectedType == null
                ? dao.findAllTasksAsStream()
                : dao.findAllTasksByStatusAsStream(selectedType!),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return Container();

          final tasks = snapshot.requireData;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (_, index) {
              return TaskListCell(task: tasks[index], dao: dao);
            },
          );
        },
      ),
    );
  }
}
