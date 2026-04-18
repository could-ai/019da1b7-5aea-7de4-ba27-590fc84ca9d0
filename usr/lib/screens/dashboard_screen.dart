import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Hello, Student!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Text(
                      DateFormat('EEEE, MMMM d').format(now),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Daily Habits Tracker'),
                    const SizedBox(height: 16),
                    const _HabitsSummary(),
                    const SizedBox(height: 32),
                    _buildSectionTitle(context, 'Today\\'s Tasks'),
                    const SizedBox(height: 16),
                    const _TodayTasksList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _HabitsSummary extends StatelessWidget {
  const _HabitsSummary();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        if (state.habits.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.favorite_border, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text('No habits added yet.'),
                  TextButton(
                    onPressed: () {
                      state.addHabit('Drink Water', HabitType.water);
                      state.addHabit('Eat Healthy Meal', HabitType.eat);
                      state.addHabit('Take a Rest', HabitType.rest);
                      state.addHabit('Go Outside', HabitType.outside);
                    },
                    child: const Text('Add Default Habits'),
                  )
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: state.habits.length,
          itemBuilder: (context, index) {
            final habit = state.habits[index];
            return InkWell(
              onTap: () => state.toggleHabit(habit.id),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: habit.isCompletedToday
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      _getHabitIcon(habit.type),
                      color: habit.isCompletedToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        habit.title,
                        style: TextStyle(
                          fontWeight: habit.isCompletedToday ? FontWeight.bold : FontWeight.normal,
                          color: habit.isCompletedToday
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getHabitIcon(HabitType type) {
    switch (type) {
      case HabitType.water: return Icons.water_drop;
      case HabitType.eat: return Icons.restaurant;
      case HabitType.rest: return Icons.bedtime;
      case HabitType.outside: return Icons.park;
      case HabitType.custom: return Icons.star;
    }
  }
}

class _TodayTasksList extends StatelessWidget {
  const _TodayTasksList();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final todayTasks = state.getTasksForDay(DateTime.now());
        
        if (todayTasks.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text('No tasks scheduled for today. Take a break!'),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: todayTasks.length,
          itemBuilder: (context, index) {
            final task = todayTasks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) => state.toggleTask(task.id),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? Colors.grey : null,
                  ),
                ),
                subtitle: Text(
                  DateFormat.jm().format(task.date),
                  style: TextStyle(color: task.isCompleted ? Colors.grey : null),
                ),
                trailing: _getTaskIcon(task.type),
              ),
            );
          },
        );
      },
    );
  }

  Widget _getTaskIcon(TaskType type) {
    IconData iconData;
    Color color;
    
    switch (type) {
      case TaskType.meeting: 
        iconData = Icons.groups;
        color = Colors.blue;
        break;
      case TaskType.homework:
        iconData = Icons.menu_book;
        color = Colors.orange;
        break;
      case TaskType.exam:
        iconData = Icons.assignment_late;
        color = Colors.red;
        break;
      case TaskType.reminder:
        iconData = Icons.notifications;
        color = Colors.green;
        break;
    }
    
    return Icon(iconData, color: color);
  }
}
