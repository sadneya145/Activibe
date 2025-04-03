import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  String name = "Your Name";
  String phone = "Your Phone";
  String bio = "A short bio about yourself.";
  String instagramUrl = "";
  String linkedInUrl = "";
  String whatsappUrl = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
Future<void> _fetchUserData() async {
  User? user = _auth.currentUser;
  if (user != null) {
    try {
      final Uri url = Uri.parse("http://localhost:5000/api/users/${user.uid}");
      print("Fetching user data from: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          name = userData["name"] ?? name;
          phone = userData["phone"] ?? phone;
          bio = userData["bio"] ?? bio;
          instagramUrl = userData["instagram"] ?? "";
          linkedInUrl = userData["linkedin"] ?? "";
          whatsappUrl = userData["whatsapp"] ?? "";
        });
      } else {
        print("Error fetching user data: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching user data: ${response.body}"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Exception occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exception occurred: $e"), backgroundColor: Colors.red),
      );
    }
  }
}
  Future<void> _updateUserData(
      String newName,
      String newPhone,
      String newBio,
      String newInstagram,
      String newLinkedIn,
      String newWhatsapp,
      String email) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        final Uri url =
            Uri.parse("http://localhost:5000/api/users/email/${user.email}");
        final response = await http.put(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": newName,
            "phone": newPhone,
            "bio": newBio,
            "instagram": newInstagram,
            "linkedin": newLinkedIn,
            "whatsapp": newWhatsapp,
            "email": email
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Profile updated successfully!"),
                backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Error updating profile: ${response.body}"),
                backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Exception occurred: $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _editProfile() {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController phoneController = TextEditingController(text: phone);
    TextEditingController bioController = TextEditingController(text: bio);
    TextEditingController instagramController =
        TextEditingController(text: instagramUrl);
    TextEditingController linkedInController =
        TextEditingController(text: linkedInUrl);
    TextEditingController whatsappController =
        TextEditingController(text: whatsappUrl);
    TextEditingController emailController =
        TextEditingController(text: _auth.currentUser?.email ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Name")),
              TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: "Phone")),
              TextField(
                  controller: bioController,
                  decoration: InputDecoration(labelText: "Bio")),
              TextField(
                  controller: instagramController,
                  decoration: InputDecoration(labelText: "Instagram URL")),
              TextField(
                  controller: linkedInController,
                  decoration: InputDecoration(labelText: "LinkedIn URL")),
              TextField(
                  controller: whatsappController,
                  decoration: InputDecoration(labelText: "WhatsApp URL")),
              TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  readOnly: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                name = nameController.text;
                phone = phoneController.text;
                bio = bioController.text;
                instagramUrl = instagramController.text;
                linkedInUrl = linkedInController.text;
                whatsappUrl = whatsappController.text;
              });

              _updateUserData(name, phone, bio, instagramUrl, linkedInUrl,
                  whatsappUrl, emailController.text);
              Navigator.pop(context);
            },
            child: Text("Save",
                style: TextStyle(fontSize: 16, color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (url.isNotEmpty) {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    }
  }

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            Text("User Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.white),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  backgroundColor: Colors.grey.shade300,
                  child: _profileImage == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              Text(name,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 5),
              Text(user?.email ?? "No Email Found",
                  style: TextStyle(color: Colors.grey)),
              SizedBox(height: 5),
              Text(phone,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black)),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(bio,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editProfile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child:
                    Text("Edit Profile", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 40),
              Text("Connect with me:",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon(instagramUrl, Icons.camera),
                  SizedBox(width: 30),
                  _socialIcon(linkedInUrl, Icons.work),
                  SizedBox(width: 30),
                  _socialIcon(whatsappUrl, Icons.message),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialIcon(String url, IconData icon) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Icon(icon, size: 50, color: Colors.blue),
    );
  }
}
