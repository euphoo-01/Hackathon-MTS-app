import 'package:hive_flutter/hive_flutter.dart';
import 'package:healarm/models/user_model.dart';
import 'package:healarm/models/device_model.dart';

class HiveInit {
  static Future<Box<UserModel>> initAuthBox() async {
    // Инициализация Hive
    await Hive.initFlutter();
    
    // Регистрация адаптеров
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(DeviceModelAdapter());
    Hive.registerAdapter(DeviceStatusAdapter());
    Hive.registerAdapter(DeviceSettingsAdapter());
    Hive.registerAdapter(DeviceReadingAdapter());
    
    // Открытие Box для хранения пользователей
    return await Hive.openBox<UserModel>('auth_users');
  }
} 