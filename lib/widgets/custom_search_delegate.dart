import 'package:flutter/material.dart';
import 'package:to_do_list_project/data/local_storage.dart';
import 'package:to_do_list_project/main.dart';
import 'package:to_do_list_project/models/task_model.dart';
import 'package:to_do_list_project/widgets/task_list_item.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<Task> allTasks;
  CustomSearchDelegate({required this.allTasks});
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query.isNotEmpty ? null : query = '';
          },
          icon: Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return GestureDetector(
      onTap: (){
        close(context, null);
      },
        child: Icon(
      Icons.arrow_back_ios,
      color: Colors.red,
      size: 24,
    ));
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Task> filteredList = allTasks.where((task)=> task.name.toLowerCase().contains(query.toLowerCase())).toList();
    return filteredList.length > 0 ? ListView.builder(
      itemBuilder: (context, index) {
        var _selectedListElement = filteredList[index];
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
            onDismissed: (direction) async {
              filteredList.removeAt(index);
              await locator<LocalStorage>().deleteTask(task: _selectedListElement);
           //   _localStorage.deleteTask(task: _selectedListElement);
            },
            child: TaskListItem(task: _selectedListElement));
      },
      itemCount: filteredList.length,
    ): Center(child: Text('We Can not Find Your Search'),) ;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
