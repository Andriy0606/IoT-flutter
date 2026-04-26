import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/data/local/room_local_data_source.dart';
import 'package:my_project/domain/models/room_snapshot.dart';
import 'package:my_project/domain/repositories/room_repository.dart';
import 'package:my_project/state/rooms/rooms_state.dart';

final class RoomsCubit extends Cubit<RoomsState> {
  RoomsCubit({
    required RoomRepository repository,
    required RoomLocalDataSource local,
  }) : _repository = repository,
       _local = local,
       super(const RoomsLoading(selectedIndex: 0));

  final RoomRepository _repository;
  final RoomLocalDataSource _local;

  Future<void> load() async {
    final index = _selectedIndex(state);
    emit(RoomsLoading(selectedIndex: index));
    try {
      final rooms = await _repository.fetchRooms();
      emit(RoomsLoaded(rooms: rooms, selectedIndex: _clampIndex(index, rooms)));
    } catch (e) {
      final cached = await _local.readRooms();
      emit(
        RoomsError(
          message: e.toString(),
          selectedIndex: _clampIndex(index, cached),
          cachedRooms: cached,
        ),
      );
    }
  }

  void selectPrev() {
    final rooms = _rooms(state);
    final index = _selectedIndex(state);
    final next = (index - 1).clamp(0, (rooms.length - 1).clamp(0, 1 << 30));
    _emitWithIndex(state, next);
  }

  void selectNext() {
    final rooms = _rooms(state);
    final index = _selectedIndex(state);
    final max = (rooms.length - 1).clamp(0, 1 << 30);
    final next = (index + 1).clamp(0, max);
    _emitWithIndex(state, next);
  }

  Future<void> createRoom(RoomSnapshot room) async {
    final rooms = List<RoomSnapshot>.of(_rooms(state))..add(room);
    await _local.saveRooms(rooms);
    _emitRooms(state, rooms);
  }

  Future<void> updateRoom(RoomSnapshot room) async {
    final rooms = List<RoomSnapshot>.of(_rooms(state));
    final idx = rooms.indexWhere((r) => r.id == room.id);
    if (idx < 0) return;
    rooms[idx] = room;
    await _local.saveRooms(rooms);
    _emitRooms(state, rooms);
  }

  Future<void> deleteRoom(int id) async {
    final rooms = List<RoomSnapshot>.of(_rooms(state))
      ..removeWhere((r) => r.id == id);
    await _local.saveRooms(rooms);
    _emitRooms(state, rooms);
  }

  int _selectedIndex(RoomsState s) => switch (s) {
    RoomsLoading(:final selectedIndex) => selectedIndex,
    RoomsLoaded(:final selectedIndex) => selectedIndex,
    RoomsError(:final selectedIndex) => selectedIndex,
  };

  List<RoomSnapshot> _rooms(RoomsState s) => switch (s) {
    RoomsLoaded(:final rooms) => rooms,
    RoomsError(:final cachedRooms) => cachedRooms,
    _ => const <RoomSnapshot>[],
  };

  int _clampIndex(int index, List<RoomSnapshot> rooms) {
    if (rooms.isEmpty) return 0;
    final max = rooms.length - 1;
    return index.clamp(0, max);
  }

  void _emitWithIndex(RoomsState prev, int index) {
    final rooms = _rooms(prev);
    _emitRooms(prev, rooms, selectedIndex: _clampIndex(index, rooms));
  }

  void _emitRooms(
    RoomsState prev,
    List<RoomSnapshot> rooms, {
    int? selectedIndex,
  }) {
    final idx = selectedIndex ?? _clampIndex(_selectedIndex(prev), rooms);
    emit(RoomsLoaded(rooms: rooms, selectedIndex: idx));
  }
}
