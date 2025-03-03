import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homepage.dart';

class SuccessPage extends StatefulWidget {
  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  String userName = "User";

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userName = userDoc['name'] ?? "User";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(20),
            child: Icon(Icons.check, size: 80, color: Colors.purple),
          ),
          SizedBox(height: 20),
          Text(
            "Your account was successfully created!",
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            "Only one click to explore Turf World.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'Roboto',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            "Welcome, $userName",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                "Next",
                style: TextStyle(fontFamily: "SF-Pro",fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          Spacer(),
          Text(
            "By using TurfGo, you agree to the",
            style: TextStyle(fontFamily: "SF-Pro",color: Colors.grey,),
          ),
          GestureDetector(
            onTap: () {
              // Handle Terms and Privacy Policy Click
            },
            child: Text(
              "Terms and Privacy Policy.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "SF-Pro",
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
