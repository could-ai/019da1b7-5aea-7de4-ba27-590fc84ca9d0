import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks & Reminders'),
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final tasks = state.tasks;
          
          if (tasks.isEmpty) {
            return const Center(
              child: Text('No tasks available.'),
            );
          }

          // Group tasks by upcoming and past/completed
          final now = DateTime.now();
          final upcomingTasks = tasks.where((t) => !t.isCompleted && t.date.isAfter(now.subtract(const Duration(days: 1)))).toList();
          final pastOrCompletedTasks = tasks.where((t) => t.isCompleted || t.date.isBefore(now.subtract(const Duration(days: 1)))).toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (upcomingTasks.isNotEmpty) ...[
                Text(
                  'Upcoming',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...upcomingTasks.map((t) => _TaskTile(task: t, state: state)),
                const SizedBox(height: 24),
              ],
              
              if (pastOrCompletedTasks.isNotEmpty) ...[
                Text(
                  'Completed & Past',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...pastOrCompletedTasks.map((t) => _TaskTile(task: t, state: state)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final AppTask task;
  final AppState state;

  const _TaskTile({required this.task, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (val) => state.toggleTask(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          '${DateFormat.yMMMd().format(task.date)} at ${DateFormat.jm().format(task.date)}',
          style: TextStyle(color: task.isCompleted ? Colors.grey : null),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getTaskTypeChip(task.type),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => state.deleteTask(task.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTaskTypeChip(TaskType type) {
    String label;
    Color color;

    switch (type) {
      case TaskType.meeting:
        label = 'Meeting';
        color = Colors.blue;
        break;
      case TaskType.homework:
        label = 'Homework';
        color = Colors.orange;
        break;
      case TaskType.exam:
        label = 'Exam';
        color = Colors.red;
        break;
      case TaskType.reminder:
        label = 'Reminder';
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
