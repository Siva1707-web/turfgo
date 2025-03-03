import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyTicketsScreen extends StatelessWidget {
  final CollectionReference ticketsCollection =
  FirebaseFirestore.instance.collection('tickets');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Tickets"),
        backgroundColor: Colors.purple[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ticketsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No tickets booked yet!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          var tickets = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              var ticket = tickets[index].data() as Map<String, dynamic>;
              return TicketCard(ticket: ticket);
            },
          );
        },
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ticket['eventName'] ?? "Unknown Event",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text("📅 Date: ${ticket['date'] ?? 'N/A'}"),
            Text("⏰ Time: ${ticket['time'] ?? 'N/A'}"),
            Text("📍 Venue: ${ticket['venue'] ?? 'N/A'}"),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Future Feature: Ticket Details
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("View Details"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
