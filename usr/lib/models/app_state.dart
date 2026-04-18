import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

enum TaskType { meeting, homework, exam, reminder }
enum HabitType { water, eat, rest, outside, custom }

class AppTask {
  final String id;
  String title;
  bool isCompleted;
  TaskType type;
  DateTime date;

  AppTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'type': type.index,
        'date': date.toIso8601String(),
      };

  factory AppTask.fromJson(Map<String, dynamic> json) => AppTask(
        id: json['id'],
        title: json['title'],
        isCompleted: json['isCompleted'],
        type: TaskType.values[json['type']],
        date: DateTime.parse(json['date']),
      );
}

class AppHabit {
  final String id;
  String title;
  bool isCompletedToday;
  HabitType type;
  DateTime lastCompletedDate;

  AppHabit({
    required this.id,
    required this.title,
    this.isCompletedToday = false,
    required this.type,
    required this.lastCompletedDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompletedToday': isCompletedToday,
        'type': type.index,
        'lastCompletedDate': lastCompletedDate.toIso8601String(),
      };

  factory AppHabit.fromJson(Map<String, dynamic> json) => AppHabit(
        id: json['id'],
        title: json['title'],
        isCompletedToday: json['isCompletedToday'],
        type: HabitType.values[json['type']],
        lastCompletedDate: DateTime.parse(json['lastCompletedDate']),
      );
}

class AppState extends ChangeNotifier {
  List<AppTask> _tasks = [];
  List<AppHabit> _habits = [];

  List<AppTask> get tasks => _tasks;
  List<AppHabit> get habits => _habits;

  final _uuid = const Uuid();

  AppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      _tasks = decoded.map((e) => AppTask.fromJson(e)).toList();
    }

    final habitsJson = prefs.getString('habits');
    if (habitsJson != null) {
      final List<dynamic> decoded = jsonDecode(habitsJson);
      _habits = decoded.map((e) => AppHabit.fromJson(e)).toList();
    }
    
    _checkHabitResets();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(_tasks.map((e) => e.toJson()).toList()));
    await prefs.setString('habits', jsonEncode(_habits.map((e) => e.toJson()).toList()));
  }

  void _checkHabitResets() {
    final now = DateTime.now();
    bool changed = false;
    for (var habit in _habits) {
      if (habit.isCompletedToday && 
         (now.day != habit.lastCompletedDate.day || now.month != habit.lastCompletedDate.month || now.year != habit.lastCompletedDate.year)) {
        habit.isCompletedToday = false;
        changed = true;
      }
    }
    if (changed) _saveData();
  }

  void addTask(String title, TaskType type, DateTime date) {
    _tasks.add(AppTask(id: _uuid.v4(), title: title, type: type, date: date));
    _tasks.sort((a, b) => a.date.compareTo(b.date));
    _saveData();
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      _saveData();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveData();
    notifyListeners();
  }

  void addHabit(String title, HabitType type) {
    _habits.add(AppHabit(id: _uuid.v4(), title: title, type: type, lastCompletedDate: DateTime.now().subtract(const Duration(days: 1))));
    _saveData();
    notifyListeners();
  }

  void toggleHabit(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index].isCompletedToday = !_habits[index].isCompletedToday;
      if (_habits[index].isCompletedToday) {
        _habits[index].lastCompletedDate = DateTime.now();
      }
      _saveData();
      notifyListeners();
    }
  }

  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    _saveData();
    notifyListeners();
  }

  List<AppTask> getTasksForDay(DateTime day) {
    return _tasks.where((t) => t.date.year == day.year && t.date.month == day.month && t.date.day == day.day).toList();
  }
}
