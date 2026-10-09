import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GoldLoanScreen extends StatefulWidget {
  const GoldLoanScreen({super.key});

  @override
  State<GoldLoanScreen> createState() => _GoldLoanScreenState();
}

class _GoldLoanScreenState extends State<GoldLoanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16112E),
        title: const Text('محاسبات تخصصی طلا، سکه و وام', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD700),
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'خرید طلا'),
            Tab(text: 'حباب سکه'),
            Tab(text: 'اقساط وام'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GoldCalculatorView(),
          CoinBubbleCalculatorView(),
          LoanCalculatorView(),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// ۱) ماشین‌حساب طلا
// -----------------------------------------------------------------
class GoldCalculatorView extends StatefulWidget {
  const GoldCalculatorView({super.key});

  @override
  State<GoldCalculatorView> createState() => _GoldCalculatorViewState();
}

class _GoldCalculatorViewState extends State<GoldCalculatorView> {
  final _weightController = TextEditingController(text: '4.5');
  final _pricePerGramController = TextEditingController(text: '6850000');
  final _wagePercentController = TextEditingController(text: '15');
  final _profitPercentController = TextEditingController(text: '7');
  final _taxPercentController = TextEditingController(text: '9');

  double _rawGoldPrice = 0;
  double _wageAmount = 0;
  double _profitAmount = 0;
  double _taxAmount = 0;
  double _finalTotalPrice = 0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final weight = double.tryParse(_weightController.text.trim()) ?? 0;
    final pricePerGram = double.tryParse(_pricePerGramController.text.replaceAll(',', '').trim()) ?? 0;
    final wagePercent = double.tryParse(_wagePercentController.text.trim()) ?? 0;
    final profitPercent = double.tryParse(_profitPercentController.text.trim()) ?? 7;
    final taxPercent = double.tryParse(_taxPercentController.text.trim()) ?? 9;

    final rawPrice = weight * pricePerGram;
    final wage = (rawPrice * wagePercent) / 100;
    final profit = ((rawPrice + wage) * profitPercent) / 100;
    // مالیات بر مجموع اجرت و سود طلافروش طبق قانون جدید مالیاتی طلا
    final tax = ((wage + profit) * taxPercent) / 100;
    final total = rawPrice + wage + profit + tax;

    setState(() {
      _rawGoldPrice = rawPrice;
      _wageAmount = wage;
      _profitAmount = profit;
      _taxAmount = tax;
      _finalTotalPrice = total;
    });
  }

  String _fmt(double v) => NumberFormat('#,###').format(v);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(_weightController, 'وزن طلا (گرم)', 'مثلاً ۴.۵', Icons.scale),
          const SizedBox(height: 12),
          _buildTextField(_pricePerGramController, 'قیمت هر گرم طلای ۱۸ عیار (تومان)', 'مثلاً ۶,۸۵۰,۰۰۰', Icons.attach_money),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField(_wagePercentController, 'درصد اجرت ساخت (%)', 'مثلاً ۱۵', Icons.percent)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_profitPercentController, 'سود طلافروش (%)', '۷', Icons.store)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_taxPercentController, 'مالیات (%)', '۹', Icons.receipt_long)),
            ],
          ),
          const SizedBox(height: 20),

          // کارت نتیجه فاکتور خرید
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A200C), Color(0xFF191433)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
            ),
            child: Column(
              children: [
                const Text('مبلغ نهایی فاکتور طلا', style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 6),
                Text(
                  '${_fmt(_finalTotalPrice)} تومان',
                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24, color: Colors.white12),
                _buildRowDetail('قیمت خام طلا:', '${_fmt(_rawGoldPrice)} تومان'),
                const SizedBox(height: 6),
                _buildRowDetail('اجرت ساخت طلاساز:', '${_fmt(_wageAmount)} تومان'),
                const SizedBox(height: 6),
                _buildRowDetail('سود طلافروش (۷٪):', '${_fmt(_profitAmount)} تومان'),
                const SizedBox(height: 6),
                _buildRowDetail('مالیات ارزش‌افزوده اجرت و سود (۹٪):', '${_fmt(_taxAmount)} تومان'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon: Icon(icon, color: const Color(0xFFFFD700), size: 18),
        filled: true,
        fillColor: const Color(0xFF191433),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onChanged: (_) => _calculate(),
    );
  }

  Widget _buildRowDetail(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

// -----------------------------------------------------------------
// ۲) ماشین‌حساب حباب سکه
// -----------------------------------------------------------------
class CoinBubbleCalculatorView extends StatefulWidget {
  const CoinBubbleCalculatorView({super.key});

  @override
  State<CoinBubbleCalculatorView> createState() => _CoinBubbleCalculatorViewState();
}

class _CoinBubbleCalculatorViewState extends State<CoinBubbleCalculatorView> {
  // مشخصات استاندارد انواع سکه
  // امامی: 8.133 گرم - عیار 900
  // بهار آزادی: 8.133 گرم - عیار 900
  // نیم سکه: 4.066 گرم - عیار 900
  // ربع سکه: 2.033 گرم - عیار 900
  // گرمی: 1.01 گرم - عیار 900
  final Map<String, Map<String, dynamic>> _coins = {
    'تمام بهار آزادی (امامی)': {'weight': 8.133, 'karat': 900, 'marketPrice': 74200000.0},
    'نیم سکه بهار آزادی': {'weight': 4.066, 'karat': 900, 'marketPrice': 39800000.0},
    'ربع سکه بهار آزادی': {'weight': 2.033, 'karat': 900, 'marketPrice': 23400000.0},
    'سکه گرمی': {'weight': 1.01, 'karat': 900, 'marketPrice': 10500000.0},
  };

  String _selectedCoin = 'تمام بهار آزادی (امامی)';
  final _dollarController = TextEditingController(text: '92500');
  final _ounceController = TextEditingController(text: '2930');
  late TextEditingController _marketPriceController;

  double _intrinsicValue = 0;
  double _bubbleAmount = 0;
  double _bubblePercent = 0;

  @override
  void initState() {
    super.initState();
    _marketPriceController = TextEditingController(text: _coins[_selectedCoin]!['marketPrice'].toString());
    _calculate();
  }

  void _calculate() {
    final coin = _coins[_selectedCoin]!;
    final weight = (coin['weight'] as num).toDouble();
    final dollar = double.tryParse(_dollarController.text.replaceAll(',', '').trim()) ?? 0;
    final ounce = double.tryParse(_ounceController.text.replaceAll(',', '').trim()) ?? 0;
    final market = double.tryParse(_marketPriceController.text.replaceAll(',', '').trim()) ?? 0;

    // فرمول ارزش ذاتی: وزن × (عیار/۷۵۰) × قیمت هر گرم طلای ۱۸ عیار
    // یا فرمول مستقیم از انس: [انس × دلار ÷ ۳۱.۱۰۳۵] × (۹۰۰ ÷ ۹۹۹.۹) × وزن
    if (ounce > 0 && dollar > 0 && weight > 0) {
      final intrinsic = ((ounce * dollar) / 31.1035) * (0.900 / 0.999) * weight;
      final bubble = market - intrinsic;
      final percent = intrinsic > 0 ? (bubble / intrinsic) * 100 : 0.0;

      setState(() {
        _intrinsicValue = intrinsic;
        _bubbleAmount = bubble;
        _bubblePercent = percent;
      });
    }
  }

  String _fmt(double v) => NumberFormat('#,###').format(v);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedCoin,
            dropdownColor: const Color(0xFF191433),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'نوع سکه',
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF191433),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            items: _coins.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedCoin = val;
                  _marketPriceController.text = _coins[val]!['marketPrice'].toString();
                });
                _calculate();
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dollarController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'قیمت دلار آزاد (تومان)',
                    labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF191433),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onChanged: (_) => _calculate(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ounceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'انس جهانی طلا (دلار)',
                    labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF191433),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onChanged: (_) => _calculate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _marketPriceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'قیمت فعلی سکه در بازار (تومان)',
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF191433),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF191433),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFFF416C).withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('مقدار حباب سکه:', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Text(
                      '${_bubblePercent.toStringAsFixed(1)} %',
                      style: TextStyle(
                        color: _bubbleAmount > 0 ? const Color(0xFFFF5252) : const Color(0xFF00E676),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${_fmt(_bubbleAmount)} تومان',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24, color: Colors.white12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ارزش ذاتی واقعی سکه:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('${_fmt(_intrinsicValue)} تومان', style: const TextStyle(color: Color(0xFF00D2FF), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// ۳) ماشین‌حساب اقساط وام بانکی
// -----------------------------------------------------------------
class LoanCalculatorView extends StatefulWidget {
  const LoanCalculatorView({super.key});

  @override
  State<LoanCalculatorView> createState() => _LoanCalculatorViewState();
}

class _LoanCalculatorViewState extends State<LoanCalculatorView> {
  final _amountController = TextEditingController(text: '100000000');
  final _rateController = TextEditingController(text: '23');
  final _monthsController = TextEditingController(text: '36');

  double _monthlyPayment = 0;
  double _totalInterest = 0;
  double _totalPayment = 0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final loan = double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0;
    final annualRate = double.tryParse(_rateController.text.trim()) ?? 0;
    final months = int.tryParse(_monthsController.text.trim()) ?? 0;

    if (loan > 0 && months > 0) {
      if (annualRate == 0) {
        // قرض‌الحسنه بدون بهره
        setState(() {
          _monthlyPayment = loan / months;
          _totalInterest = 0;
          _totalPayment = loan;
        });
        return;
      }

      // فرمول رسمی بانک مرکزی ایران
      final r = (annualRate / 100) / 12; // نرخ ماهانه
      final powFactor = pow(1 + r, months);
      final payment = (loan * r * powFactor) / (powFactor - 1);
      final totalPay = payment * months;
      final interest = totalPay - loan;

      setState(() {
        _monthlyPayment = payment;
        _totalInterest = interest;
        _totalPayment = totalPay;
      });
    }
  }

  String _fmt(double v) => NumberFormat('#,###').format(v);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'مبلغ وام (تومان)',
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF191433),
              suffixText: 'تومان',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _rateController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'سود سالانه (%)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: '۲۳ یا ۱۸ یا ۴',
                    filled: true,
                    fillColor: const Color(0xFF191433),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onChanged: (_) => _calculate(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _monthsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'مدت بازپرداخت (ماه)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: '۳۶ یا ۶۰',
                    filled: true,
                    fillColor: const Color(0xFF191433),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onChanged: (_) => _calculate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // چیپ‌های میانبر سود بانکی
          Wrap(
            spacing: 8,
            children: [
              _buildRateChip(4, 'قرض‌الحسنه ۴٪'),
              _buildRateChip(18, 'تسهیلات ۱۸٪'),
              _buildRateChip(23, 'تسهیلات ۲۳٪'),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2B38), Color(0xFF191433)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.4)),
            ),
            child: Column(
              children: [
                const Text('مبلغ هر قسط ماهانه', style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 6),
                Text(
                  '${_fmt(_monthlyPayment)} تومان',
                  style: const TextStyle(color: Color(0xFF00D2FF), fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24, color: Colors.white12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('کل سود پرداختی به بانک:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('${_fmt(_totalInterest)} تومان', style: const TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('کل بازپرداخت (اصل + سود):', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('${_fmt(_totalPayment)} تومان', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateChip(double rate, String label) {
    return ActionChip(
      backgroundColor: const Color(0xFF221C42),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      onPressed: () {
        _rateController.text = rate.toStringAsFixed(0);
        _calculate();
      },
    );
  }
}
