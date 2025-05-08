// lib/models/walk.dart

class Walk {
  /// If null, this is a new walk that hasn't been saved to the server yet.
  final String? id;
  final String petId;
  final double distance;
  final int durationSeconds;
  final List<WalkCoordinate> coordinates;
  final DateTime startTime;
  final DateTime endTime;

  Walk({
    this.id,
    required this.petId,
    required this.distance,
    required this.durationSeconds,
    required this.coordinates,
    required this.startTime,
    required this.endTime,
  });

  /// Factory to parse a walk returned by the server (includes `id`).
  factory Walk.fromJson(Map<String, dynamic> json) {
    return Walk(
      id: json['id'] as String?,
      petId: json['pet_id'] as String,
      distance: (json['distance'] as num).toDouble(),
      durationSeconds: json['duration_seconds'] as int,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((coord) => WalkCoordinate.fromJson(coord as Map<String, dynamic>))
          .toList(),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
    );
  }

  /// Convert to JSON for sending to server when creating a new walk.
  /// Note: `id` is omitted, since the server will assign it.
  Map<String, dynamic> toJsonForCreate() {
    return {
      'pet_id': petId,
      'distance': distance,
      'duration_seconds': durationSeconds,
      'coordinates': coordinates.map((c) => c.toJson()).toList(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    };
  }

  /// Full JSON representation, including `id`, if needed.
  Map<String, dynamic> toJson() {
    final data = toJsonForCreate();
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}

class WalkCoordinate {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  WalkCoordinate({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory WalkCoordinate.fromJson(Map<String, dynamic> json) {
    return WalkCoordinate(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
