import 'package:flutter/material.dart';
import '../utils/balance_manager.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentBalance();
  }

  Future<void> _loadCurrentBalance() async {
    final balance = await BalanceManager.getBalance();
    setState(() {
      _controller.text = balance.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Текущий баланс',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Введите баланс',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final newBalance = double.tryParse(_controller.text) ?? 0.0;
                await BalanceManager.setBalance(newBalance);
                Navigator.pop(context);
              },
              child: Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
