import 'package:flutter/material.dart';

class PartnerGoalsPage extends StatefulWidget {
  @override
  _PartnerGoalsPageState createState() => _PartnerGoalsPageState();
}

class _PartnerGoalsPageState extends State<PartnerGoalsPage> {
  final TextEditingController goalController = TextEditingController();
  final TextEditingController partnerController = TextEditingController();

  List<Map<String, dynamic>> sharedGoals = [];

  void addSharedGoal() {
    if (goalController.text.isNotEmpty && partnerController.text.isNotEmpty) {
      setState(() {
        sharedGoals.add({
          "goal": goalController.text,
          "partners": partnerController.text.split(',').map((e) => e.trim()).toList(),
          "progress": 0, // Percentage progress tracking
        });
        goalController.clear();
        partnerController.clear();
      });
    }
  }

  void updateProgress(int index) {
    setState(() {
      if (sharedGoals[index]["progress"] < 100) {
        sharedGoals[index]["progress"] += 10;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Accountability Partners")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: goalController,
              decoration: InputDecoration(labelText: "Goal"),
            ),
            TextField(
              controller: partnerController,
              decoration: InputDecoration(
                  labelText: "Enter Partner Emails (comma separated)"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: addSharedGoal,
              child: Text("Add Goal"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sharedGoals.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(sharedGoals[index]["goal"]),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Partners: ${sharedGoals[index]["partners"].join(', ')}"),
                          LinearProgressIndicator(
                            value: sharedGoals[index]["progress"] / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () => updateProgress(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
