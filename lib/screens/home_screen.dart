import 'package:flutter/material.dart';
import '../utils/balance_manager.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance = await BalanceManager.getBalance();
    setState(() {
      _balance = balance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Финансовый журнал'),
      ),
      body: Column(
        children: [
          _buildBalanceCard(),
          Expanded(child: _buildNavigationButtons(context)),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Текущий баланс', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text(
              '₽ ${_balance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildNavButton(
            context, 'Добавить транзакцию', Icons.add, '/add-transaction'),
        _buildNavButton(context, 'Категории', Icons.category, '/categories'),
        _buildNavButton(context, 'Статистика', Icons.bar_chart, '/statistics'),
        _buildNavButton(context, 'Настройки', Icons.settings, '/settings'),
      ],
    );
  }

  Widget _buildNavButton(
      BuildContext context, String label, IconData icon, String route) {
    return ElevatedButton(
      onPressed: () =>
          Navigator.pushNamed(context, route).then((_) => _loadBalance()),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
