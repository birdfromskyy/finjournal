import 'package:shared_preferences/shared_preferences.dart';

class BalanceManager {
  static const String _balanceKey = 'user_balance';

  static Future<double> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_balanceKey) ?? 0.0;
  }

  static Future<void> setBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, balance);
  }

  static Future<void> updateBalance(double amount) async {
    final currentBalance = await getBalance();
    await setBalance(currentBalance + amount);
  }
}
