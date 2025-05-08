class HealthRecord {
  final int? id;
  final int petId;
  final String type;
  final DateTime date;
  final String? notes;
  final DateTime? createdAt;

  HealthRecord({
    this.id,
    required this.petId,
    required this.type,
    required this.date,
    this.notes,
    this.createdAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      petId: json['pet_id'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'type': type,
      'date': date.toIso8601String().split('T')[0],
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
