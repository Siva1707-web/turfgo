import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MyDetails extends StatefulWidget {
  @override
  _MyDetailsState createState() => _MyDetailsState();
}

class _MyDetailsState extends State<MyDetails> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String name = "Loading...";
  String email = "Loading...";
  String mobile = "Loading...";
  String location = "Loading...";
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  /// ✅ Fetch user details **only once** from Firebase
  Future<void> fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw "User not logged in";

      DatabaseReference userRef = _database.child("users").child(user.uid);
      DataSnapshot snapshot = (await userRef.get());

      if (snapshot.exists) {
        Map<dynamic, dynamic>? userData = snapshot.value as Map?;
        setState(() {
          name = userData?["name"] ?? "Not available";
          email = userData?["email"] ?? "Not available";
          mobile = userData?["mobile"] ?? "Not available";
          location = userData?["location"] ?? "Not available";
          isLoading = false;
        });
      } else {
        throw "User data not found";
      }
    } catch (error) {
      setState(() {
        isError = true;
        isLoading = false;
      });
      print("Error fetching user data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("My Details", style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: Colors.purple[700],
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // ✅ Fast loading
          : isError
          ? Center(child: Text("Error loading data. Please try again.", style: TextStyle(color: Colors.red, fontSize: 16)))
          : Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// ✅ User Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purple[700],
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 20),

            /// ✅ User Information
            userInfoCard("Full Name", name, Icons.person),
            userInfoCard("Email Address", email, Icons.email),
            userInfoCard("Mobile Number", mobile, Icons.phone),
            userInfoCard("Location", location, Icons.location_on),

            SizedBox(height: 30),

            /// ✅ Back Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: Colors.white),
              label: Text("Back", style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Simple User Info Card
  Widget userInfoCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.purple[700]),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[800])),
        subtitle: Text(value, style: TextStyle(fontSize: 16, color: Colors.black87)),
      ),
    );
  }
}