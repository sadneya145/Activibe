import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecentActivity extends StatefulWidget {
  final String userId;

  RecentActivity({required this.userId});

  @override
  _RecentActivityState createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {
  List<dynamic> goals = [];
  List<dynamic> events = [];

  @override
  void initState() {
    super.initState();
    fetchRecentGoals();
    fetchRecentEvents();
  }

  Future<void> fetchRecentGoals() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/goals/${widget.userId}'));
    if (response.statusCode == 200) {
      setState(() {
        goals = jsonDecode(response.body);
      });
    }
  }

  Future<void> fetchRecentEvents() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/events/${widget.userId}'));
    if (response.statusCode == 200) {
      setState(() {
        events = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Goals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...goals.map((goal) => ListTile(
          title: Text(goal['title']),
          subtitle: Text(goal['description']),
        )).toList(),
        
        SizedBox(height: 10),
        Text("Recent Events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...events.map((event) => ListTile(
          title: Text(event['name']),
          subtitle: Text(event['date']),
        )).toList(),
      ],
    );
  }
}
