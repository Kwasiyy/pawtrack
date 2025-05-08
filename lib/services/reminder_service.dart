// lib/services/reminder_service.dart

import '../models/reminder.dart';

/// Singleton service to store and manage reminders in-memory
class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final List<Reminder> _reminders = [];

  /// Returns all reminders (unmodifiable)
  List<Reminder> getAll() => List.unmodifiable(_reminders);

  /// Adds a new reminder
  void add(Reminder reminder) {
    _reminders.add(reminder);
  }

  /// Toggles the completion status of a reminder by [id]
  void toggleCompleted(int id) {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final old = _reminders[idx];
      _reminders[idx] = Reminder(
        id: old.id,
        petId: old.petId,
        title: old.title,
        notes: old.notes,
        date: old.date,
        type: old.type,
        isCompleted: !old.isCompleted,
      );
    }
  }
}



