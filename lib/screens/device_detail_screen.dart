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

class _DeviceDetailScreenState extends State<DeviceDetailScreen> with SingleTickerProviderStateMixin {
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
      final deviceController = Provider.of<DeviceController>(context, listen: false);
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
    
    final deviceController = Provider.of<DeviceController>(context, listen: false);
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
      backgroundColor: AppTheme.backgroundLightColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          device?.name ?? 'Устройство',
          style: TextStyle(
            fontFamily: 'Baloo2',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        actions: [
          // Кнопка настроек устройства
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Настройки устройства',
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
          // Кнопка удаления устройства
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Удалить устройство',
            onPressed: () {
              if (device != null) {
                _showDeleteConfirmationDialog(device);
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
              : Stack(
                  children: [
                    // Декоративные элементы фона с усиленным размытием
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Основное содержимое
                    Column(
                      children: [
                        // Карточка статуса
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: GlassCard(
                            hasShadow: true,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                device.status == DeviceStatus.normal
                                    ? AppTheme.successColor.withOpacity(0.8)
                                    : device.status == DeviceStatus.warning
                                        ? AppTheme.warningColor.withOpacity(0.8)
                                        : device.status == DeviceStatus.critical
                                            ? AppTheme.errorColor.withOpacity(0.8)
                                            : Colors.grey.withOpacity(0.8),
                                device.status == DeviceStatus.normal
                                    ? AppTheme.successColor.withOpacity(0.6)
                                    : device.status == DeviceStatus.warning
                                        ? AppTheme.warningColor.withOpacity(0.6)
                                        : device.status == DeviceStatus.critical
                                            ? AppTheme.errorColor.withOpacity(0.6)
                                            : Colors.grey.withOpacity(0.6),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Статус устройства',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        _getStatusText(device.status),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 8),
                                
                                const Divider(
                                  color: Colors.white24,
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Основные показатели
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStat(
                                      icon: Icons.favorite,
                                      title: 'Пульс',
                                      value: readings.isNotEmpty && readings.first.pulseRate != null
                                          ? '${readings.first.pulseRate} уд/мин'
                                          : 'Н/Д',
                                      valueColor: readings.isNotEmpty && readings.first.pulseRate != null
                                          ? readings.first.pulseRate! > 100 || readings.first.pulseRate! < 50
                                              ? AppTheme.errorColor
                                              : Colors.white
                                          : Colors.white,
                                    ),
                                    _buildStat(
                                      icon: Icons.speed,
                                      title: 'Давление',
                                      value: readings.isNotEmpty && 
                                          readings.first.systolicPressure != null &&
                                          readings.first.diastolicPressure != null
                                          ? '${readings.first.systolicPressure}/${readings.first.diastolicPressure}'
                                          : 'Н/Д',
                                      valueColor: Colors.white,
                                    ),
                                    _buildStat(
                                      icon: Icons.screen_rotation,
                                      title: 'Наклон',
                                      value: readings.isNotEmpty && readings.first.bodyAngle != null
                                          ? '${readings.first.bodyAngle}°'
                                          : 'Н/Д',
                                      valueColor: readings.isNotEmpty && readings.first.bodyAngle != null
                                          ? readings.first.bodyAngle! > 60
                                              ? AppTheme.errorColor
                                              : Colors.white
                                          : Colors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ).animate().fade(duration: 400.ms),
                        
                        // Вкладки с данными
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(
                              text: 'Пульс',
                              icon: Icon(Icons.favorite_outline),
                            ),
                            Tab(
                              text: 'Давление',
                              icon: Icon(Icons.speed_outlined),
                            ),
                          ],
                          labelColor: AppTheme.primaryColor,
                          unselectedLabelColor: AppTheme.textColor,
                          labelStyle: const TextStyle(
                            fontFamily: 'Baloo2',
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontFamily: 'Baloo2',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        // Содержимое вкладок
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Вкладка пульса
                              _buildPulseTab(readings, context),
                              
                              // Вкладка давления
                              _buildPressureTab(readings, context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
      floatingActionButton: device == null
          ? null
          : FloatingActionButton.extended(
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
              label: const Text(
                'Детальная статистика',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              icon: const Icon(Icons.analytics_outlined),
              backgroundColor: AppTheme.primaryColor,
            ),
    );
  }
  
  Widget _buildStat({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Baloo2',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPulseTab(List<DeviceReading> readings, BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    if (readings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.heart_broken_outlined,
              size: 64,
              color: AppTheme.textLightColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Нет данных о пульсе',
              style: const TextStyle(
                fontFamily: 'Baloo2',
                fontSize: 18,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: size.width * 0.8,
              child: Text(
                'Устройство пока не передало данных о пульсе. Проверьте настройки или подождите некоторое время.',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppTheme.textLightColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    
    // Отфильтруем только показания с пульсом
    final pulseReadings = readings
        .where((reading) => reading.pulseRate != null)
        .toList()
        .reversed
        .toList();
    
    if (pulseReadings.isEmpty) {
      return Center(
        child: Text(
          'Нет данных о пульсе',
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppTheme.textColor,
          ),
        ),
      );
    }
    
    // Вычисляем мин/макс/средний пульс
    final minPulse = pulseReadings.map((r) => r.pulseRate!).reduce((a, b) => a < b ? a : b);
    final maxPulse = pulseReadings.map((r) => r.pulseRate!).reduce((a, b) => a > b ? a : b);
    final avgPulse = pulseReadings.map((r) => r.pulseRate!).reduce((a, b) => a + b) / pulseReadings.length;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Статистика пульса
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPulseStatCard(
                title: 'Мин.',
                value: minPulse.toInt().toString(),
                color: minPulse < 50 ? AppTheme.errorColor : AppTheme.primaryColor,
                icon: Icons.arrow_downward,
              ),
              _buildPulseStatCard(
                title: 'Средн.',
                value: avgPulse.toInt().toString(),
                color: AppTheme.primaryColor,
                icon: Icons.horizontal_rule,
              ),
              _buildPulseStatCard(
                title: 'Макс.',
                value: maxPulse.toInt().toString(),
                color: maxPulse > 100 ? AppTheme.errorColor : AppTheme.primaryColor,
                icon: Icons.arrow_upward,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Заголовок графика
          Text(
            'График пульса',
            style: const TextStyle(
              fontFamily: 'Baloo2',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Данные за сегодня',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppTheme.textLightColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // График пульса
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.textLightColor.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppTheme.textLightColor,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      interval: 20,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < pulseReadings.length) {
                          final reading = pulseReadings[value.toInt()];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${reading.timestamp.hour}:${reading.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: AppTheme.textLightColor,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      interval: pulseReadings.length > 5 ? (pulseReadings.length / 5).ceil().toDouble() : 1,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: pulseReadings.length.toDouble() - 1,
                minY: 40,
                maxY: 140,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      pulseReadings.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        pulseReadings[index].pulseRate!.toDouble(),
                      ),
                    ),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        Color dotColor = AppTheme.primaryColor;
                        double radius = 4;
                        
                        if (pulseReadings[index].pulseRate! > 100 || pulseReadings[index].pulseRate! < 50) {
                          dotColor = AppTheme.errorColor;
                          radius = 5;
                        }
                        
                        return FlDotCirclePainter(
                          radius: radius,
                          color: dotColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppTheme.textLightColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Baloo2',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPressureTab(List<DeviceReading> readings, BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    if (readings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.speed_outlined,
              size: 64,
              color: AppTheme.textLightColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Нет данных о давлении',
              style: const TextStyle(
                fontFamily: 'Baloo2',
                fontSize: 18,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: size.width * 0.8,
              child: Text(
                'Устройство пока не передало данных о давлении. Проверьте настройки или подождите некоторое время.',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppTheme.textLightColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    
    // Отфильтруем только показания с данными о давлении
    final pressureReadings = readings
        .where((reading) => reading.systolicPressure != null && reading.diastolicPressure != null)
        .toList()
        .reversed
        .toList();
    
    if (pressureReadings.isEmpty) {
      return Center(
        child: Text(
          'Нет данных о давлении',
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppTheme.textColor,
          ),
        ),
      );
    }
    
    // Вычисляем мин/макс/среднее систолическое давление
    final minSys = pressureReadings.map((r) => r.systolicPressure!).reduce((a, b) => a < b ? a : b);
    final maxSys = pressureReadings.map((r) => r.systolicPressure!).reduce((a, b) => a > b ? a : b);
    final avgSys = pressureReadings.map((r) => r.systolicPressure!).reduce((a, b) => a + b) / pressureReadings.length;
    
    // Вычисляем мин/макс/среднее диастолическое давление
    final minDia = pressureReadings.map((r) => r.diastolicPressure!).reduce((a, b) => a < b ? a : b);
    final maxDia = pressureReadings.map((r) => r.diastolicPressure!).reduce((a, b) => a > b ? a : b);
    final avgDia = pressureReadings.map((r) => r.diastolicPressure!).reduce((a, b) => a + b) / pressureReadings.length;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Статистика давления
          Text(
            'Систолическое',
            style: const TextStyle(
              fontFamily: 'Baloo2',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPulseStatCard(
                title: 'Мин.',
                value: minSys.toString(),
                color: AppTheme.primaryColor,
                icon: Icons.arrow_downward,
              ),
              _buildPulseStatCard(
                title: 'Средн.',
                value: avgSys.toInt().toString(),
                color: AppTheme.primaryColor,
                icon: Icons.horizontal_rule,
              ),
              _buildPulseStatCard(
                title: 'Макс.',
                value: maxSys.toString(),
                color: maxSys > 140 ? AppTheme.errorColor : AppTheme.primaryColor,
                icon: Icons.arrow_upward,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Диастолическое',
            style: const TextStyle(
              fontFamily: 'Baloo2',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.accentColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPulseStatCard(
                title: 'Мин.',
                value: minDia.toString(),
                color: AppTheme.accentColor,
                icon: Icons.arrow_downward,
              ),
              _buildPulseStatCard(
                title: 'Средн.',
                value: avgDia.toInt().toString(),
                color: AppTheme.accentColor,
                icon: Icons.horizontal_rule,
              ),
              _buildPulseStatCard(
                title: 'Макс.',
                value: maxDia.toString(),
                color: maxDia > 90 ? AppTheme.errorColor : AppTheme.accentColor,
                icon: Icons.arrow_upward,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Заголовок графика
          Text(
            'График давления',
            style: const TextStyle(
              fontFamily: 'Baloo2',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Данные за сегодня',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppTheme.textLightColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // График давления
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.textLightColor.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppTheme.textLightColor,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      interval: 30,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < pressureReadings.length) {
                          final reading = pressureReadings[value.toInt()];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${reading.timestamp.hour}:${reading.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: AppTheme.textLightColor,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      interval: pressureReadings.length > 5 ? (pressureReadings.length / 5).ceil().toDouble() : 1,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: pressureReadings.length.toDouble() - 1,
                minY: 40,
                maxY: 180,
                lineBarsData: [
                  // Систолическое давление
                  LineChartBarData(
                    spots: List.generate(
                      pressureReadings.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        pressureReadings[index].systolicPressure!.toDouble(),
                      ),
                    ),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                  ),
                  
                  // Диастолическое давление
                  LineChartBarData(
                    spots: List.generate(
                      pressureReadings.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        pressureReadings[index].diastolicPressure!.toDouble(),
                      ),
                    ),
                    isCurved: true,
                    color: AppTheme.accentColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.accentColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.accentColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Легенда
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Систолическое',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppTheme.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Диастолическое',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 