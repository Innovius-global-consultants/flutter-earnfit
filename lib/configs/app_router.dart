import 'package:go_router/go_router.dart';

import '../screens/activity/activity_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/friends/friends_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/splash/splash_screen.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'home',
            builder: (context, state) => HomeScreen(),
          ),
          GoRoute(
            path: 'activity',
            builder: (context, state) => ActivityScreen(),
          ),
          GoRoute(
            path: 'friends',
            builder: (context, state) => FriendsScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
