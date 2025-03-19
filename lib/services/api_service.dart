import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:healarm/models/device_model.dart';
import 'package:healarm/models/user_model.dart';

class ApiService {
  // Базовый URL API (для демонстрации)
  final String _baseUrl = 'https://api.example.com'; 
  
  // Имитация задержки сети
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }
  
  // Аутентификация
  Future<UserModel> login(String email, String password) async {
    await _simulateNetworkDelay();
    
    // Заглушка для демонстрации
    return UserModel(
      id: '1',
      email: email,
      username: 'Пользователь',
      isVerified: true,
    );
  }
  
  // Регистрация пользователя
  Future<UserModel> register(String username, String email, String password) async {
    await _simulateNetworkDelay();
    
    // Заглушка для демонстрации
    return UserModel(
      id: '1',
      email: email,
      username: username,
      isVerified: false,
    );
  }
  
  // Обновление профиля пользователя
  Future<UserModel> updateUserProfile(UserModel user) async {
    await _simulateNetworkDelay();
    
    // Заглушка для демонстрации, возвращаем те же данные
    return user;
  }
  
  // Получение всех устройств пользователя
  Future<List<DeviceModel>> getUserDevices(String userId) async {
    await _simulateNetworkDelay();
    
    // Заглушка для демонстрации
    final devices = <DeviceModel>[];
    
    // Генерируем одно демонстрационное устройство
    devices.add(
      DeviceModel(
        id: 'device_1',
        userId: userId,
        name: 'Мое устройство',
        deviceCode: 'TEST123',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastActive: DateTime.now(),
        settings: DeviceSettings(),
        status: DeviceStatus.normal,
        readings: [],
      ),
    );
    
    return devices;
  }
  
  // Добавление нового устройства
  Future<DeviceModel> addDevice(String userId, String deviceCode, String deviceName) async {
    await _simulateNetworkDelay();
    
    // Заглушка для демонстрации
    return DeviceModel(
      id: 'device_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      name: deviceName,
      deviceCode: deviceCode,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
      settings: DeviceSettings(),
      status: DeviceStatus.normal,
      readings: [],
    );
  }
  
  // Получение детальной информации об устройстве
  Future<DeviceModel> getDeviceDetails(String deviceId) async {
    await _simulateNetworkDelay();
    
    // Заглушка для демонстрации
    return DeviceModel(
      id: deviceId,
      userId: 'user_1',
      name: 'Мое устройство',
      deviceCode: 'TEST123',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastActive: DateTime.now(),
      settings: DeviceSettings(),
      status: DeviceStatus.normal,
      readings: [],
    );
  }
  
  // Обновление настроек устройства
  Future<void> updateDeviceSettings(String deviceId, DeviceSettings settings) async {
    await _simulateNetworkDelay();
    
    // Заглушка для демонстрации, просто ожидаем
    return;
  }
  
  // Удаление устройства
  Future<void> removeDevice(String deviceId) async {
    await _simulateNetworkDelay();
    
    // Заглушка для демонстрации, просто ожидаем
    return;
  }
  
  // Получение показаний устройства за период
  Future<List<DeviceReading>> getDeviceReadings(
    String deviceId, 
    DateTime startDate, 
    DateTime endDate,
  ) async {
    await _simulateNetworkDelay();
    
    // Заглушка для демонстрации
    final readings = <DeviceReading>[];
    final now = DateTime.now();
    
    // Генерируем случайные показания
    for (int i = 0; i < 20; i++) {
      final timestamp = now.subtract(Duration(hours: i * 3));
      if (timestamp.isBefore(startDate)) continue;
      if (timestamp.isAfter(endDate)) continue;
      
      readings.add(
        DeviceReading(
          id: 'reading_$i',
          deviceId: deviceId,
          timestamp: timestamp,
          pulseRate: 65 + (i % 15),
          systolicPressure: 120 + (i % 10),
          diastolicPressure: 80 + (i % 5),
          bodyAngle: 10 + (i % 20),
          isAnomaly: i % 10 == 0, // Каждое десятое показание - аномальное
        ),
      );
    }
    
    return readings;
  }
} 