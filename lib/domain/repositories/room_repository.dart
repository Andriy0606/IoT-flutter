import 'package:my_project/domain/models/room_snapshot.dart';

abstract interface class RoomRepository {
  Future<List<RoomSnapshot>> fetchRooms();
}
