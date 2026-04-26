import 'package:my_project/data/local/room_local_data_source.dart';
import 'package:my_project/data/remote/room_remote_data_source.dart';
import 'package:my_project/domain/models/room_snapshot.dart';
import 'package:my_project/domain/repositories/room_repository.dart';

final class RoomRepositoryImpl implements RoomRepository {
  const RoomRepositoryImpl({
    required RoomRemoteDataSource remote,
    required RoomLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  final RoomRemoteDataSource _remote;
  final RoomLocalDataSource _local;

  @override
  Future<List<RoomSnapshot>> fetchRooms() async {
    try {
      final rooms = await _remote.fetchRooms();
      await _local.saveRooms(rooms);
      return rooms;
    } catch (_) {
      final cached = await _local.readRooms();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }
}
