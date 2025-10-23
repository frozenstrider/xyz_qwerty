import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/purchases/presentation/purchases_screen.dart';
import '../features/title/presentation/title_detail_screen.dart';
import '../features/reader/presentation/reader_screen.dart';
import '../features/login/presentation/login_screen.dart';
import '../features/shared/widgets/main_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey(debugLabel: 'rootNavigator');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey(debugLabel: 'shellNavigator');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(state: state, child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            pageBuilder: (context, state) => const NoTransitionPage(child: SearchScreen()),
          ),
          GoRoute(
            path: '/library',
            name: 'library',
            pageBuilder: (context, state) => const NoTransitionPage(child: LibraryScreen()),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/title/:id',
        name: 'title-detail',
        builder: (context, state) => TitleDetailScreen(titleId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reader/:chapterId',
        name: 'reader',
        builder: (context, state) => ReaderScreen(chapterId: state.pathParameters['chapterId'] ?? ''),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/purchases',
        name: 'purchases',
        builder: (context, state) => const PurchasesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
});
