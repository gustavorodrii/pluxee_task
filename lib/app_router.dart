import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'data/datasources/repositories/task_repository_impl.dart';
import 'data/datasources/task_remote_datasource.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/bloc/auth_state.dart';
import 'presentation/auth/pages/login_page.dart';
import 'presentation/auth/pages/register_page.dart';
import 'presentation/tasks/bloc/task_bloc.dart';
import 'presentation/tasks/pages/dashboard_page.dart';
import 'presentation/tasks/pages/task_detail_page.dart';
import 'presentation/tasks/pages/task_form_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Use uma key própria do GoRouter (não leia currentContext na inicialização)
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(BuildContext context) {
  final authBloc = context.read<AuthBloc>();

  return GoRouter(
    initialLocation: '/login',
    navigatorKey: rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (ctx, state) {
      final authState = authBloc.state;
      final loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (authState.status == AuthStatus.authenticated && loggingIn) {
        return '/dashboard';
      }
      if (authState.status != AuthStatus.authenticated && !loggingIn) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      // Shell que compartilha o mesmo Bloc entre dashboard e filhas
      ShellRoute(
        builder: (context, state, child) {
          final ds = TaskRemoteDataSourceImpl(useMock: true);
          final repo = TaskRepositoryImpl(ds);
          return BlocProvider<TaskBloc>(
            create: (_) => TaskBloc(repo)..add(TasksRequested()),
            child: child,
          );
        },
        routes: [
          // Página principal
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
            routes: [
              GoRoute(
                path: 'task/new',
                builder: (context, state) => const TaskFormPage(),
              ),
              GoRoute(
                path: 'task/:id',
                builder: (context, state) =>
                    TaskDetailPage(taskId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'task/:id/edit',
                builder: (context, state) =>
                    TaskFormPage(taskId: state.pathParameters['id']!),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
