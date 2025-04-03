import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> recentActivities = [
    {
      "title": "Completed a 5K Run",
      "description": "You successfully completed your 5K run challenge!",
    },
    {
      "title": "Joined a New Fitness Group",
      "description": "You have joined the 'Morning Joggers' group!",
    },
    {
      "title": "Logged 10,000 Steps",
      "description": "Great job on achieving your daily step goal!",
    },
    {
      "title": "Shared a Fitness Tip",
      "description": "You shared a useful tip on healthy eating habits.",
    }
  ];
  final List<Map<String, dynamic>> features = [
    {
      "title": "Goal Creation & Tracking",
      "description": "Set SMART goals and log progress daily.",
      "image":
          "https://plus.unsplash.com/premium_vector-1727955579504-b6e00adbf23c?q=80&w=1800&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "route": "/goal"
    },
    {
      "title": "Accountability Partners",
      "description": "Add friends, family, or mentors to track progress.",
      "image":
          "https://plus.unsplash.com/premium_vector-1682269939460-1e7d742aaa7f?q=80&w=1800&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "route": "/partner"
    },
    {
      "title": "Virtual Nudges",
      "description": "Receive motivating messages from partners.",
      "image":
          "https://images.unsplash.com/vector-1738325063642-ca6a57d8743e?q=80&w=1800&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "route": "/forum"
    },
    {
      "title": "Collaborative Goals",
      "description": "Work on shared goals like fitness challenges.",
      "image":
          "https://plus.unsplash.com/premium_vector-1727274000289-99ec6fa1f744?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8Y29sbGFicmF0aXZlJTIwd29ya3xlbnwwfHwwfHx8MA%3D%3D",
      "route": "/socials"
    },
    {
      "title": "Community Events",
      "description": "Discover and join local fitness and wellness events.",
      "image":
          "https://plus.unsplash.com/premium_vector-1725520929129-f7c7863cbc7a?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NzV8fGV2ZW50fGVufDB8fDB8fHww",
      "route": "/event"
    },
  ];

  List<int> likes = [0, 0, 0, 0,0]; // Track likes for each feature

  void toggleLike(int index) {
    setState(() {
      likes[index]++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Activibe",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: () {
                Navigator.pushNamed(context, "/user");
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CarouselSlider.builder(
                itemCount: features.length,
                itemBuilder: (context, index, realIndex) {
                  return GestureDetector(
                    onTap: () {
                      if (features[index]["route"] != null) {
                        Navigator.pushNamed(context, features[index]["route"]);
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: NetworkImage(features[index]["image"]),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(0.4),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    features[index]["title"],
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    features[index]["description"],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Row(
                              children: [
                                Text(
                                  likes[index].toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon:
                                      Icon(Icons.favorite, color: Colors.black),
                                  onPressed: () => toggleLike(index),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 350,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                ),
              ),
              SizedBox(height: 25),
              Text(
                "Recent Activities",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: recentActivities.length,
                  itemBuilder: (context, index) {
                    var activity = recentActivities[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(activity['title']!),
                        subtitle: Text(activity['description']!),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          // Navigate to detail screen
                        },
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
