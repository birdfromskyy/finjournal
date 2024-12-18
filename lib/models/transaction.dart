import 'category.dart';

class Transaction {
  final double amount;
  final DateTime date;
  final Category category;

  Transaction(
      {required this.amount, required this.date, required this.category});
}
