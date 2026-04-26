import 'package:my_project/data/local/key_value_storage.dart';
import 'package:my_project/domain/models/room_snapshot.dart';

abstract interface class RoomLocalDataSource {
  Future<List<RoomSnapshot>> readRooms();
  Future<void> saveRooms(List<RoomSnapshot> rooms);
  Future<void> deleteRooms();
}

final class RoomLocalDataSourceImpl implements RoomLocalDataSource {
  const RoomLocalDataSourceImpl({required KeyValueStorage storage})
    : _storage = storage;

  final KeyValueStorage _storage;

  static const String _kRooms = 'rooms_cache';

  @override
  Future<List<RoomSnapshot>> readRooms() async {
    final value = await _storage.readString(_kRooms);
    return RoomSnapshot.listFromStorageString(value);
  }

  @override
  Future<void> saveRooms(List<RoomSnapshot> rooms) async {
    await _storage.writeString(
      _kRooms,
      RoomSnapshot.listToStorageString(rooms),
    );
  }

  @override
  Future<void> deleteRooms() async {
    await _storage.remove(_kRooms);
  }
}
