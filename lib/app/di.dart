import 'package:my_project/app/session_storage.dart';
import 'package:my_project/data/local/room_local_data_source.dart';
import 'package:my_project/data/local/shared_prefs_storage.dart';
import 'package:my_project/data/local/user_local_data_source.dart';
import 'package:my_project/data/remote/api_client.dart';
import 'package:my_project/data/remote/room_remote_data_source.dart';
import 'package:my_project/data/repositories/room_repository_impl.dart';
import 'package:my_project/data/repositories/user_repository_impl.dart';
import 'package:my_project/domain/repositories/room_repository.dart';
import 'package:my_project/domain/repositories/user_repository.dart';
import 'package:my_project/domain/services/auth_service.dart';
import 'package:my_project/domain/services/connectivity_service.dart';
import 'package:my_project/domain/services/mqtt_temperature_service.dart';
import 'package:my_project/domain/validation/validators.dart';

// py tools\mqtt_publisher.py --host test.mosquitto.org --port 1883 --topic sensor/temperature

final class AppDi {
  AppDi._();

  static const SharedPrefsStorage _storage = SharedPrefsStorage();

  static const AuthValidators validators = AuthValidators();

  static const SessionStorage sessionStorage = SessionStorageImpl(
    storage: _storage,
  );

  static const UserLocalDataSource _userLocal = UserLocalDataSourceImpl(
    storage: _storage,
  );

  static const UserRepository userRepository = UserRepositoryImpl(
    local: _userLocal,
  );

  static const AuthService authService = AuthServiceImpl(
    validators: validators,
    userRepository: userRepository,
    sessionStorage: sessionStorage,
  );

  static final ConnectivityService connectivityService =
      ConnectivityServiceImpl();

  static final SwitchableMqttTemperatureService mqttTemperatureService =
      SwitchableMqttTemperatureServiceImpl(
        storage: _storage,
        clientIdPrefix: 'flutter_room_state_client',
        topic: 'sensor/temperature',
      );

  static final ApiClient _apiClient = ApiClient();

  static const RoomLocalDataSource _roomLocal = RoomLocalDataSourceImpl(
    storage: _storage,
  );

  static final RoomRemoteDataSource _roomRemote = RoomRemoteDataSourceImpl(
    apiClient: _apiClient,
  );

  static final RoomRepository roomRepository = RoomRepositoryImpl(
    remote: _roomRemote,
    local: _roomLocal,
  );

  static RoomLocalDataSource get roomLocalDataSource => _roomLocal;
}
