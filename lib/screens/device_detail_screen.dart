import 'package:flutter/material.dart';
import 'package:healarm/controllers/device_controller.dart';
import 'package:healarm/models/device_model.dart';
import 'package:healarm/screens/device_settings_screen.dart';
import 'package:healarm/screens/device_stats_screen.dart';
import 'package:healarm/theme/app_theme.dart';
import 'package:healarm/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

class DeviceDetailScreen extends StatefulWidget {
  final String deviceId;

  const DeviceDetailScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDeviceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDeviceData() {
    Future.microtask(() {
      final deviceController =
          Provider.of<DeviceController>(context, listen: false);
      deviceController.loadDeviceDetails(widget.deviceId);
      deviceController.loadTodayReadings(widget.deviceId);
    });
  }

  String _getStatusText(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.normal:
        return 'Нормальное';
      case DeviceStatus.warning:
        return 'Внимание';
      case DeviceStatus.critical:
        return 'Критическое';
      case DeviceStatus.offline:
        return 'Офлайн';
    }
  }

  Color _getStatusColor(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.normal:
        return AppTheme.successColor;
      case DeviceStatus.warning:
        return AppTheme.warningColor;
      case DeviceStatus.critical:
        return AppTheme.errorColor;
      case DeviceStatus.offline:
        return Colors.grey;
    }
  }

  // Показываем диалог подтверждения удаления устройства
  void _showDeleteConfirmationDialog(DeviceModel device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Удаление устройства',
          style: const TextStyle(
            fontFamily: 'Baloo2',
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Вы действительно хотите удалить устройство "${device.name}"?',
              style: const TextStyle(
                fontFamily: 'Inter',
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Все данные и история мониторинга будут удалены безвозвратно.',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppTheme.textLightColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textColor,
            ),
            child: const Text(
              'Отмена',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _deleteDevice(device),
            style: AppTheme.dangerButtonStyle,
            child: const Text(
              'Удалить',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Удаление устройства
  void _deleteDevice(DeviceModel device) async {
    Navigator.pop(context); // Закрываем диалог

    final deviceController =
        Provider.of<DeviceController>(context, listen: false);
    final success = await deviceController.removeDevice(device.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Устройство "${device.name}" успешно удалено',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context); // Возвращаемся на предыдущий экран
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка при удалении устройства: ${deviceController.error}',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceController = Provider.of<DeviceController>(context);
    final device = deviceController.currentDevice;
    final readings = deviceController.readings;

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          device?.name ?? 'Устройство',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontFamily: 'Baloo2',
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppTheme.primaryColor),
            onPressed: () {
              if (device != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceSettingsScreen(
                      deviceId: device.id,
                      initialSettings: device.settings,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: deviceController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : device == null
              ? const Center(
                  child: Text(
                    'Устройство не найдено',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.textColor,
                    ),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      // Информация об устройстве
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            device.name,
                                            style: const TextStyle(
                                              fontFamily: 'Baloo2',
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'ID: ${device.id}',
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14,
                                              color: AppTheme.textLightColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(device.status)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _getStatusColor(
                                                  device.status),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _getStatusText(device.status),
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14,
                                              color: _getStatusColor(
                                                  device.status),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 16),
                                // Последние показания
                                if (device.lastReading != null) ...[
                                  const Text(
                                    'Последние показания',
                                    style: TextStyle(
                                      fontFamily: 'Baloo2',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildReadingCard(
                                          icon: Icons.favorite_outline,
                                          title: 'Пульс',
                                          value:
                                              '${device.lastReading!.pulseRate}',
                                          unit: 'уд/мин',
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildReadingCard(
                                          icon: Icons.speed_outlined,
                                          title: 'Давление',
                                          value:
                                              '${device.lastReading!.systolicPressure}/${device.lastReading!.diastolicPressure}',
                                          unit: 'мм рт.ст.',
                                          color: AppTheme.accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildReadingCard(
                                    icon: Icons.screen_rotation_outlined,
                                    title: 'Положение тела',
                                    value: '${device.lastReading!.bodyAngle}°',
                                    unit: 'градусов',
                                    color: AppTheme.successColor,
                                  ),
                                ] else
                                  const Center(
                                    child: Text(
                                      'Нет данных',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        color: AppTheme.textLightColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Кнопки действий
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DeviceSettingsScreen(
                                        deviceId: device.id,
                                        initialSettings: device.settings,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.settings_outlined),
                                label: const Text('Настройки'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primaryColor,
                                  elevation: 0,
                                  side: const BorderSide(
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DeviceStatsScreen(
                                        deviceId: device.id,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.stacked_line_chart),
                                label: const Text('Статистика'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _loadDeviceData();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Данные обновлены'),
                                      backgroundColor: AppTheme.successColor,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Обновить данные'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.successColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () =>
                                _showDeleteConfirmationDialog(device),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Удалить устройство'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.errorColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildReadingCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: AppTheme.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppTheme.textLightColor,
          ),
        ),
      ],
    );
  }
}
