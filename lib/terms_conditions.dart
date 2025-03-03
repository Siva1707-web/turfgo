import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms & Conditions", style: TextStyle(fontFamily: "Roboto",color: Colors.white)),
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
                "Terms & Conditions for TurfGo",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple[900]),
              ),
              SizedBox(height: 10),
              Text(
                "Effective Date: 02-03-2025\n",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _termsSection("1. Introduction",
                  "By using TurfGo, you agree to the following terms and conditions."),
              _termsSection("2. User Accounts",
                  "• Users must provide accurate and valid information during registration.\n• TurfGo reserves the right to terminate accounts that provide false information."),
              _termsSection("3. Booking Policies",
                  "• Users can book available turf slots through the app.\n• Cancellations and rescheduling are subject to availability and TurfGo's cancellation policy."),
              _termsSection("4. Payment & Refunds",
                  "• Payments must be completed before confirming a booking.\n• Refunds, if applicable, will be processed as per TurfGo’s refund policy."),
              _termsSection("5. User Conduct",
                  "• Users must not misuse the app or attempt unauthorized access.\n• Any fraudulent activity will result in account suspension."),
              _termsSection("6. Liability Disclaimer",
                  "TurfGo is not responsible for injuries, accidents, or damages occurring at the booked turf."),
              _termsSection("7. Changes to Terms",
                  "TurfGo reserves the right to modify these terms at any time."),
              _termsSection("8. Contact Information",
                  "For any concerns, contact us at abisiva1707@gmail.com."),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _termsSection(String title, String content) {
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
