import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(FinanceJournalApp());
}

class FinanceJournalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Финансовый журнал',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
      routes: {
        '/add-transaction': (context) => AddTransactionScreen(),
        '/categories': (context) => CategoriesScreen(),
        '/statistics': (context) => StatisticsScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
