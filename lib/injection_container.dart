import 'package:get_it/get_it.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/send_otp.dart';
import 'features/auth/domain/usecases/verify_otp.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/users/data/repositories/user_repository_impl.dart';
import 'features/users/domain/repositories/user_repository.dart';
import 'features/users/domain/usecases/add_user.dart';
import 'features/users/domain/usecases/get_users.dart';
import 'features/users/presentation/bloc/users_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoC
  sl.registerFactory(() => AuthBloc(sendOtpUseCase: sl(), verifyOtpUseCase: sl()));
  sl.registerFactory(() => UsersBloc(getUsersUseCase: sl(), addUserUseCase: sl()));

  // Features - Auth
  sl.registerLazySingleton(() => SendOtp(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  // Features - Users
  sl.registerLazySingleton(() => GetUsers(sl()));
  sl.registerLazySingleton(() => AddUser(sl()));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());
}
