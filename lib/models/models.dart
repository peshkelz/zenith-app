import 'dart:convert';

// مدل تراکنش مالی (درآمد / هزینه)
class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final bool isExpense; // true: هزینه, false: درآمد
  final String category;
  final DateTime date;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'isExpense': isExpense,
    'category': category,
    'date': date.toIso8601String(),
  };

  factory TransactionItem.fromMap(Map<String, dynamic> map) => TransactionItem(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
    isExpense: map['isExpense'] ?? true,
    category: map['category'] ?? 'متفرقه',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
  );

  String toJson() => json.encode(toMap());
  factory TransactionItem.fromJson(String source) => TransactionItem.fromMap(json.decode(source));
}

// مدل ردیاب عادت
class HabitItem {
  final String id;
  final String title;
  final String iconName;
  int streak;
  String lastCompletedDate; // format: YYYY-MM-DD

  HabitItem({
    required this.id,
    required this.title,
    required this.iconName,
    this.streak = 0,
    this.lastCompletedDate = '',
  });

  bool isCompletedToday() {
    final today = _dateKey(DateTime.now());
    return lastCompletedDate == today;
  }

  void toggleToday() {
    final today = _dateKey(DateTime.now());
    if (isCompletedToday()) {
      lastCompletedDate = '';
      if (streak > 0) streak--;
    } else {
      lastCompletedDate = today;
      streak++;
    }
  }

  static String _dateKey(DateTime dt) =>
      "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'iconName': iconName,
    'streak': streak,
    'lastCompletedDate': lastCompletedDate,
  };

  factory HabitItem.fromMap(Map<String, dynamic> map) => HabitItem(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    iconName: map['iconName'] ?? 'star',
    streak: map['streak'] ?? 0,
    lastCompletedDate: map['lastCompletedDate'] ?? '',
  );

  String toJson() => json.encode(toMap());
  factory HabitItem.fromJson(String source) => HabitItem.fromMap(json.decode(source));
}

// مدل وظیفه روزانه
class TaskItem {
  final String id;
  final String title;
  bool isDone;
  final String priority; // 'high', 'medium', 'low'

  TaskItem({
    required this.id,
    required this.title,
    this.isDone = false,
    this.priority = 'medium',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'isDone': isDone,
    'priority': priority,
  };

  factory TaskItem.fromMap(Map<String, dynamic> map) => TaskItem(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    isDone: map['isDone'] ?? false,
    priority: map['priority'] ?? 'medium',
  );

  String toJson() => json.encode(toMap());
  factory TaskItem.fromJson(String source) => TaskItem.fromMap(json.decode(source));
}

// مدل نرخ‌های بازار
class MarketRate {
  final String key;
  final String name;
  double price;
  final String unit;
  final double change24h;

  MarketRate({
    required this.key,
    required this.name,
    required this.price,
    this.unit = 'تومان',
    this.change24h = 0.0,
  });

  Map<String, dynamic> toMap() => {
    'key': key,
    'name': name,
    'price': price,
    'unit': unit,
    'change24h': change24h,
  };

  factory MarketRate.fromMap(Map<String, dynamic> map) => MarketRate(
    key: map['key'] ?? '',
    name: map['name'] ?? '',
    price: (map['price'] as num?)?.toDouble() ?? 0.0,
    unit: map['unit'] ?? 'تومان',
    change24h: (map['change24h'] as num?)?.toDouble() ?? 0.0,
  );
}
