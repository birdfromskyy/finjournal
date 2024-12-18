import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/shared_preferences_service.dart';
import '../utils/balance_manager.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _categories = await SharedPreferencesService.getCategories();
    setState(() {});
  }

  void _addCategory(String name, bool isIncome) async {
    final newCategory = Category(name: name, isIncome: isIncome);
    _categories.add(newCategory);
    await SharedPreferencesService.saveCategories(_categories);
    setState(() {});
  }

  void _editCategory(Category category) async {
    final TextEditingController _controller =
        TextEditingController(text: category.name);
    bool isIncome = category.isIncome;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Редактировать категорию'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Название категории'),
                  ),
                  Row(
                    children: [
                      Text('Расход'),
                      Switch(
                        value: isIncome,
                        onChanged: (value) {
                          setState(() {
                            isIncome = value;
                          });
                        },
                      ),
                      Text('Доход'),
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
                    final oldName = category.name;
                    final newName = _controller.text;

                    if (category.isIncome != isIncome) {
                      await _recalculateTransactions(category, isIncome);
                    }

                    if (oldName != newName) {
                      await _updateTransactionCategoryNames(oldName, newName);
                    }

                    setState(() {
                      category.name = newName;
                      category.isIncome = isIncome;
                    });
                    await _saveCategories();
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

  Future<void> _recalculateTransactions(
      Category category, bool newIsIncome) async {
    final transactions = await SharedPreferencesService.getTransactions();
    double adjustment = 0.0;

    for (var transaction in transactions) {
      if (transaction['category'] == category.name) {
        final amount = transaction['amount'];
        if (newIsIncome) {
          adjustment += 2 * amount;
        } else {
          adjustment -= 2 * amount;
        }
        transaction['isIncome'] = newIsIncome;
      }
    }

    await SharedPreferencesService.saveTransactions(transactions);
    await BalanceManager.updateBalance(adjustment);
  }

  Future<void> _updateTransactionCategoryNames(
      String oldName, String newName) async {
    final transactions = await SharedPreferencesService.getTransactions();

    for (var transaction in transactions) {
      if (transaction['category'] == oldName) {
        transaction['category'] = newName;
      }
    }

    await SharedPreferencesService.saveTransactions(transactions);
  }

  void _removeCategory(Category category) async {
    _categories.remove(category);
    await SharedPreferencesService.saveCategories(_categories);
    setState(() {});
  }

  Future<void> _saveCategories() async {
    await SharedPreferencesService.saveCategories(_categories);
  }

  void _addCategoryDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    bool isIncome = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Добавить категорию'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Название категории'),
                  ),
                  Row(
                    children: [
                      Text('Расход'),
                      Switch(
                        value: isIncome,
                        onChanged: (value) {
                          setState(() {
                            isIncome = value;
                          });
                        },
                      ),
                      Text('Доход'),
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
                  onPressed: () {
                    _addCategory(_controller.text, isIncome);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Категории'),
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return ListTile(
            title: Text(category.name),
            subtitle: Text(category.isIncome ? 'Доход' : 'Расход'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _editCategory(category);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _removeCategory(category);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCategoryDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
