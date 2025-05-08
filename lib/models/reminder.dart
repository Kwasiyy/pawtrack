// lib/models/reminder.dart

enum ReminderType {
  vaccination,
  grooming,
  dentalCare,
  exercise,
  healthCheck,
}

class Reminder {
  final int id;
  final int petId;
  final String title;
  final String notes;
  final DateTime date;
  final ReminderType type;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.petId,
    required this.title,
    required this.notes,
    required this.date,
    required this.type,
    this.isCompleted = false,
  });

  /// Convert a Reminder instance to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'pet_id': petId,
    'title': title,
    'notes': notes,
    'date': date.toIso8601String(),
    'type': type.toString().split('.').last,
    'is_completed': isCompleted ? 1 : 0,
  };

  /// Construct a Reminder from JSON map
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as int,
      petId: json['pet_id'] as int,
      title: json['title'] as String,
      notes: json['notes'] as String,
      date: DateTime.parse(json['date'] as String),
      type: ReminderType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] as String),
        orElse: () => ReminderType.vaccination,
      ),
      isCompleted: (json['is_completed'] == 1 || json['is_completed'] == true),
    );
  }
}
