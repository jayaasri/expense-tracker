import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'expense_model.dart';

class Item extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onDelete;
  final Function(ExpenseModel) onUpdate;
  final void Function(int, int, int) updateTotals;

  final int totalMoney;
  final int spentMoney;
  final int income;

  const Item({
    Key? key,
    required this.expense,
    required this.onDelete,
    required this.onUpdate,
    required this.updateTotals,
    required this.totalMoney,
    required this.spentMoney,
    required this.income,
  }) : super(key: key);

  // New callback function to update the expense
  void _updateExpense(ExpenseModel updatedExpense) {
    // Get the difference between the new and old amount
    int amountDifference = updatedExpense.amount - expense.amount;

    // Update the expense in the parent widget
    onUpdate(updatedExpense);

    // Update the total money based on the difference
    int newTotalMoney =
        totalMoney + (expense.isIncome ? amountDifference : -amountDifference);

    // Update the spent money and income accordingly
    int newSpentMoney = spentMoney + (expense.isIncome ? 0 : amountDifference);
    int newIncome = income + (expense.isIncome ? amountDifference : 0);

    // Update totals using the callback function
    updateTotals(newTotalMoney, newSpentMoney, newIncome);
  }

  void _deleteExpense() {
    // Call the delete callback
    onDelete();
    // Update totals using the callback function
    updateTotals(totalMoney, spentMoney, income);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return UpdateExpenseDialog(
              expense: expense,
              onUpdate: onUpdate,
              totalMoney: totalMoney,
              spentMoney: spentMoney,
              income: income,
              // Pass the callback function to the dialog
              updateExpense: _updateExpense,
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 9,
          bottom: 7,
          left: 12,
          right: 11,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(blurRadius: 0.4),
            ],
            borderRadius: BorderRadius.all(
              Radius.circular(11.5),
            ),
            color: Colors.white,
          ),
          child: Row(
            children: [
              SizedBox(
                height: 35,
                width: 35,
                child: expense.isIncome
                    ? Image.asset("images/income.png")
                    : Image.asset("images/expense.png"),
              ),
              const SizedBox(width: 17),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.item,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat.yMMMMd().format(expense.date),
                    style: const TextStyle(
                      fontSize: 14.7,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                "\Rs.${expense.amount}",
                style: TextStyle(
                  fontSize: 20.5,
                  color: expense.isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () {
    // Call the onDelete callback to delete the expense
              onDelete();
                  },
              icon: Icon(Icons.delete),
              color: Colors.red,
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class UpdateExpenseDialog extends StatefulWidget {
  final ExpenseModel expense;
  final Function(ExpenseModel) onUpdate;
  final int totalMoney;
  final int spentMoney;
  final int income;
  final Function(ExpenseModel) updateExpense;

  const UpdateExpenseDialog({
    Key? key,
    required this.expense,
    required this.onUpdate,
    required this.totalMoney,
    required this.spentMoney,
    required this.income,
    required this.updateExpense,
  }) : super(key: key);

  @override
  _UpdateExpenseDialogState createState() => _UpdateExpenseDialogState();
}

class _UpdateExpenseDialogState extends State<UpdateExpenseDialog> {
  TextEditingController itemController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  int localTotalMoney = 0;
  int localSpentMoney = 0;
  int localIncome = 0;

  String currentOption = "expense";

  @override
  void initState() {
    super.initState();
    // Set initial values when the dialog is opened
    itemController.text = widget.expense.item;
    amountController.text = widget.expense.amount.toString();
    dateController.text = DateFormat.yMMMMd().format(widget.expense.date);

    // Set local values for updating state
    localTotalMoney = widget.totalMoney;
    localSpentMoney = widget.spentMoney;
    localIncome = widget.income;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("UPDATE TRANSACTION"),
      content: SizedBox(
        height: 240,
        width: 400,
        child: Column(
          children: [
            TextField(
              controller: itemController,
              decoration: const InputDecoration(
                hintText: "Enter the Item",
                hintStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter the Amount",
                hintStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                onTap: () async {
                  // User can pick a date
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.expense.date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    String date = DateFormat.yMMMMd().format(pickedDate);
                    dateController.text = date;
                  }
                },
                readOnly: true, // Add this line to make the field read-only
                controller: dateController,
                // ... existing code for date picker
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
          child: const Text(
            "CANCEL",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            // Perform the update operation
            int oldAmount = widget.expense.amount;
            ExpenseModel updatedExpense = ExpenseModel(
              item: itemController.text,
              amount: int.parse(amountController.text),
              isIncome: currentOption == "income",
              date: DateFormat.yMMMMd().parse(dateController.text),
            );

            // Calculate the difference and update totalMoney accordingly
            int amountDifference = updatedExpense.amount - oldAmount;

            // Update totalMoney, spentMoney, and income based on the amount difference
            setState(() {
              if (updatedExpense.isIncome) {
                localIncome += amountDifference;
                localTotalMoney += amountDifference;
              } else {
                localSpentMoney += amountDifference;
                localTotalMoney -= amountDifference;
              }
            });

            // Update the expense in the parent widget using the provided callback function
            widget.updateExpense(updatedExpense);
            // Close the dialog
            Navigator.pop(context);
          },
          child: const Text(
            "UPDATE",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
