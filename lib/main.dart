import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:satay_master_pro/providers/auth_provider.dart';
import 'package:satay_master_pro/screens/splash_screen.dart';

import 'firebase_options.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: SatayGoApp(),
    ),
  );
}

class SatayGoApp extends StatelessWidget {
  const SatayGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SatayGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          primary: Colors.deepOrange,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      ),
      home: const RoleGate(),
    );
  }
}

class RoleGate extends ConsumerWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const MainNavigationScreen();
        }

        final userProfile = ref.watch(userProfileProvider);
        return userProfile.when(
          data: (appUser) {
            if (appUser?.role == 'admin') {
              return const AdminDashboardScreen();
            }
            return const MainNavigationScreen();
          },
          loading: () => const SplashScreen(),
          error: (err, stack) => const Scaffold(
            body: Center(
              child: Text('Error loading user profile'),
            ),
          ),
        );
      },
      loading: () => const SplashScreen(),
      error: (err, stack) => const Scaffold(
        body: Center(
          child: Text('Something went wrong'),
        ),
      ),
    );
  }
}
