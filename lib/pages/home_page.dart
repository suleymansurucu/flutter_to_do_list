import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:to_do_list_project/data/local_storage.dart';
import 'package:to_do_list_project/main.dart';
import 'package:to_do_list_project/widgets/custom_search_delegate.dart';
import 'package:to_do_list_project/widgets/task_list_item.dart';

import '../models/task_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Task> _allTask;
  late LocalStorage _localStorage;

  @override
  void initState() {
    super.initState();
    _localStorage = locator<LocalStorage>();
    _allTask = <Task>[];
    getAllTaskFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(
          'What is Your Tasks?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _showSearchPage,
            icon: Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () => _showAddTaskBottomSheet(context),
            icon: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: _allTask.isNotEmpty
          ? ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          var _selectedListElement = _allTask[index];
          return Dismissible(
            key: Key(_selectedListElement.id),
            background: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                _allTask.removeAt(index);
                _localStorage.deleteTask(task: _selectedListElement);
              });
            },
            child: Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: TaskListItem(task: _selectedListElement),
            ),
          );
        },
        itemCount: _allTask.length,
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_task, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'You do not have tasks today!!!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please Enter to Your Task',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 16),
                TextField(
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Please Enter to Your Task',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onSubmitted: (value) {
                    Navigator.of(context).pop();
                    if (value.trim().length > 3) {
                      DatePicker.showTimePicker(context, showSecondsColumn: false,
                          onConfirm: (time) async {
                            var newAddTask = Task.create(name: value.trim(), createdAt: time);
                            _allTask.add(newAddTask);
                            await _localStorage.addTask(task: newAddTask);
                            setState(() {});
                          });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void getAllTaskFromDb() async {
    _allTask = await _localStorage.getAllTask();
    setState(() {});
  }

  Future<void> _showSearchPage() async {
    await showSearch(
      context: context,
      delegate: CustomSearchDelegate(allTasks: _allTask),
    );
    getAllTaskFromDb();
  }
}
