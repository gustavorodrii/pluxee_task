import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_router.dart';
import 'core/theme/app_theme.dart';

import 'domain/repositories/task_repository.dart';
import 'data/datasources/task_remote_datasource.dart';
import 'data/datasources/repositories/task_repository_impl.dart';

import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/bloc/auth_event.dart';
import 'presentation/tasks/bloc/task_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<TaskRepository>(
      create: (_) {
        final ds = TaskRemoteDataSourceImpl(useMock: true);
        return TaskRepositoryImpl(ds);
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc()..add(AuthAppStarted()),
          ),
          BlocProvider<TaskBloc>(
            create: (ctx) =>
                TaskBloc(ctx.read<TaskRepository>())..add(TasksRequested()),
          ),
        ],
        child: Builder(
          builder: (context) {
            final router = buildRouter(context);
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
