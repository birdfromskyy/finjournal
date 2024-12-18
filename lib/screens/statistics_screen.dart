import 'package:flutter/material.dart';
import '../services/shared_preferences_service.dart';
import '../utils/balance_manager.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _showIncome = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await SharedPreferencesService.getTransactions();
    setState(() {
      _transactions = transactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Статистика'),
      ),
      body: Column(
        children: [
          _buildDropdown(),
          _buildSearchField(),
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButton<bool>(
        value: _showIncome,
        onChanged: (bool? newValue) {
          setState(() {
            _showIncome = newValue!;
          });
        },
        items: [
          DropdownMenuItem<bool>(
            value: true,
            child: Text('Доходы'),
          ),
          DropdownMenuItem<bool>(
            value: false,
            child: Text('Расходы'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Поиск по категории или названию',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildTransactionList() {
    final filteredTransactions = _transactions.where((transaction) {
      final matchesType = transaction['isIncome'] == _showIncome;
      final category = transaction['category']?.toLowerCase() ?? '';
      final name = transaction['name']?.toLowerCase() ?? '';
      final matchesQuery =
          category.contains(_searchQuery) || name.contains(_searchQuery);
      return matchesType && matchesQuery;
    }).toList();

    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        final name = transaction['name'];
        final amount = transaction['amount'];
        final category = transaction['category'];
        final date = transaction['date'];

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('$name: ₽${amount.toStringAsFixed(2)}'),
            subtitle: Text('$category - $date'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _editTransaction(transaction);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteTransaction(transaction);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editTransaction(Map<String, dynamic> transaction) {
    final TextEditingController _nameController =
        TextEditingController(text: transaction['name']);
    final TextEditingController _amountController =
        TextEditingController(text: transaction['amount'].toString());
    DateTime _selectedDate = DateTime.parse(transaction['date']);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Редактировать транзакцию'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Название'),
                  ),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Сумма'),
                  ),
                  Row(
                    children: [
                      Text('Дата: ${_selectedDate.toLocal()}'.split(' ')[0]),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () async {
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
                        },
                        child: Text('Выбрать дату'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Отмена'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      transaction['name'] = _nameController.text;
                      transaction['amount'] =
                          double.tryParse(_amountController.text) ??
                              transaction['amount'];
                      transaction['date'] = _selectedDate.toIso8601String();
                    });
                    await SharedPreferencesService.saveTransactions(
                        _transactions);
                    Navigator.pop(context);
                  },
                  child: Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteTransaction(Map<String, dynamic> transaction) async {
    final amount = transaction['amount'];
    final isIncome = transaction['isIncome'];

    final adjustment = isIncome ? -amount : amount;
    await BalanceManager.updateBalance(adjustment);

    _transactions.remove(transaction);
    await SharedPreferencesService.saveTransactions(_transactions);
    setState(() {});
  }
}
