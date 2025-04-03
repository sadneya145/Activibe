import 'package:flutter/material.dart';

void main() {
  runApp(SocialsApp());
}

class SocialsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SocialsPage(),
    );
  }
}

class SocialsPage extends StatefulWidget {
  @override
  _SocialsPageState createState() => _SocialsPageState();
}

class _SocialsPageState extends State<SocialsPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  List<Map<String, String>> posts = [
    {
      'username': 'Elia',
      'profileImage':
          'https://th.bing.com/th/id/R.bc93d490d488d675e94c3c780ecb807f?rik=64kvN1L0MWA6yQ&riu=http%3A%2F%2Fsalticid.com%2Fmarathon%2Fwp-content%2Fuploads%2F2019%2F01%2F829777_1336_0016.jpg',
      'timeAgo': '2 hrs ago',
      'caption': "Successfully completed the City Marathon! 🏃‍♂️💪",
      'postImage':
          'https://media.gettyimages.com/id/1439602793/photo/2022-tcs-new-york-city-marathon.jpg?s=1024x1024&w=gi&k=20&c=dWv8AUUXup0l6hPnIvMo93tqBviis-fnPE8GjWbH3Nw=',
    },
    {
      'username': 'Neha',
      'profileImage':
          'https://randomuser.me/api/portraits/women/2.jpg',
      'timeAgo': '5 hrs ago',
      'caption': "Excited to announce the upcoming Tech Meetup this Saturday! 🚀",
      'postImage':
          'https://th.bing.com/th/id/OIP.d52_XyE2MG0Jd2lDQ55zlQHaE8?rs=1&pid=ImgDetMain',
    },
    {
      'username': 'Sophia',
      'profileImage':
          'https://randomuser.me/api/portraits/women/17.jpg',
      'timeAgo': '5 hrs ago',
      'caption': "Had an amazing time at the Food Festival! 🍕🍔",
      'postImage':'https://just-eat-prod-sg-res.cloudinary.com/image/upload/c_fill,f_auto,q_auto,w_1200,h_630,d_au:cuisines:italian-2.jpg/v1/au/restaurants/11044322.jpg',

    }
  ];

  void addPost() {
    if (_textController.text.isNotEmpty && _imageController.text.isNotEmpty) {
      setState(() {
        posts.insert(0, {
          'username': 'New User',
          'profileImage':
              'https://www.bing.com/th?id=OIP.7aP4mEJqwx32saqOQi7S1wHaHa&pid=Api&rs=1', // Default user image
          'timeAgo': 'Just now',
          'caption': _textController.text,
          'postImage': _imageController.text,
        });
      });

      _textController.clear();
      _imageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socials', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: "What's on your mind?",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _imageController,
                  decoration: InputDecoration(
                    labelText: "Enter Image URL",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addPost,
                  child: Text("Post"),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: posts.map((post) => buildPost(post)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPost(Map<String, String> post) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post['profileImage']!),
                  radius: 25,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['username']!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(post['timeAgo']!, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(post['caption']!, style: TextStyle(fontSize: 15)),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(post['postImage']!,
                  width: double.infinity, height: 200, fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }
}
