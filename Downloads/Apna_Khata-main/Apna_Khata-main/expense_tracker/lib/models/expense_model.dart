import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String item;
  final double amount;
  final String category;
  final Timestamp timestamp;

  Expense({
    required this.id,
    required this.item,
    required this.amount,
    required this.category,
    required this.timestamp,
  });

  // A factory constructor to create an Expense from a Firestore document
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      item: data['item'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      category: data['category'] ?? 'Other',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // A method to convert an Expense instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'item': item,
      'amount': amount,
      'category': category,
      'timestamp': timestamp,
    };
  }
}