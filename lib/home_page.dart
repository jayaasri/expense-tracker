import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'expense_model.dart';
import 'fund_condition_widget.dart';
import 'item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final itemController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  late SharedPreferences _prefs;
  List<ExpenseModel> expenses = [];
  int totalMoney = 0;
  int spentMoney = 0;
  int income = 0;

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    _prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = _prefs.getStringList('expenses');
    if (jsonList != null) {
      setState(() {
        expenses = jsonList.map((json) => ExpenseModel.fromJson(jsonDecode(json))).toList();
        calculateTotals();
      });
    }
  }

  Future<void> saveExpenses() async {
    final List<String> jsonList = expenses.map((expense) => jsonEncode(expense.toJson())).toList();
    await _prefs.setStringList('expenses', jsonList);
  }

  void addExpense(ExpenseModel expense) {
    setState(() {
      expenses.add(expense);
      calculateTotals();
    });
    saveExpenses();
  }

  void updateTotals(int newTotalMoney, int newSpentMoney, int newIncome) {
    setState(() {
      totalMoney = newTotalMoney;
      spentMoney = newSpentMoney;
      income = newIncome;
    });
  }

  void updateExpense(int index, ExpenseModel expense) {
    setState(() {
      expenses[index] = expense;
      calculateTotals();
    });
    saveExpenses();
  }

  void deleteExpense(int index) {
  final deletedExpense = expenses[index];
  setState(() {
    expenses.removeAt(index);
    if (deletedExpense.isIncome) {
      income -= deletedExpense.amount;
      totalMoney -= deletedExpense.amount;
    } else {
      spentMoney -= deletedExpense.amount;
      totalMoney += deletedExpense.amount; // Subtracting an expense adds to totalMoney
    }
  });
  updateTotals(totalMoney, spentMoney, income);
  saveExpenses();
  
}

  void calculateTotals() {
    int total = 0;
    int spent = 0;
    int earnings = 0;

    for (var expense in expenses) {
      if (expense.isIncome) {
        total += expense.amount;
        earnings += expense.amount;
      } else {
        total -= expense.amount;
        spent += expense.amount;
      }
    }

    setState(() {
      totalMoney = total;
      spentMoney = spent;
      income = earnings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String currentOption = "expense";

              return AlertDialog(
                title: const Text("ADD TRANSACTION"),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: itemController,
                        decoration: const InputDecoration(hintText: "Enter the Item"),
                      ),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: "Enter the Amount"),
                      ),
                      TextField(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            final String date = DateFormat.yMMMMd().format(pickedDate);
                            dateController.text = date;
                          }
                        },
                        readOnly: true,
                        controller: dateController,
                        decoration: const InputDecoration(
                          labelText: "DATE",
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Radio(
                            value: "expense",
                            groupValue: currentOption,
                            onChanged: (value) {
                              setState(() {
                                currentOption = value.toString();
                              });
                            },
                          ),
                          const Text(
                            "Expense",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Radio(
                            value: "income",
                            groupValue: currentOption,
                            onChanged: (value) {
                              setState(() {
                                currentOption = value.toString();
                              });
                            },
                          ),
                          const Text(
                            "Income",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("CANCEL"),
                  ),
                  TextButton(
                    onPressed: () {
                      final expense = ExpenseModel(
                        item: itemController.text,
                        amount: int.parse(amountController.text),
                        isIncome: currentOption == "income",
                        date: DateTime.now(),
                      );
                      addExpense(expense);
                      itemController.clear();
                      amountController.clear();
                      dateController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text("ADD"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 54, 244, 165),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FundCondition(
                    type: "DEPOSIT",
                    amount: "$totalMoney",
                    icon: "blue",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: FundCondition(
                    type: "EXPENSE",
                    amount: "$spentMoney",
                    icon: "orange",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 8),
                  child: FundCondition(
                    type: "INCOME",
                    amount: "$income",
                    icon: "grey",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Any action you want to perform on tapping an item
                    },
                    child: Item(
                      expense: expenses[index],
                      onDelete: () {
                        deleteExpense(index);
                      },
                      onUpdate: (updatedExpense) {
                        updateExpense(index, updatedExpense);
                      },
                      updateTotals: updateTotals,
                      totalMoney: totalMoney,
                      spentMoney: spentMoney,
                      income: income,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
