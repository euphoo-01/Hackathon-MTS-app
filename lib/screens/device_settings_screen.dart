import 'package:flutter/material.dart';
import 'package:healarm/controllers/device_controller.dart';
import 'package:healarm/models/device_model.dart';
import 'package:healarm/theme/app_theme.dart';
import 'package:healarm/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DeviceSettingsScreen extends StatefulWidget {
  final String deviceId;
  final DeviceSettings initialSettings;

  const DeviceSettingsScreen({
    super.key,
    required this.deviceId,
    required this.initialSettings,
  });

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  late bool _isPulseTrackingEnabled;
  late bool _isPressureTrackingEnabled;
  late bool _isPositionTrackingEnabled;
  late int _measurementInterval;

  final List<int> _intervalOptions = [15, 30, 60, 120, 180, 360, 720];

  @override
  void initState() {
    super.initState();
    _isPulseTrackingEnabled = widget.initialSettings.isPulseTrackingEnabled;
    _isPressureTrackingEnabled = widget.initialSettings.isPressureTrackingEnabled;
    _isPositionTrackingEnabled = widget.initialSettings.isPositionTrackingEnabled;
    _measurementInterval = widget.initialSettings.measurementIntervalMinutes;
  }

  Future<void> _saveSettings() async {
    final deviceController = Provider.of<DeviceController>(context, listen: false);
    
    final settings = DeviceSettings(
      isPulseTrackingEnabled: _isPulseTrackingEnabled,
      isPressureTrackingEnabled: _isPressureTrackingEnabled,
      isPositionTrackingEnabled: _isPositionTrackingEnabled,
      measurementIntervalMinutes: _measurementInterval,
    );
    
    final success = await deviceController.updateDeviceSettings(
      widget.deviceId,
      settings,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Настройки успешно сохранены'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceController = Provider.of<DeviceController>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLightColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Настройки устройства',
          style: AppTheme.subheadingStyle.copyWith(fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: Stack(
        children: [
          // Декоративные элементы фона
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor.withOpacity(0.1),
              ),
            ),
          ),
          
          // Основное содержимое
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Параметры отслеживания',
                  style: AppTheme.subheadingStyle,
                ).animate().fade(duration: 400.ms),
                
                const SizedBox(height: 8),
                
                Text(
                  'Настройте, какие параметры будет отслеживать устройство',
                  style: AppTheme.captionStyle,
                ).animate().fade(delay: 200.ms, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                // Карточка настроек отслеживания
                GlassCard(
                  hasShadow: true,
                  child: Column(
                    children: [
                      // Отслеживание пульса
                      SwitchListTile(
                        title: const Text('Отслеживание пульса'),
                        subtitle: const Text(
                          'Устройство будет измерять частоту сердечных сокращений',
                        ),
                        value: _isPulseTrackingEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isPulseTrackingEnabled = value;
                          });
                        },
                        secondary: const Icon(
                          Icons.favorite_outline,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      
                      const Divider(),
                      
                      // Отслеживание давления
                      SwitchListTile(
                        title: const Text('Отслеживание давления'),
                        subtitle: const Text(
                          'Устройство будет измерять артериальное давление',
                        ),
                        value: _isPressureTrackingEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isPressureTrackingEnabled = value;
                          });
                        },
                        secondary: const Icon(
                          Icons.speed_outlined,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      
                      const Divider(),
                      
                      // Отслеживание положения
                      SwitchListTile(
                        title: const Text('Отслеживание положения'),
                        subtitle: const Text(
                          'Устройство будет отслеживать положение тела пользователя',
                        ),
                        value: _isPositionTrackingEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isPositionTrackingEnabled = value;
                          });
                        },
                        secondary: const Icon(
                          Icons.screen_rotation_outlined,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(delay: 300.ms, duration: 400.ms),
                
                const SizedBox(height: 24),
                
                Text(
                  'Интервал измерений',
                  style: AppTheme.subheadingStyle,
                ).animate().fade(delay: 400.ms, duration: 400.ms),
                
                const SizedBox(height: 8),
                
                Text(
                  'Как часто устройство будет снимать показания',
                  style: AppTheme.captionStyle,
                ).animate().fade(delay: 500.ms, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                // Карточка настроек интервала
                GlassCard(
                  hasShadow: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Частота измерений:'),
                            Text(
                              '$_measurementInterval мин',
                              style: AppTheme.bodyStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Слайдер интервала
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Slider(
                              value: _intervalOptions.indexOf(_measurementInterval).toDouble(),
                              min: 0,
                              max: (_intervalOptions.length - 1).toDouble(),
                              divisions: _intervalOptions.length - 1,
                              activeColor: AppTheme.primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _measurementInterval = _intervalOptions[value.toInt()];
                                });
                              },
                            ),
                            
                            // Метки слайдера
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: _intervalOptions.map((interval) {
                                return Text(
                                  interval.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: interval == _measurementInterval
                                        ? AppTheme.primaryColor
                                        : AppTheme.textLightColor,
                                    fontWeight: interval == _measurementInterval
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Информация о батарее
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.battery_charging_full_outlined,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Частые измерения повышают точность мониторинга, но сокращают срок службы батареи. '
                                'При интервале в 60 минут, батареи хватит примерно на 1 год работы.',
                                style: AppTheme.captionStyle.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(delay: 600.ms, duration: 400.ms),
                
                const SizedBox(height: 32),
                
                // Сообщение об ошибке
                if (deviceController.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      deviceController.error!,
                      style: const TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                // Кнопка сохранения
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: deviceController.isLoading ? null : _saveSettings,
                    icon: deviceController.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Сохранить настройки'),
                  ),
                ).animate().fade(delay: 700.ms, duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 