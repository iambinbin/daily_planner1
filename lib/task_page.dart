import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './data/databaseHelper.dart';

class TaskPage extends StatefulWidget {
  final DateTime selectedDate;

  const TaskPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task for ${widget.selectedDate.toString().split(' ')[0]}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Task Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Task Description'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Start Time: ${_startTime?.format(context) ?? 'Not set'}'),
                      trailing: Icon(Icons.access_time),
                      onTap: () async {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _startTime = time;
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('End Time: ${_endTime?.format(context) ?? 'Not set'}'),
                      trailing: Icon(Icons.access_time),
                      onTap: () async {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _endTime = time;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text('Save Task'),
              ),
              SizedBox(height: 20),
              Text('Tasks for this date:'),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _databaseHelper.getTasksForDate(widget.selectedDate),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No tasks for this date'));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final task = snapshot.data![index];
                          return ListTile(
                            title: Text(task['title']),
                            subtitle: Text(
                              '${task['description']}\nStart: ${task['start_time']} End: ${task['end_time']}',
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate() && _startTime != null && _endTime != null) {
      try {
        int result = await _databaseHelper.insertTask(
          _titleController.text,
          _descriptionController.text,
          widget.selectedDate,
          //_startTime!,
          //_endTime!,
        );
        if (result != -1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task saved successfully')),
          );
          _titleController.clear();
          _descriptionController.clear();
          setState(() {
            _startTime = null;
            _endTime = null;
          });
        } else {
          throw Exception('Failed to insert task');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving task: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please set start and end times')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}