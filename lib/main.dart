import 'package:activibe/PartnerGoals.dart';
import 'package:activibe/forums.dart';
import 'package:activibe/goalTrack.dart';
import 'package:activibe/notification_service.dart';
import 'package:activibe/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:activibe/home.dart';
import 'package:activibe/socials.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'package:activibe/event.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Activibe',
      theme: ThemeData(
        fontFamily: 'Lora',
      ),
      home: AuthScreen(),
      routes: {
        '/home': (context) => HomePage(),
        '/socials': (context) => SocialsPage(),
        '/user': (context) => ProfilePage(),
        '/forum': (context) => ForumListPage(),
        '/goal': (context) => GoalPage(),
        '/event': (context) => EventPage(),
        '/partner': (context)=>PartnerGoalsPage()
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Generate a random password or use a placeholder
        const password =
            "google_sign_in_password"; // Replace with a secure random password
        await storeUserInMongoDB(user, password);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
    }
  }

  Future<void> signUpWithEmailPassword() async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Send user data to backend server
        await storeUserInMongoDB(user, _passwordController.text.trim());
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print("Email/Password Sign-Up Error: $e");
    }
  }

  // Function to send user data to backend server
  Future<void> storeUserInMongoDB(User user, String password) async {
    final url = Uri.parse(
        'http://localhost:5000/api/users'); // Replace with your backend URL
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ??
              'No Name', // Default value if displayName is null
          'password': password, // Include the password
        }),
      );

      if (response.statusCode == 200) {
        print('User login successful');
      } else {
        print('Failed to store user data in MongoDB: ${response.body}');
      }
    } catch (e) {
      print('HTTP Request Error: $e');
    }
  }

  Future<void> loginWithEmailPassword() async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in MongoDB
        final userExists = await loginUser(_emailController.text.trim(), _passwordController.text.trim());


        if (userExists) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("User not found. Please sign up."),
                backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      print("Email/Password Login Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Login failed. Please check your credentials."),
            backgroundColor: Colors.red),
      );
    }
  }

// Function to check if a user exists in MongoDB
  Future<bool> loginUser(String email, String password) async {
  final url = Uri.parse('http://localhost:5000/api/login');

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Login successful, Token: ${data["token"]}');
      return true;
    } else {
      print('Login failed: ${response.body}');
      return false;
    }
  } catch (e) {
    print('HTTP Request Error: $e');
    return false;
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/login2.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/logo.png", width: 100, height: 100),
                SizedBox(height: 20),
                Text(
                  isLogin ? "Welcome Back!" : "Join Us Today!",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Email",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLogin
                      ? loginWithEmailPassword // Use the new login function
                      : signUpWithEmailPassword, // Use the existing sign-up function
                  child: Text(isLogin ? "Login" : "Signup"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    textStyle: TextStyle(color: Color.fromARGB(0, 0, 0, 0)),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? "Don't have an account? Sign up"
                        : "Already have an account? Login",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                SizedBox(height: 10),
                Text("Or", style: TextStyle(fontSize: 18, color: Colors.black)),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: signInWithGoogle,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          "https://img.icons8.com/?size=100&id=V5cGWnc9R4xj&format=png&color=000000",
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(width: 10),
                        Text("Continue with Google",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
