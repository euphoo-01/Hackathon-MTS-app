import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healarm/models/device_model.dart';
import 'package:healarm/services/api_service.dart';
import 'package:healarm/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class DeviceController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<DeviceModel> _devices = [];
  DeviceModel? _selectedDevice;
  List<DeviceReading> _readings = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  List<DeviceModel> get devices => _devices;
  DeviceModel? get selectedDevice => _selectedDevice;
  List<DeviceReading> get readings => _readings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Геттер для совместимости со старым кодом
  DeviceModel? get currentDevice => _selectedDevice;

  // Установка текущего пользователя
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  // Загрузка устройств из локального хранилища
  Future<void> _loadDevicesFromStorage() async {
    try {
      if (_currentUserId == null) {
        throw Exception('Пользователь не авторизован');
      }

      final prefs = await SharedPreferences.getInstance();
      final devicesJson = prefs.getString('devices_$_currentUserId');

      if (devicesJson != null) {
        final List<dynamic> decoded = jsonDecode(devicesJson);
        _devices = decoded
            .map((item) => DeviceModel.fromJson(item))
            .where((device) => device.userId == _currentUserId)
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  // Сохранение устройств в локальное хранилище
  Future<void> _saveDevicesToStorage() async {
    try {
      if (_currentUserId == null) {
        throw Exception('Пользователь не авторизован');
      }

      final prefs = await SharedPreferences.getInstance();
      final devicesJson = jsonEncode(_devices.map((d) => d.toJson()).toList());
      await prefs.setString('devices_$_currentUserId', devicesJson);
    } catch (e) {
      _error = e.toString();
    }
  }

  // Инициализация демонстрационных данных
  Future<void> initDemoData() async {
    if (_currentUserId == null) {
      throw Exception('Пользователь не авторизован');
    }

    if (_devices.isEmpty) {
      // Создаем демонстрационное устройство с показаниями
      final List<DeviceReading> readings = [];
      final now = DateTime.now();

      // Генерируем данные за последние 30 дней
      for (int i = 0; i < 30; i++) {
        final timestamp = now.subtract(Duration(days: 30 - i, hours: i % 3));
        readings.add(
          DeviceReading(
            id: 'reading_$i',
            deviceId: 'device_1',
            timestamp: timestamp,
            pulseRate: 65 + (i % 15),
            systolicPressure: 120 + (i % 10),
            diastolicPressure: 80 + (i % 5),
            bodyAngle: 10 + (i % 20),
            isAnomaly: i % 10 == 0, // Каждое десятое показание - аномальное
          ),
        );
      }

      _devices.add(
        DeviceModel(
          id: 'device_1',
          userId: _currentUserId!,
          name: 'Мое устройство',
          deviceCode: 'TEST123',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          lastActive: DateTime.now(),
          settings: DeviceSettings(),
          status: DeviceStatus.normal,
          readings: readings,
        ),
      );

      await _saveDevicesToStorage();
    }
  }

  // Получение всех устройств пользователя
  Future<List<DeviceModel>> getAllDevices() async {
    if (_currentUserId == null) {
      throw Exception('Пользователь не авторизован');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadDevicesFromStorage();

      // Если нет устройств в хранилище, создаем демо-данные
      if (_devices.isEmpty) {
        await initDemoData();
      }

      _isLoading = false;
      notifyListeners();
      return _devices;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Метод для совместимости со старым кодом
  Future<void> loadUserDevices(String userId) async {
    setCurrentUser(userId);
    await getAllDevices();
  }

  // Получение устройства по ID
  Future<DeviceModel?> getDeviceById(String deviceId) async {
    if (_currentUserId == null) {
      throw Exception('Пользователь не авторизован');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await getAllDevices();

      final device = _devices.firstWhere(
        (d) => d.id == deviceId && d.userId == _currentUserId,
        orElse: () => throw Exception('Устройство не найдено'),
      );

      _selectedDevice = device;
      _isLoading = false;
      notifyListeners();
      return device;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Загрузка деталей устройства (для совместимости со старым кодом)
  Future<void> loadDeviceDetails(String deviceId) async {
    await getDeviceById(deviceId);
  }

  // Загрузка показаний устройства за сегодня (для совместимости со старым кодом)
  Future<void> loadTodayReadings(String deviceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await getDeviceById(deviceId);

      if (_selectedDevice != null && _selectedDevice!.readings != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        _readings = _selectedDevice!.readings!
            .where((r) => r.timestamp.isAfter(today))
            .toList();
      } else {
        _readings = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Загрузка показаний устройства за период (для совместимости со старым кодом)
  Future<void> loadDeviceReadings(
    String deviceId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await getDeviceById(deviceId);

      if (_selectedDevice != null && _selectedDevice!.readings != null) {
        _readings = _selectedDevice!.readings!
            .where((r) =>
                r.timestamp.isAfter(startDate) && r.timestamp.isBefore(endDate))
            .toList();
      } else {
        _readings = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Добавление нового устройства
  Future<bool> addDevice(String name, String deviceCode) async {
    if (_currentUserId == null) {
      throw Exception('Пользователь не авторизован');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Проверка, не существует ли уже устройство с таким кодом у текущего пользователя
      final existingDevice = _devices
          .any((d) => d.deviceCode == deviceCode && d.userId == _currentUserId);
      if (existingDevice) {
        throw Exception('Устройство с таким кодом уже существует');
      }

      // Создание нового устройства
      final newDevice = DeviceModel(
        id: 'device_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUserId!,
        name: name,
        deviceCode: deviceCode,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        settings: DeviceSettings(),
        status: DeviceStatus.normal,
        readings: [],
      );

      _devices.add(newDevice);
      await _saveDevicesToStorage();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Перегрузка метода для совместимости со старым кодом
  Future<bool> addDevice3(
      String userId, String deviceCode, String deviceName) async {
    return addDevice(deviceName, deviceCode);
  }

  // Установка текущего устройства (для совместимости со старым кодом)
  void setCurrentDevice(DeviceModel device) {
    _selectedDevice = device;
    notifyListeners();
  }

  // Обновление настроек устройства
  Future<bool> updateDeviceSettings(
      String deviceId, DeviceSettings settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final deviceIndex = _devices.indexWhere((d) => d.id == deviceId);
      if (deviceIndex == -1) {
        throw Exception('Устройство не найдено');
      }

      // Обновление устройства с новыми настройками
      final updatedDevice = _devices[deviceIndex].copyWith(settings: settings);
      _devices[deviceIndex] = updatedDevice;

      await _saveDevicesToStorage();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Удаление устройства
  Future<bool> removeDevice(String deviceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _devices.removeWhere((d) => d.id == deviceId);
      await _saveDevicesToStorage();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Очистка выбранного устройства
  void clearSelectedDevice() {
    _selectedDevice = null;
    notifyListeners();
  }
}
