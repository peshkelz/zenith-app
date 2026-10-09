import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  List<TransactionItem> _transactions = [];
  String _filter = 'all'; // 'all', 'expense', 'income'

  final List<Map<String, dynamic>> _categories = [
    {'name': 'خوراک', 'icon': Icons.restaurant, 'color': Color(0xFFFF9800)},
    {'name': 'کافه و رستوران', 'icon': Icons.local_cafe, 'color': Color(0xFFE91E63)},
    {'name': 'خرید', 'icon': Icons.shopping_bag, 'color': Color(0xFF9C27B0)},
    {'name': 'مسکن و قبوض', 'icon': Icons.home, 'color': Color(0xFF3F51B5)},
    {'name': 'حمل‌ونقل', 'icon': Icons.directions_car, 'color': Color(0xFF00BCD4)},
    {'name': 'حقوق', 'icon': Icons.account_balance_wallet, 'color': Color(0xFF4CAF50)},
    {'name': 'سرمایه‌گذاری', 'icon': Icons.trending_up, 'color': Color(0xFFFFD700)},
    {'name': 'متفرقه', 'icon': Icons.category, 'color': Color(0xFF607D8B)},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await StorageService.loadTransactions();
    setState(() {
      _transactions = list;
    });
  }

  String _format(double v) => NumberFormat('#,###').format(v);

  double get _totalIncome => _transactions
      .where((e) => !e.isExpense)
      .fold(0.0, (sum, i) => sum + i.amount);

  double get _totalExpense => _transactions
      .where((e) => e.isExpense)
      .fold(0.0, (sum, i) => sum + i.amount);

  double get _balance => _totalIncome - _totalExpense;

  List<TransactionItem> get _filteredList {
    if (_filter == 'expense') return _transactions.where((e) => e.isExpense).toList();
    if (_filter == 'income') return _transactions.where((e) => !e.isExpense).toList();
    return _transactions;
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isExpense = true;
    String selectedCategory = 'خوراک';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF191433),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ثبت تراکنش جدید',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // نوع تراکنش (هزینه / درآمد)
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('هزینه 🔻')),
                      ButtonSegment(value: false, label: Text('درآمد 🔺')),
                    ],
                    selected: {isExpense},
                    onSelectionChanged: (val) {
                      setModalState(() {
                        isExpense = val.first;
                        selectedCategory = isExpense ? 'خوراک' : 'حقوق';
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'عنوان (مثلاً ناهار، حقوق، کرایه)',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: const Color(0xFF221C42),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'مبلغ (تومان)',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: const Color(0xFF221C42),
                      suffixText: 'تومان',
                      suffixStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('انتخاب دسته‌بندی:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _categories.map((c) {
                      final isSelected = selectedCategory == c['name'];
                      return ChoiceChip(
                        label: Text(c['name']),
                        selected: isSelected,
                        selectedColor: (c['color'] as Color).withOpacity(0.3),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        backgroundColor: const Color(0xFF221C42),
                        onSelected: (_) => setModalState(() => selectedCategory = c['name']),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: isExpense ? const Color(0xFFFF416C) : const Color(0xFF00E676),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final amount = double.tryParse(amountController.text.replaceAll(',', '').trim()) ?? 0;
                      if (title.isEmpty || amount <= 0) return;

                      final item = TransactionItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: title,
                        amount: amount,
                        isExpense: isExpense,
                        category: selectedCategory,
                        date: DateTime.now(),
                      );

                      setState(() {
                        _transactions.insert(0, item);
                      });
                      await StorageService.saveTransactions(_transactions);
                      if (mounted) Navigator.pop(ctx);
                    },
                    child: const Text('ثبت و ذخیره', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16112E),
        title: const Text('مدیریت دخل و خرج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00D2FF),
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('ثبت تراکنش', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // کارت خلاصه موجودی
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F1742), Color(0xFF110D26)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('موجودی خالص کیف پول', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    '${_format(_balance)} تومان',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('کل درآمدها 🔺', style: TextStyle(color: Color(0xFF00E676), fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('${_format(_totalIncome)} ت', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(height: 30, width: 1, color: Colors.white12),
                      Column(
                        children: [
                          const Text('کل هزینه‌ها 🔻', style: TextStyle(color: Color(0xFFFF5252), fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('${_format(_totalExpense)} ت', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // فیلترها
            Row(
              children: [
                _buildFilterChip('همه', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('هزینه‌ها', 'expense'),
                const SizedBox(width: 8),
                _buildFilterChip('درآمدها', 'income'),
              ],
            ),
            const SizedBox(height: 16),

            // لیست تراکنش‌ها
            if (_filteredList.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text('هنوز تراکنشی ثبت نشده است', style: TextStyle(color: Colors.grey.shade500)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredList.length,
                itemBuilder: (context, index) {
                  final item = _filteredList[index];
                  return Dismissible(
                    key: Key(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) async {
                      setState(() {
                        _transactions.removeWhere((e) => e.id == item.id);
                      });
                      await StorageService.saveTransactions(_transactions);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF191433),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.04)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: item.isExpense
                                  ? const Color(0xFFFF5252).withOpacity(0.15)
                                  : const Color(0xFF00E676).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                              color: item.isExpense ? const Color(0xFFFF5252) : const Color(0xFF00E676),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.category} • ${DateFormat('yyyy/MM/dd').format(item.date)}',
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${item.isExpense ? '-' : '+'} ${_format(item.amount)}',
                            style: TextStyle(
                              color: item.isExpense ? const Color(0xFFFF5252) : const Color(0xFF00E676),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF00D2FF),
      labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      backgroundColor: const Color(0xFF221C42),
      onSelected: (_) => setState(() => _filter = value),
    );
  }
}
