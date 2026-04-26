import 'dart:convert';

final class RoomSnapshot {
  const RoomSnapshot({
    required this.id,
    required this.name,
    required this.temperatureC,
    required this.humidityPercent,
    required this.isLightOn,
  });

  final int id;
  final String name;
  final int temperatureC;
  final int humidityPercent;
  final bool isLightOn;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'temperatureC': temperatureC,
    'humidityPercent': humidityPercent,
    'isLightOn': isLightOn,
  };

  static RoomSnapshot fromJson(Map<String, Object?> json) {
    return RoomSnapshot(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      temperatureC: (json['temperatureC'] as int?) ?? 0,
      humidityPercent: (json['humidityPercent'] as int?) ?? 0,
      isLightOn: (json['isLightOn'] as bool?) ?? false,
    );
  }

  static List<RoomSnapshot> listFromStorageString(String? value) {
    if (value == null || value.isEmpty) return <RoomSnapshot>[];
    final dynamic decoded = jsonDecode(value);
    if (decoded is! List<dynamic>) return <RoomSnapshot>[];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((e) => RoomSnapshot.fromJson(e.cast<String, Object?>()))
        .toList(growable: false);
  }

  static String listToStorageString(List<RoomSnapshot> rooms) {
    return jsonEncode(rooms.map((e) => e.toJson()).toList(growable: false));
  }
}
