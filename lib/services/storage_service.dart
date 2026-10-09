import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _keyTransactions = 'zenith_transactions';
  static const String _keyHabits = 'zenith_habits';
  static const String _keyTasks = 'zenith_tasks';
  static const String _keyRates = 'zenith_rates';

  // ذخیره و بازیابی تراکنش‌ها
  static Future<List<TransactionItem>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_keyTransactions);
    if (data == null || data.isEmpty) {
      // داده‌های پیش‌فرض نمونه
      final defaults = [
        TransactionItem(
          id: '1',
          title: 'حقوق ماهانه',
          amount: 35000000,
          isExpense: false,
          category: 'حقوق',
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        TransactionItem(
          id: '2',
          title: 'خرید سوپرمارکت',
          amount: 1450000,
          isExpense: true,
          category: 'خوراک',
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TransactionItem(
          id: '3',
          title: 'کافه و رستوران',
          amount: 680000,
          isExpense: true,
          category: 'کافه',
          date: DateTime.now(),
        ),
      ];
      await saveTransactions(defaults);
      return defaults;
    }
    return data.map((e) => TransactionItem.fromJson(e)).toList();
  }

  static Future<void> saveTransactions(List<TransactionItem> list) async {
    final prefs = await SharedPreferences.getInstance();
    final data = list.map((e) => e.toJson()).toList();
    await prefs.setStringList(_keyTransactions, data);
  }

  // ذخیره و بازیابی عادت‌ها
  static Future<List<HabitItem>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_keyHabits);
    if (data == null || data.isEmpty) {
      final defaults = [
        HabitItem(id: '1', title: 'ورزش و پیاده‌روی', iconName: 'fitness', streak: 4),
        HabitItem(id: '2', title: 'مطالعه ۳۰ دقیقه کتاب', iconName: 'book', streak: 7),
        HabitItem(id: '3', title: 'نوشیدن ۲ لیتر آب', iconName: 'water', streak: 3),
        HabitItem(id: '4', title: 'یادگیری مهارت جدید', iconName: 'code', streak: 12),
      ];
      await saveHabits(defaults);
      return defaults;
    }
    return data.map((e) => HabitItem.fromJson(e)).toList();
  }

  static Future<void> saveHabits(List<HabitItem> list) async {
    final prefs = await SharedPreferences.getInstance();
    final data = list.map((e) => e.toJson()).toList();
    await prefs.setStringList(_keyHabits, data);
  }

  // ذخیره و بازیابی وظایف
  static Future<List<TaskItem>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_keyTasks);
    if (data == null || data.isEmpty) {
      final defaults = [
        TaskItem(id: '1', title: 'بررسی صورت‌حساب‌های ماه', isDone: false, priority: 'high'),
        TaskItem(id: '2', title: 'محاسبه حباب سکه و پس‌انداز طلا', isDone: true, priority: 'medium'),
        TaskItem(id: '3', title: 'برنامه‌ریزی اهداف هفته آینده', isDone: false, priority: 'low'),
      ];
      await saveTasks(defaults);
      return defaults;
    }
    return data.map((e) => TaskItem.fromJson(e)).toList();
  }

  static Future<void> saveTasks(List<TaskItem> list) async {
    final prefs = await SharedPreferences.getInstance();
    final data = list.map((e) => e.toJson()).toList();
    await prefs.setStringList(_keyTasks, data);
  }

  // ذخیره و بازیابی نرخ‌های بازار
  static Future<List<MarketRate>> loadRates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyRates);
    if (raw == null) {
      final defaults = [
        MarketRate(key: 'usd', name: 'دلار آزاد', price: 92500, change24h: 0.8),
        MarketRate(key: 'tether', name: 'تتر (USDT)', price: 93100, change24h: 0.5),
        MarketRate(key: 'gold18', name: 'طلای ۱۸ عیار (هر گرم)', price: 6850000, change24h: 1.2),
        MarketRate(key: 'coin_emami', name: 'سکه تمام امامی', price: 74200000, change24h: -0.4),
        MarketRate(key: 'coin_half', name: 'نیم سکه بهار آزادی', price: 39800000, change24h: 0.2),
        MarketRate(key: 'coin_quarter', name: 'ربع سکه بهار آزادی', price: 23400000, change24h: 1.1),
        MarketRate(key: 'ounce', name: 'انس طلا (جهانی)', price: 2930, unit: 'دلار', change24h: 0.3),
      ];
      await saveRates(defaults);
      return defaults;
    }
    final List list = json.decode(raw);
    return list.map((e) => MarketRate.fromMap(e)).toList();
  }

  static Future<void> saveRates(List<MarketRate> list) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_keyRates, data);
  }
}
