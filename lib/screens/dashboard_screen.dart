import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int tabIndex) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TransactionItem> _transactions = [];
  List<HabitItem> _habits = [];
  List<TaskItem> _tasks = [];
  List<MarketRate> _rates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final tr = await StorageService.loadTransactions();
    final hb = await StorageService.loadHabits();
    final tk = await StorageService.loadTasks();
    final rt = await StorageService.loadRates();
    if (mounted) {
      setState(() {
        _transactions = tr;
        _habits = hb;
        _tasks = tk;
        _rates = rt;
        _isLoading = false;
      });
    }
  }

  String _formatNumber(double num) {
    return NumberFormat('#,###').format(num);
  }

  double get _totalIncome => _transactions
      .where((e) => !e.isExpense)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get _totalExpense => _transactions
      .where((e) => e.isExpense)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get _balance => _totalIncome - _totalExpense;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00D2FF)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C20),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF00D2FF),
          backgroundColor: const Color(0xFF1E1738),
          onRefresh: _loadAllData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // هدر خوش‌آمدگویی و آیکون نئونی
                _buildHeader(),
                const SizedBox(height: 20),

                // ویجت ۱: کارت‌های لحظه‌ای طلا و دلار
                _buildMarketWidget(),
                const SizedBox(height: 20),

                // ویجت ۲: کارت هوشمند دخل و خرج
                _buildFinanceWidget(),
                const SizedBox(height: 20),

                // ویجت ۳: ردیاب عادت‌ها و چک‌لیست امروز
                _buildHabitsWidget(),
                const SizedBox(height: 20),

                // ویجت ۴: ابزارهای پرکاربرد سریع (محاسبه طلا، حباب، وام)
                _buildQuickToolsWidget(),
                const SizedBox(height: 24),

                // بنر راهنمای ویجت و شورتکات‌های آیفون
                _buildIosTipCard(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'دستیار هوشمند زنیت',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'داشبورد یکپارچه مالی و زندگی شما',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
            ),
          ],
        ),
        // آیکون کریستالی شیک
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF00D2FF), Color(0xFF9D50BB), Color(0xFFFF416C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9D50BB).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
        ),
      ],
    );
  }

  // ویجت طلا و ارز
  Widget _buildMarketWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191433),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF416C).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.trending_up, color: Color(0xFFFF416C), size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'نبض بازار (طلا و ارز)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => widget.onNavigateTab(2), // تب طلا و بازار
                child: const Text('مشاهده کامل >', style: TextStyle(color: Color(0xFF00D2FF), fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _rates.take(4).length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final rate = _rates[index];
                final isPositive = rate.change24h >= 0;
                return Container(
                  width: 135,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF221C42),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rate.name,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${_formatNumber(rate.price)} ${rate.unit}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            color: isPositive ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                            size: 16,
                          ),
                          Text(
                            '${rate.change24h.abs()}%',
                            style: TextStyle(
                              color: isPositive ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ویجت دخل و خرج
  Widget _buildFinanceWidget() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1F1742),
            const Color(0xFF16112E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D2FF).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'موجودی کل شما',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onPressed: () => widget.onNavigateTab(1), // تب مالی
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatNumber(_balance)} تومان',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24, color: Colors.white12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_downward, color: Color(0xFF00E676), size: 16),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('درآمد کل', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(
                          '${_formatNumber(_totalIncome)} ت',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_upward, color: Color(0xFFFF5252), size: 16),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('هزینه کل', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(
                          '${_formatNumber(_totalExpense)} ت',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ویجت عادت‌ها و تسک‌ها
  Widget _buildHabitsWidget() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF191433),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9D50BB).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.whatshot, color: Color(0xFFFF9100), size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'عادت‌های فعال امروز',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => widget.onNavigateTab(3), // تب عادت‌ها
                child: const Text('مدیریت >', style: TextStyle(color: Color(0xFF00D2FF), fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: _habits.take(3).map((h) {
              final isDone = h.isCompletedToday();
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFF142E25) : const Color(0xFF221C42),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDone ? const Color(0xFF00E676).withOpacity(0.3) : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(h.title, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9100).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '🔥 ${h.streak}',
                            style: const TextStyle(color: Color(0xFFFF9100), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isDone ? const Color(0xFF00E676) : Colors.grey,
                        size: 22,
                      ),
                      onPressed: () async {
                        setState(() {
                          h.toggleToday();
                        });
                        await StorageService.saveHabits(_habits);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ابزارهای محاسباتی سریع
  Widget _buildQuickToolsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ابزارهای هوشمند مالی و محاسباتی',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildToolButton(
                title: 'فرمول خرید طلا',
                subtitle: 'اجرت + سود + مالیات',
                icon: Icons.monetization_on_outlined,
                color: const Color(0xFFFFD700),
                onTap: () => widget.onNavigateTab(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToolButton(
                title: 'حباب انواع سکه',
                subtitle: 'امامی، نیم، ربع',
                icon: Icons.pie_chart_outline,
                color: const Color(0xFFFF416C),
                onTap: () => widget.onNavigateTab(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToolButton(
                title: 'اقساط وام بانک',
                subtitle: 'سود ۴٪ تا ۲۳٪',
                icon: Icons.account_balance_outlined,
                color: const Color(0xFF00D2FF),
                onTap: () => widget.onNavigateTab(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF191433),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIosTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1636),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF9D50BB).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D2FF), Color(0xFF9D50BB), Color(0xFFFF416C)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.apple, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'افزودن به صفحه اصلی آیفون',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'در سافاری دکمه Share و سپس Add to Home Screen را بزنید تا مثل اپلیکیشن اختصاصی با آیکون نئونی نصب شود.',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
