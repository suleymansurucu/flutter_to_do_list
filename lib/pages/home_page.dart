import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:to_do_list_project/data/local_storage.dart';
import 'package:to_do_list_project/main.dart';
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
    // TODO: implement initState
    super.initState();
    _localStorage = locator<LocalStorage>();
    _allTask = <Task>[];
    getAllTaskFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GestureDetector(
            onTap: () {
              _showAddTaskBottomSheet(context);
            },
            child: Text(
              'Bugun Neler Yapacaksin ?',
              style: TextStyle(color: Colors.black),
            )),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(
              onPressed: () {
                _showAddTaskBottomSheet(context);
              },
              icon: Icon(Icons.add)),
        ],
      ),
      body: _allTask.isNotEmpty
          ? ListView.builder(
              itemBuilder: (context, index) {
                var _selectedListElement = _allTask[index];
                return Dismissible(
                    key: Key(_selectedListElement.id),
                    background: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Text('The Task deleted'),
                      ],
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        _allTask.removeAt(index);
                         _localStorage.deleteTask(task: _selectedListElement);
                      });
                    },
                    child: TaskListItem(task: _selectedListElement));
              },
              itemCount: _allTask.length,
            )
          : Center(
              child: Text('Lets add the task'),
            ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            // padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            padding: EdgeInsets.only(bottom: 150),

            width: MediaQuery.of(context).size.width,
            child: ListTile(
              title: TextField(
                style: TextStyle(fontSize: 24),
                decoration: InputDecoration(
                  hintText: 'Enter Your Task',
                ),
                onSubmitted: (value) {
                  Navigator.of(context).pop();
                  if (value.length > 3) {
                    DatePicker.showTimePicker(context, showSecondsColumn: false,
                        onConfirm: (time) async {
                      var newAddTask =
                          Task.create(name: value, createdAt: time);
                      _allTask.add(newAddTask);
                      await _localStorage.addTask(task: newAddTask);
                      setState(() {});
                    });
                  }
                },
              ),
            ),
          );
        });
  }

  void getAllTaskFromDb() async {
    _allTask = await _localStorage.getAllTask();
    setState(() {});
  }
}
