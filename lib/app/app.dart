import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/app/app_routes.dart';
import 'package:my_project/app/di.dart';
import 'package:my_project/screens/home/home_screen.dart';
import 'package:my_project/screens/login/login_screen.dart';
import 'package:my_project/screens/profile/profile_screen.dart';
import 'package:my_project/screens/register/register_screen.dart';
import 'package:my_project/screens/splash/splash_screen.dart';
import 'package:my_project/state/auth/auth_cubit.dart';
import 'package:my_project/state/mqtt/mqtt_cubit.dart';
import 'package:my_project/state/rooms/rooms_cubit.dart';
import 'package:my_project/state/user/user_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RoomsCubit>(
          create: (_) => RoomsCubit(
            repository: AppDi.roomRepository,
            local: AppDi.roomLocalDataSource,
          )..load(),
        ),
        BlocProvider<MqttCubit>(
          create: (_) => MqttCubit(
            connectivity: AppDi.connectivityService,
            mqtt: AppDi.mqttTemperatureService,
          )..init(),
        ),
        BlocProvider<UserCubit>(
          create: (_) => UserCubit(
            userRepository: AppDi.userRepository,
            validators: AppDi.validators,
            sessionStorage: AppDi.sessionStorage,
          )..loadUser(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authService: AppDi.authService),
        ),
      ],
      child: MaterialApp(
        title: 'Room State',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.splash,
        routes: <String, WidgetBuilder>{
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
        },
      ),
    );
  }
}
