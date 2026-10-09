import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<HabitItem> _habits = [];
  List<TaskItem> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final hb = await StorageService.loadHabits();
    final tk = await StorageService.loadTasks();
    if (mounted) {
      setState(() {
        _habits = hb;
        _tasks = tk;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddHabitDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF191433),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تعریف عادت جدید', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: TextField(
            controller: titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'عنوان عادت (مثلاً ورزش صبحگاهی)',
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
                final text = titleController.text.trim();
                if (text.isEmpty) return;
                final habit = HabitItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: text,
                  iconName: 'star',
                  streak: 0,
                );
                setState(() {
                  _habits.add(habit);
                });
                await StorageService.saveHabits(_habits);
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text('افزودن', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    String priority = 'medium';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF191433),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('افزودن کار جدید', style: TextStyle(color: Colors.white, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'عنوان وظیفه',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF221C42),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('اولویت:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPriorityChoice('فوری', 'high', priority, const Color(0xFFFF5252), (p) => setDialogState(() => priority = p)),
                      _buildPriorityChoice('متوسط', 'medium', priority, const Color(0xFFFFB300), (p) => setDialogState(() => priority = p)),
                      _buildPriorityChoice('عادی', 'low', priority, const Color(0xFF00E676), (p) => setDialogState(() => priority = p)),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('انصراف', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D2FF)),
                  onPressed: () async {
                    final text = titleController.text.trim();
                    if (text.isEmpty) return;
                    final item = TaskItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: text,
                      priority: priority,
                      isDone: false,
                    );
                    setState(() {
                      _tasks.add(item);
                    });
                    await StorageService.saveTasks(_tasks);
                    if (mounted) Navigator.pop(ctx);
                  },
                  child: const Text('ثبت', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPriorityChoice(String title, String val, String current, Color color, Function(String) onSelect) {
    final isSelected = current == val;
    return GestureDetector(
      onTap: () => onSelect(val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : const Color(0xFF221C42),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Text(
          title,
          style: TextStyle(color: isSelected ? color : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
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
        title: const Text('ردیاب عادت‌ها و چک‌لیست روزانه', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF9D50BB),
          labelColor: const Color(0xFF00D2FF),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'عادت‌های روزانه'),
            Tab(text: 'چک‌لیست کارها'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9D50BB),
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddHabitDialog();
          } else {
            _showAddTaskDialog();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHabitsTab(),
          _buildTasksTab(),
        ],
      ),
    );
  }

  Widget _buildHabitsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _habits.length,
      itemBuilder: (context, index) {
        final habit = _habits[index];
        final isDone = habit.isCompletedToday();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF191433),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDone ? const Color(0xFF00E676).withOpacity(0.4) : Colors.white.withOpacity(0.06),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDone ? const Color(0xFF00E676).withOpacity(0.2) : const Color(0xFF221C42),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: isDone ? const Color(0xFF00E676) : const Color(0xFFFFD700),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('زنجیره تداوم: ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          Text(
                            '🔥 ${habit.streak} روز',
                            style: const TextStyle(color: Color(0xFFFF9100), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isDone ? const Color(0xFF00E676) : Colors.grey,
                  size: 28,
                ),
                onPressed: () async {
                  setState(() {
                    habit.toggleToday();
                  });
                  await StorageService.saveHabits(_habits);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTasksTab() {
    final completedCount = _tasks.where((e) => e.isDone).length;
    final total = _tasks.length;
    final progress = total > 0 ? (completedCount / total) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ویجت پیشرفت کارها
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF191433),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF00D2FF).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('پیشرفت کارهای امروز', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('$completedCount از $total کار انجام شد', style: const TextStyle(color: Color(0xFF00D2FF), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: const Color(0xFF221C42),
                  color: const Color(0xFF00D2FF),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              Color pColor = const Color(0xFF00E676);
              String pText = 'عادی';
              if (task.priority == 'high') {
                pColor = const Color(0xFFFF5252);
                pText = 'فوری';
              } else if (task.priority == 'medium') {
                pColor = const Color(0xFFFFB300);
                pText = 'متوسط';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF191433),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: task.isDone,
                      activeColor: const Color(0xFF00E676),
                      onChanged: (val) async {
                        setState(() {
                          task.isDone = val ?? false;
                        });
                        await StorageService.saveTasks(_tasks);
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          color: task.isDone ? Colors.grey : Colors.white,
                          decoration: task.isDone ? TextDecoration.lineThrough : null,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: pColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(pText, style: TextStyle(color: pColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                      onPressed: () async {
                        setState(() {
                          _tasks.removeAt(index);
                        });
                        await StorageService.saveTasks(_tasks);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
