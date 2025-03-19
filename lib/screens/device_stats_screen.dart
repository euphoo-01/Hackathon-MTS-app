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

class _DeviceStatsScreenState extends State<DeviceStatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(hours: 24));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReadings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadReadings() {
    Future.microtask(() {
      final deviceController =
          Provider.of<DeviceController>(context, listen: false);
      deviceController.loadDeviceReadings(
          widget.deviceId, _startDate, _endDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceController = Provider.of<DeviceController>(context);
    final device = deviceController.currentDevice;
    final readings = deviceController.readings;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Статистика устройства',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontFamily: 'Baloo2',
            fontSize: 24,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.favorite_border, color: AppTheme.textDarkColor),
              text: 'Пульс',
            ),
            Tab(
              icon: Icon(Icons.speed_outlined, color: AppTheme.textDarkColor),
              text: 'Давление',
            ),
            Tab(
              icon: Icon(Icons.screen_rotation_outlined,
                  color: AppTheme.textDarkColor),
              text: 'Положение',
            ),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textDarkColor,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Декоративные элементы фона
            Positioned(
              top: 0,
              right: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                  maxHeight: MediaQuery.of(context).size.width * 0.8,
                ),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        blurRadius: 100,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Основное содержимое
            if (readings.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 64,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Нет данных для анализа',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Статистика появится после получения данных от устройства',
                      style: TextStyle(
                        color: AppTheme.textLightColor,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              TabBarView(
                controller: _tabController,
                children: [
                  _buildPulseTab(),
                  _buildPressureTab(),
                  _buildPositionTab(),
                ],
              ),
          ],
        ),
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
    // Расчет значений по часам
    final List<FlSpot> spots = [];
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));

    // Группируем показания по часам
    final Map<int, List<int>> valuesByHour = {};
    for (var reading in readings) {
      if (reading.timestamp.isAfter(yesterday)) {
        final hour = reading.timestamp.hour;
        final value = valueExtractor(reading);
        if (value != null) {
          if (!valuesByHour.containsKey(hour)) {
            valuesByHour[hour] = [];
          }
          valuesByHour[hour]!.add(value);
        }
      }
    }

    // Создаем точки для графика
    for (int hour = 0; hour < 24; hour++) {
      if (valuesByHour.containsKey(hour)) {
        final values = valuesByHour[hour]!;
        final average = values.reduce((a, b) => a + b) / values.length;
        spots.add(FlSpot(hour.toDouble(), average));
      }
    }

    // Расчет статистики
    int? min, max;
    double avg = 0;
    int count = 0;

    for (final reading in readings) {
      if (reading.timestamp.isAfter(yesterday)) {
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
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
                ? Center(
                    child: Text(
                      'Нет данных для отображения',
                      style: TextStyle(
                        color: AppTheme.textDarkColor,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: (maxY - minY) / 5,
                        verticalInterval: 4,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppTheme.textDarkColor.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: AppTheme.textDarkColor.withOpacity(0.2),
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
                              if (value % 4 == 0) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    '${value.toInt()}:00',
                                    style: TextStyle(
                                      color: AppTheme.textDarkColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: AppTheme.textDarkColor,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: AppTheme.textDarkColor.withOpacity(0.2),
                        ),
                      ),
                      minX: 0,
                      maxX: 23,
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
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.white,
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y.toStringAsFixed(1)} $unit\n${spot.x.toInt()}:00',
                                TextStyle(
                                  color: AppTheme.textDarkColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ).animate().fade(
        delay: Duration(milliseconds: delay),
        duration: const Duration(milliseconds: 400));
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

  Widget _buildPulseTab() {
    final deviceController = Provider.of<DeviceController>(context);
    final readings = deviceController.readings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatSection(
            title: 'Статистика пульса',
            readings: readings,
            readingsByDay: {},
            sortedDays: [],
            valueExtractor: (reading) => reading.pulseRate,
            color: AppTheme.primaryColor,
            unit: 'уд/мин',
            minY: 40,
            maxY: 140,
            delay: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildPressureTab() {
    final deviceController = Provider.of<DeviceController>(context);
    final readings = deviceController.readings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatSection(
            title: 'Систолическое давление',
            readings: readings,
            readingsByDay: {},
            sortedDays: [],
            valueExtractor: (reading) => reading.systolicPressure,
            color: AppTheme.primaryColor,
            unit: 'мм рт.ст.',
            minY: 90,
            maxY: 180,
            delay: 0,
          ),
          const SizedBox(height: 16),
          _buildStatSection(
            title: 'Диастолическое давление',
            readings: readings,
            readingsByDay: {},
            sortedDays: [],
            valueExtractor: (reading) => reading.diastolicPressure,
            color: AppTheme.accentColor,
            unit: 'мм рт.ст.',
            minY: 50,
            maxY: 120,
            delay: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildPositionTab() {
    final deviceController = Provider.of<DeviceController>(context);
    final readings = deviceController.readings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatSection(
            title: 'Положение тела',
            readings: readings,
            readingsByDay: {},
            sortedDays: [],
            valueExtractor: (reading) => reading.bodyAngle,
            color: AppTheme.successColor,
            unit: '°',
            minY: 0,
            maxY: 180,
            delay: 0,
          ),
        ],
      ),
    );
  }
}
