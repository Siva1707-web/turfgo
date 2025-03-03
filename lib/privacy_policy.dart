import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy", style: TextStyle(fontFamily: "Roboto",color: Colors.white)),
        backgroundColor: Colors.purple[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Privacy Policy for TurfGo",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple[900]),
              ),
              SizedBox(height: 10),
              Text(
                "Effective Date: 02-03-2025\n",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _policySection("1. Introduction",
                  "TurfGo values your privacy and is committed to protecting your personal data. This privacy policy outlines how we collect, use, and safeguard your information."),
              _policySection("2. Information We Collect",
                  "• Name, Email, Mobile Number, and Location during registration.\n• Booking history and payment transactions.\n• Profile pictures (if uploaded by the user)."),
              _policySection("3. How We Use Your Information",
                  "• To manage bookings and provide customer support.\n• To improve user experience and send updates.\n• To process secure payments and maintain user profiles."),
              _policySection("4. Data Security",
                  "We use encryption and secure servers to protect your data. Sensitive information, including payment details, is handled externally via third-party payment providers."),
              _policySection("5. Third-Party Services",
                  "We may integrate with Google Pay, Paytm, and PhonePe for payment transactions. TurfGo does not store any payment details."),
              _policySection("6. Your Rights",
                  "• Users can update their personal information in the profile settings.\n• Users can request account deletion by contacting support."),
              _policySection("7. Contact Information",
                  "For any privacy-related concerns, email us at abisiva@1707@gmail.com."),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _policySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple[700])),
          SizedBox(height: 5),
          Text(content, style: TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }
}
