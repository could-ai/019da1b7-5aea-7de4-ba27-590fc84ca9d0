import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final selectedDayTasks = state.getTasksForDay(_selectedDay!);

          return Column(
            children: [
              TableCalendar<AppTask>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) => state.getTasksForDay(day),
                calendarStyle: CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: selectedDayTasks.isEmpty
                    ? Center(
                        child: Text(
                          'No tasks on ${DateFormat.yMMMd().format(_selectedDay!)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: selectedDayTasks.length,
                        itemBuilder: (context, index) {
                          final task = selectedDayTasks[index];
                          return ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (val) => state.toggleTask(task.id),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: Text('${DateFormat.jm().format(task.date)} - ${_taskTypeToString(task.type)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => state.deleteTask(task.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _taskTypeToString(TaskType type) {
    switch (type) {
      case TaskType.meeting: return 'Meeting';
      case TaskType.homework: return 'Homework';
      case TaskType.exam: return 'Exam';
      case TaskType.reminder: return 'Reminder';
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    TaskType selectedType = TaskType.homework;
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: TaskType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_taskTypeToString(type)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Time'),
                  trailing: Text(selectedTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setDialogState(() => selectedTime = time);
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  final finalDate = DateTime(
                    _selectedDay!.year,
                    _selectedDay!.month,
                    _selectedDay!.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  Provider.of<AppState>(context, listen: false).addTask(
                    titleController.text.trim(),
                    selectedType,
                    finalDate,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
