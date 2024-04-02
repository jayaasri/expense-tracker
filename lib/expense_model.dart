class ExpenseModel {
  String item;
  int amount;
  bool isIncome;
  DateTime date;

  ExpenseModel({
    required this.item,
    required this.amount,
    required this.isIncome,
    required this.date,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      item: json['item'],
      amount: json['amount'],
      isIncome: json['isIncome'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'amount': amount,
      'isIncome': isIncome,
      'date': date.toIso8601String(),
    };
  }
}
