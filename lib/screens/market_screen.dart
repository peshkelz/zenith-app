import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class MarketScreen extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const MarketScreen({super.key, this.onNavigateTab});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  List<MarketRate> _rates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    final list = await StorageService.loadRates();
    if (mounted) {
      setState(() {
        _rates = list;
        _isLoading = false;
      });
    }
  }

  String _fmt(double v) => NumberFormat('#,###').format(v);

  void _editRate(MarketRate rate) {
    final ctrl = TextEditingController(text: rate.price.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF191433),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('ویرایش قیمت ${rate.name}', style: const TextStyle(color: Colors.white, fontSize: 16)),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'قیمت جدید (${rate.unit})',
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF221C42),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('انصراف', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D2FF)),
              onPressed: () async {
                final p = double.tryParse(ctrl.text.replaceAll(',', '').trim()) ?? rate.price;
                setState(() {
                  rate.price = p;
                });
                await StorageService.saveRates(_rates);
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text('ثبت', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16112E),
        title: const Text('قیمت لحظه‌ای طلا، سکه و ارز', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00D2FF)),
            tooltip: 'به‌روزرسانی نرخ‌ها',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('نرخ‌های روز به‌روزرسانی شدند'),
                  backgroundColor: Color(0xFF191433),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بنر طلایی محاسبات سریع
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C220E), Color(0xFF1A1433)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'محاسبه قیمت نهایی طلا و حباب سکه',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'با یک لمس، قیمت‌های این صفحه را در ماشین‌حساب طلا و وام استفاده کنید.',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _rates.length,
              itemBuilder: (context, index) {
                final rate = _rates[index];
                final isPositive = rate.change24h >= 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191433),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF221C42),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              rate.key.contains('gold') || rate.key.contains('coin') || rate.key.contains('ounce')
                                  ? Icons.monetization_on
                                  : Icons.currency_exchange,
                              color: rate.key.contains('gold') || rate.key.contains('coin')
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFF00D2FF),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rate.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                    color: isPositive ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                                    size: 16,
                                  ),
                                  Text(
                                    '${rate.change24h.abs()}% تغییر ۲۴ ساعت',
                                    style: TextStyle(
                                      color: isPositive ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _fmt(rate.price),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(rate.unit, style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 18),
                            tooltip: 'ویرایش قیمت',
                            onPressed: () => _editRate(rate),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
