import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:healarm/controllers/auth_controller.dart';
import 'package:healarm/controllers/device_controller.dart';
import 'package:healarm/models/device_model.dart';
import 'package:healarm/models/user_model.dart';
import 'package:healarm/screens/add_device_screen.dart';
import 'package:healarm/screens/device_detail_screen.dart';
import 'package:healarm/screens/device_settings_screen.dart';
import 'package:healarm/screens/device_stats_screen.dart';
import 'package:healarm/screens/home_screen.dart';
import 'package:healarm/screens/login_screen.dart';
import 'package:healarm/screens/main_screen.dart';
import 'package:healarm/screens/profile_screen.dart';
import 'package:healarm/screens/register_screen.dart';
import 'package:healarm/screens/splash_screen.dart';
import 'package:healarm/screens/statistics_screen.dart';
import 'package:healarm/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Установка ориентации устройства
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => DeviceController()),
      ],
      child: MaterialApp(
        title: 'Healarm',
        theme: AppTheme.getTheme(),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/addDevice': (context) => const AddDeviceScreen(),
          '/statistics': (context) => const StatisticsScreen(),
          '/home': (context) => const MainScreen(),
          '/main': (context) => const MainScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/deviceDetail') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => DeviceDetailScreen(
                deviceId: args['deviceId'],
              ),
            );
          } else if (settings.name == '/deviceSettings') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => DeviceSettingsScreen(
                deviceId: args['deviceId'],
                initialSettings: args['settings'],
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
