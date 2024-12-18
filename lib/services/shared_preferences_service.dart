import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/category.dart';

class SharedPreferencesService {
  static Future<void> saveBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', balance);
  }

  static Future<double> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('balance') ?? 0.0;
  }

  static Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = jsonEncode(categories
        .map((c) => {'name': c.name, 'isIncome': c.isIncome})
        .toList());
    await prefs.setString('categories', categoriesJson);
  }

  static Future<List<Category>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesString = prefs.getString('categories');
    if (categoriesString != null) {
      final List<dynamic> categoriesJson = jsonDecode(categoriesString);
      return categoriesJson
          .map((json) =>
              Category(name: json['name'], isIncome: json['isIncome']))
          .toList();
    }
    return [
      Category(name: 'Общие доходы', isIncome: true),
      Category(name: 'Общие расходы', isIncome: false),
    ];
  }

  static Future<void> saveTransactions(
      List<Map<String, dynamic>> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = jsonEncode(transactions);
    await prefs.setString('transactions', transactionsJson);
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsString = prefs.getString('transactions');
    if (transactionsString != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(transactionsString));
    }
    return [];
  }
}
