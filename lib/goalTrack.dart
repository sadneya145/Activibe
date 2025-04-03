import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class GoalPage extends StatefulWidget {
  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  final TextEditingController _goalTitleController = TextEditingController();
  final TextEditingController _goalDescController = TextEditingController();
  String? _savedGoalTitle;
  String? _savedGoalDesc;

  final String apiUrl = "http://localhost:5000/api/goal";

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  Future<void> _saveGoal() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": _goalTitleController.text,
        "description": _goalDescController.text,
      }),
    );

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('goal_title', _goalTitleController.text);
      await prefs.setString('goal_desc', _goalDescController.text);

      setState(() {
        _savedGoalTitle = _goalTitleController.text;
        _savedGoalDesc = _goalDescController.text;
      });

      NotificationService().showReminderNotification(); // Set Reminder
    }
  }

  Future<void> _loadGoal() async {
    final response = await http.get(Uri.parse("http://localhost:5000/api/goals"));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('goal_title', data.last['title']);
        await prefs.setString('goal_desc', data.last['description']);

        setState(() {
          _savedGoalTitle = data.last['title'];
          _savedGoalDesc = data.last['description'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activibe')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _goalTitleController,
              decoration: InputDecoration(labelText: 'Enter Goal Title'),
            ),
            TextField(
              controller: _goalDescController,
              decoration: InputDecoration(labelText: 'Enter Goal Description'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveGoal,
              child: Text('Save Goal & Set Reminder'),
            ),
            SizedBox(height: 20),
            Text(
              "Goal: $_savedGoalTitle",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Details: $_savedGoalDesc",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
