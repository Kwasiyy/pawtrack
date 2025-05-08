import "reminder.dart";


class Pet {
  final String? id;
  final String userId;
  final String name;
  final String? breed;
  final int? age;
  final String? photoUrl;
  final DateTime? createdAt;
  final String gender;
  final bool isSterilized;
  final String petType;
  final double? weight;
  final List<Reminder>? reminders;

  Pet({
    this.id,
    required this.userId,
    required this.name,
    this.breed,
    this.age,
    this.photoUrl,
    this.createdAt,
    required this.gender,
    required this.isSterilized,
    required this.petType,
    this.weight,
    this.reminders,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id']?.toString(),
      userId: json['user_id'].toString(),
      name: json['name'],
      breed: json['breed'],
      age: json['age'],
      photoUrl: json['photo_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      gender: json['gender'] ?? 'Unknown',
      isSterilized: json['is_sterilized'] ?? false,
      petType: json['pet_type'] ?? 'Unknown',
      weight: json['weight']?.toDouble(),
      reminders: (json['reminders'] as List<dynamic>?)
          ?.map((e) => Reminder.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'breed': breed,
      'age': age,
      'photo_url': photoUrl,
      'created_at': createdAt?.toIso8601String(),
      'gender': gender,
      'is_sterilized': isSterilized,
      'pet_type': petType,
      'weight': weight,
      'reminders': reminders?.map((e) => e.toJson()).toList(),
    };
  }

  List<Reminder> getUpcomingAppointments() {
    if (reminders == null) return [];
    final now = DateTime.now();
    return reminders!
        .where((r) => !r.isCompleted && r.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
