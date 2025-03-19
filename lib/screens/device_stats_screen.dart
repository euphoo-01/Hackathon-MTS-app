import 'package:flutter/material.dart';
import 'package:healarm/controllers/device_controller.dart';
import 'package:healarm/models/device_model.dart';
import 'package:healarm/theme/app_theme.dart';
import 'package:healarm/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

class DeviceStatsScreen extends StatefulWidget {
  final String deviceId;

  const DeviceStatsScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<DeviceStatsScreen> createState() => _DeviceStatsScreenState();
}

class _DeviceStatsScreenState extends State<DeviceStatsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _loadReadings();
  }
  
  void _loadReadings() {
    Future.microtask(() {
      final deviceController = Provider.of<DeviceController>(context, listen: false);
      deviceController.loadDeviceReadings(widget.deviceId, _startDate, _endDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceController = Provider.of<DeviceController>(context);
    final device = deviceController.currentDevice;
    final readings = deviceController.readings;
    
    // Группировка показаний по дням
    final Map<DateTime, List<DeviceReading>> readingsByDay = {};
    for (var reading in readings) {
      final date = DateTime(
        reading.timestamp.year,
        reading.timestamp.month,
        reading.timestamp.day,
      );
      
      if (!readingsByDay.containsKey(date)) {
        readingsByDay[date] = [];
      }
      
      readingsByDay[date]!.add(reading);
    }
    
    // Сортировка дней по возрастанию
    final sortedDays = readingsByDay.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return Scaffold(
      backgroundColor: AppTheme.backgroundLightColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Статистика устройства',
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
          
          // Основное содержимое
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название устройства и период
                Text(
                  device?.name ?? 'Устройство',
                  style: AppTheme.headingStyle.copyWith(
                    fontSize: 24,
                  ),
                ).animate().fade(duration: 400.ms),
                
                const SizedBox(height: 8),
                
                Text(
                  'Статистика за ${_startDate.day}.${_startDate.month}.${_startDate.year} - ${_endDate.day}.${_endDate.month}.${_endDate.year}',
                  style: AppTheme.captionStyle,
                ).animate().fade(delay: 200.ms, duration: 400.ms),
                
                const SizedBox(height: 24),
                
                // Карточка выбора периода
                GlassCard(
                  hasShadow: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Выберите период',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateSelector(
                              label: 'Начало',
                              date: _startDate,
                              onTap: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                  lastDate: _endDate,
                                );
                                
                                if (pickedDate != null && mounted) {
                                  setState(() {
                                    _startDate = pickedDate;
                                  });
                                  _loadReadings();
                                }
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: _buildDateSelector(
                              label: 'Конец',
                              date: _endDate,
                              onTap: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: _startDate,
                                  lastDate: DateTime.now(),
                                );
                                
                                if (pickedDate != null && mounted) {
                                  setState(() {
                                    _endDate = pickedDate;
                                  });
                                  _loadReadings();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Быстрые фильтры
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              label: 'Сегодня',
                              onTap: () {
                                setState(() {
                                  _startDate = DateTime.now().subtract(const Duration(hours: 24));
                                  _endDate = DateTime.now();
                                });
                                _loadReadings();
                              },
                            ),
                            _buildFilterChip(
                              label: 'Неделя',
                              onTap: () {
                                setState(() {
                                  _startDate = DateTime.now().subtract(const Duration(days: 7));
                                  _endDate = DateTime.now();
                                });
                                _loadReadings();
                              },
                            ),
                            _buildFilterChip(
                              label: 'Месяц',
                              onTap: () {
                                setState(() {
                                  _startDate = DateTime.now().subtract(const Duration(days: 30));
                                  _endDate = DateTime.now();
                                });
                                _loadReadings();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(delay: 300.ms, duration: 400.ms),
                
                const SizedBox(height: 24),
                
                // Статистика пульса
                if (device?.settings.isPulseTrackingEnabled ?? false)
                  _buildStatSection(
                    title: 'Статистика пульса',
                    readings: readings,
                    readingsByDay: readingsByDay,
                    sortedDays: sortedDays,
                    valueExtractor: (reading) => reading.pulseRate,
                    color: AppTheme.primaryColor,
                    unit: 'уд/мин',
                    minY: 40,
                    maxY: 140,
                    delay: 400,
                  ),
                
                const SizedBox(height: 24),
                
                // Статистика систолического давления
                if (device?.settings.isPressureTrackingEnabled ?? false)
                  _buildStatSection(
                    title: 'Систолическое давление',
                    readings: readings,
                    readingsByDay: readingsByDay,
                    sortedDays: sortedDays,
                    valueExtractor: (reading) => reading.systolicPressure,
                    color: AppTheme.primaryDarkColor,
                    unit: 'мм рт. ст.',
                    minY: 90,
                    maxY: 180,
                    delay: 500,
                  ),
                
                const SizedBox(height: 24),
                
                // Статистика диастолического давления
                if (device?.settings.isPressureTrackingEnabled ?? false)
                  _buildStatSection(
                    title: 'Диастолическое давление',
                    readings: readings,
                    readingsByDay: readingsByDay,
                    sortedDays: sortedDays,
                    valueExtractor: (reading) => reading.diastolicPressure,
                    color: AppTheme.accentColor,
                    unit: 'мм рт. ст.',
                    minY: 50,
                    maxY: 120,
                    delay: 600,
                  ),
                
                const SizedBox(height: 24),
                
                // Критические события
                GlassCard(
                  hasShadow: true,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.warningColor.withOpacity(0.7),
                      AppTheme.errorColor.withOpacity(0.7),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Критические события',
                        style: AppTheme.subheadingStyle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildEventCounter(
                            icon: Icons.favorite_border,
                            count: readings.where((r) => 
                              r.pulseRate != null && (r.pulseRate! > 120 || r.pulseRate! < 45)
                            ).length,
                            label: 'Критический пульс',
                          ),
                          _buildEventCounter(
                            icon: Icons.speed_outlined,
                            count: readings.where((r) => 
                              r.systolicPressure != null && r.diastolicPressure != null && 
                              (r.systolicPressure! > 180 || r.systolicPressure! < 90 ||
                               r.diastolicPressure! > 120 || r.diastolicPressure! < 60)
                            ).length,
                            label: 'Критическое давление',
                          ),
                          _buildEventCounter(
                            icon: Icons.screen_rotation_outlined,
                            count: readings.where((r) => 
                              r.bodyAngle != null && r.bodyAngle! > 60
                            ).length,
                            label: 'Критический наклон',
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fade(delay: 700.ms, duration: 400.ms),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // Индикатор загрузки
          if (deviceController.isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textLightColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.day}.${date.month}.${date.year}',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatSection({
    required String title,
    required List<DeviceReading> readings,
    required Map<DateTime, List<DeviceReading>> readingsByDay,
    required List<DateTime> sortedDays,
    required int? Function(DeviceReading) valueExtractor,
    required Color color,
    required String unit,
    required double minY,
    required double maxY,
    required int delay,
  }) {
    // Расчет средних значений по дням
    final List<FlSpot> spots = [];
    for (int i = 0; i < sortedDays.length; i++) {
      final date = sortedDays[i];
      final dayReadings = readingsByDay[date]!;
      
      // Фильтруем показания с ненулевыми значениями
      final validReadings = dayReadings
          .where((r) => valueExtractor(r) != null)
          .toList();
      
      if (validReadings.isNotEmpty) {
        // Расчет среднего значения
        final sum = validReadings.fold<int>(
          0, 
          (sum, reading) => sum + (valueExtractor(reading) ?? 0),
        );
        final average = sum / validReadings.length;
        
        spots.add(FlSpot(i.toDouble(), average));
      }
    }
    
    // Расчет статистики
    int? min, max;
    double avg = 0;
    int count = 0;
    
    for (final reading in readings) {
      final value = valueExtractor(reading);
      if (value != null) {
        if (min == null || value < min) {
          min = value;
        }
        if (max == null || value > max) {
          max = value;
        }
        avg += value;
        count++;
      }
    }
    
    if (count > 0) {
      avg /= count;
    }
    
    return GlassCard(
      hasShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.subheadingStyle.copyWith(
              fontSize: 18,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Значения статистики
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatValue(
                label: 'Среднее',
                value: count > 0 ? '${avg.toStringAsFixed(1)} $unit' : 'Н/Д',
                color: color,
              ),
              _buildStatValue(
                label: 'Минимум',
                value: min != null ? '$min $unit' : 'Н/Д',
                color: color,
              ),
              _buildStatValue(
                label: 'Максимум',
                value: max != null ? '$max $unit' : 'Н/Д',
                color: color,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // График
          SizedBox(
            height: 200,
            child: spots.isEmpty
                ? const Center(
                    child: Text('Нет данных для отображения'),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: (maxY - minY) / 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= sortedDays.length || value.toInt() < 0) {
                                return const SizedBox();
                              }
                              
                              final date = sortedDays[value.toInt()];
                              
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '${date.day}.${date.month}',
                                  style: AppTheme.captionStyle.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: AppTheme.captionStyle.copyWith(
                                  fontSize: 12,
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (sortedDays.length - 1).toDouble(),
                      minY: minY,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: color,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: color,
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: color.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    ).animate().fade(delay: Duration(milliseconds: delay), duration: const Duration(milliseconds: 400));
  }
  
  Widget _buildStatValue({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.captionStyle,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildEventCounter({
    required IconData icon,
    required int count,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: AppTheme.headingStyle.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 