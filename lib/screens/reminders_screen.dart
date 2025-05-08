// lib/screens/reminders_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = ReminderService.instance;
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: ReminderType.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _showAddReminderDialog(ReminderType type) async {
    _titleCtrl.clear();
    _notesCtrl.clear();
    _selectedDate = null;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add ${type.toString().split('.').last} Reminder'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Select Date'
                    : 'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleCtrl.text.isNotEmpty && _selectedDate != null) {
                final newRem = Reminder(
                  id: DateTime.now().millisecondsSinceEpoch,
                  petId: 1, // TODO: Wire up real petId
                  title: _titleCtrl.text,
                  notes: _notesCtrl.text,
                  date: _selectedDate!,
                  type: type,
                );
                _service.add(newRem);
                setState(() {}); // refresh lists
                Navigator.pop(context);
              } else {
                // show an alert if missing title or date
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Missing Fields'),
                    content: const Text('Title and Date are required.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      )
                    ],
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderList(ReminderType type) {
    final all = _service.getAll()
      .where((r) => r.type == type)
      .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

    if (all.isEmpty) {
      return const Center(child: Text('No reminders yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: all.length,
      itemBuilder: (ctx, i) {
        final r = all[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(r.title),
            subtitle: Text(
              '${r.notes}\nDate: ${DateFormat('MMM dd, yyyy').format(r.date)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            isThreeLine: true,
            trailing: Checkbox(
              value: r.isCompleted,
              onChanged: (_) {
                _service.toggleCompleted(r.id);
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ReminderType.values
        .map((e) => Tab(text: e.toString().split('.').last))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Care Reminders'),
        bottom: TabBar(controller: _tabController, isScrollable: true, tabs: tabs),
      ),
      body: TabBarView(
        controller: _tabController,
        children: ReminderType.values
            .map((type) => Stack(
                  children: [
                    _buildReminderList(type),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: () => _showAddReminderDialog(type),
                        child: const Icon(Icons.add),
                      ),
                    )
                  ],
                ))
            .toList(),
      ),
    );
  }
}
