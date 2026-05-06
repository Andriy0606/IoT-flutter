import 'package:my_project/data/remote/api_client.dart';
import 'package:my_project/domain/models/room_snapshot.dart';

abstract interface class RoomRemoteDataSource {
  Future<List<RoomSnapshot>> fetchRooms();
}

/// Minimal mock-backed API: uses JSONPlaceholder users as room names.
/// Keeps the app "thematic" (rooms) while avoiding custom backend setup.
final class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  const RoomRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  static final Uri _endpoint = Uri.parse(
    'https://jsonplaceholder.typicode.com/users',
  );

  @override
  Future<List<RoomSnapshot>> fetchRooms() async {
    final list = await _apiClient.getJsonList(_endpoint);

    final rooms = <RoomSnapshot>[];
    for (final item in list) {
      if (item is! Map<String, dynamic>) continue;
      final map = item.cast<String, Object?>();

      final id = (map['id'] as int?) ?? 0;
      final name = (map['name'] as String?) ?? 'Room $id';

      // Deterministic mock sensor values from id.
      final temperatureC = 18 + (id % 8);
      final humidityPercent = 35 + (id % 30);
      final isLightOn = id.isEven;

      rooms.add(
        RoomSnapshot(
          id: id,
          name: name,
          temperatureC: temperatureC,
          humidityPercent: humidityPercent,
          isLightOn: isLightOn,
        ),
      );
    }

    return rooms;
  }
}
