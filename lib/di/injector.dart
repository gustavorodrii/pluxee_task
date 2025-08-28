import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../config.dart';
import '../core/storage/secure_storage.dart';
import '../data/datasources/api/auth_api.dart';
import '../data/datasources/api/mock_api.dart';
import '../data/datasources/task_remote_datasource.dart';
import '../data/datasources/repositories/auth_repository_impl.dart';
import '../data/datasources/repositories/task_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/task_repository.dart';
import '../presentation/auth/bloc/auth_bloc.dart';
import '../presentation/tasks/bloc/task_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage());

  sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(baseUrl: kBaseUrl)));

  if (kUseMockApi) {
    final mock = MockApi();
    sl.registerLazySingleton<AuthApi>(() => mock);
  } else {
    sl.registerLazySingleton<AuthApi>(() => AuthApi(sl(), sl()));
  }

  sl.registerLazySingleton<TaskRemoteDataSource>(() => TaskRemoteDataSourceImpl(
        useMock: kUseMockApi,
      ));

  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));

  sl.registerFactory<AuthBloc>(() => AuthBloc());
  sl.registerFactory<TaskBloc>(() => TaskBloc(sl()));
}
