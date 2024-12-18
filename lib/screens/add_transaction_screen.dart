import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../services/shared_preferences_service.dart';
import '../utils/balance_manager.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  List<Category> _categories = [];
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _categories = await SharedPreferencesService.getCategories();
    setState(() {
      _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
    });
  }

  void _addTransaction() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final name = _nameController.text.trim();
    if (_selectedCategory != null && amount != 0.0 && name.isNotEmpty) {
      final transaction = {
        'name': name,
        'amount': amount,
        'date': _selectedDate.toIso8601String(),
        'category': _selectedCategory!.name,
        'isIncome': _selectedCategory!.isIncome,
      };

      final transactions = await SharedPreferencesService.getTransactions();
      transactions.add(transaction);
      await SharedPreferencesService.saveTransactions(transactions);

      final adjustment = _selectedCategory!.isIncome ? amount : -amount;
      await BalanceManager.updateBalance(adjustment);

      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить транзакцию'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Название'),
            ),
            DropdownButton<Category>(
              value: _selectedCategory,
              onChanged: (Category? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: _categories
                  .map<DropdownMenuItem<Category>>((Category category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Сумма'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Дата: ${DateFormat.yMd().format(_selectedDate)}'),
                Spacer(),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Выбрать дату'),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTransaction,
              child: Text('Добавить транзакцию'),
            ),
          ],
        ),
      ),
    );
  }
}
