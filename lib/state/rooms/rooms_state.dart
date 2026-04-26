import 'package:my_project/domain/models/room_snapshot.dart';

sealed class RoomsState {
  const RoomsState();
}

final class RoomsLoading extends RoomsState {
  const RoomsLoading({required this.selectedIndex});
  final int selectedIndex;
}

final class RoomsLoaded extends RoomsState {
  const RoomsLoaded({required this.rooms, required this.selectedIndex});
  final List<RoomSnapshot> rooms;
  final int selectedIndex;
}

final class RoomsError extends RoomsState {
  const RoomsError({
    required this.message,
    required this.selectedIndex,
    required this.cachedRooms,
  });

  final String message;
  final int selectedIndex;
  final List<RoomSnapshot> cachedRooms;
}
