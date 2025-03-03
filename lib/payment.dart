import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'ticketscreen.dart';

class PaymentScreen extends StatefulWidget {
  final String turfName;
  final String selectedDate;
  final String selectedTime;
  final List<String> slotNumbers;
  final int totalAmount;

  PaymentScreen({
    required this.turfName,
    required this.selectedDate,
    required this.selectedTime,
    required this.slotNumbers,
    required this.totalAmount,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int get totalAmount => widget.slotNumbers.length * 800;
  String upiId = "sivaprasath17105@okaxis";
  late String transactionRefId;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    transactionRefId = DateTime.now().millisecondsSinceEpoch.toString();
    _startPaymentPolling();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatSelectedTime(List<String> slotNumbers) {
    if (slotNumbers.isEmpty) return "N/A";
    List<int> sortedSlots = slotNumbers
        .map((slot) => int.parse(slot.replaceAll(RegExp(r'[^0-9]'), '')))
        .toList()
      ..sort();
    String startTime = _slotToTime(sortedSlots.first);
    String endTime = _slotToTime(sortedSlots.last + 1);
    return "$startTime - $endTime";
  }

  String _slotToTime(int slot) {
    int hour = slot % 24;
    String period = hour < 12 ? "AM" : "PM";
    int formattedHour = (hour == 0 || hour == 12) ? 12 : (hour % 12);
    return "$formattedHour:00 $period";
  }

  String getUpiQRData() {
    return "upi://pay?pa=$upiId&pn=${widget.turfName}&mc=&tid=&tr=$transactionRefId"
        "&tn=Turf Booking&am=$totalAmount&cu=INR";
  }

  void _startPaymentPolling() {
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in. Please sign in.")),
      );
      Navigator.pop(context);
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      DocumentSnapshot paymentDoc =
      await _firestore.collection("payments").doc(transactionRefId).get();
      if (paymentDoc.exists && paymentDoc["status"] == "SUCCESS") {
        timer.cancel();
        _completePayment();
      }
    });
  }

  Future<void> _completePayment() async {
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: User not found. Please sign in again.")),
      );
      return;
    }
    String userId = user.uid;
    String ticketId = DateTime.now().millisecondsSinceEpoch.toString();
    DocumentReference bookingRef =
    _firestore.collection("bookings").doc(widget.selectedDate);
    String selectedTime = _formatSelectedTime(widget.slotNumbers);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot bookingSnapshot = await transaction.get(bookingRef);
      if (bookingSnapshot.exists) {
        transaction.update(bookingRef, {
          "slots": FieldValue.arrayUnion(
            widget.slotNumbers.map((slot) => {"slot": slot, "userId": userId}).toList(),
          ),
          "totalBooked": FieldValue.increment(widget.slotNumbers.length),
        });
      } else {
        transaction.set(bookingRef, {
          "turfName": widget.turfName,
          "slots": widget.slotNumbers.map((slot) => {"slot": slot, "userId": userId}).toList(),
          "totalBooked": widget.slotNumbers.length,
        });
      }
    });
    await _firestore.collection("tickets").doc(ticketId).set({
      "ticketId": ticketId,
      "userId": userId,
      "turfName": widget.turfName,
      "date": widget.selectedDate,
      "time": selectedTime,
      "slots": widget.slotNumbers,
      "amount": totalAmount,
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TicketScreen(
          ticketId: ticketId,
          turfName: widget.turfName,
          selectedDate: widget.selectedDate,
          selectedTime: selectedTime,
          slotNumbers: widget.slotNumbers,
          totalAmount: totalAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        centerTitle: true, // ✅ Center the title
      ),
      body: Center( // ✅ Wrap with Center to align all content
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // ✅ Center vertically
            crossAxisAlignment: CrossAxisAlignment.center, // ✅ Center horizontally
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // ✅ Center text
                  children: [
                    Text("Turf: ${widget.turfName}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text("Date: ${widget.selectedDate}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center),
                    Text("Time: ${_formatSelectedTime(widget.slotNumbers)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center),
                    Text("Total: ₹$totalAmount",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text("Scan QR Code to Pay",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              const SizedBox(height: 10),
              QrImageView(
                data: getUpiQRData(),
                size: 220,
                version: QrVersions.auto,
                gapless: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
