import 'package:flutter/material.dart';
import 'package:healarm/controllers/device_controller.dart';
import 'package:healarm/models/device_model.dart';
import 'package:healarm/theme/app_theme.dart';
import 'package:healarm/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  final String? deviceId;

  const StatisticsScreen({Key? key, this.deviceId}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DeviceModel> _devices = [];
  DeviceModel? _selectedDevice;
  String _timeRange = 'week'; // 'day', 'week', 'month'
  bool _isLoading = false;
  List<DeviceReading> _filteredReadings = [];
  final DateFormat _dateFormat = DateFormat('dd.MM HH:mm');
  final DateFormat _shortDateFormat = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDevices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final deviceController = Provider.of<DeviceController>(context, listen: false);
      
      // Используем Future.microtask, чтобы избежать вызова notifyListeners во время построения
      Future.microtask(() async {
        final devices = await deviceController.getAllDevices();
        
        if (mounted) {
          setState(() {
            _devices = devices;
            if (widget.deviceId != null) {
              final deviceIndex = _devices.indexWhere((device) => device.id == widget.deviceId);
              if (deviceIndex != -1) {
                _selectedDevice = _devices[deviceIndex];
              } else if (_devices.isNotEmpty) {
                _selectedDevice = _devices.first;
              }
            } else if (_devices.isNotEmpty) {
              _selectedDevice = _devices.first;
            }
            
            if (_selectedDevice != null) {
              _filterReadings();
            }
            
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки устройств: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterReadings() {
    if (_selectedDevice?.readings == null || _selectedDevice!.readings!.isEmpty) {
      _filteredReadings = [];
      return;
    }

    final now = DateTime.now();
    DateTime startDate;

    // Определяем начальную дату в зависимости от выбранного периода
    switch (_timeRange) {
      case 'day':
        startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
        break;
      case 'week':
        startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    }

    // Фильтруем показания за выбранный период
    _filteredReadings = _selectedDevice!.readings!
        .where((reading) => reading.timestamp.isAfter(startDate))
        .toList();
    
    // Сортируем показания по времени
    _filteredReadings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void _onDeviceChanged(DeviceModel? device) {
    setState(() {
      _selectedDevice = device;
      if (_selectedDevice != null) {
        _filterReadings();
      } else {
        _filteredReadings = [];
      }
    });
  }

  void _onTimeRangeChanged(String? range) {
    if (range != null) {
      setState(() {
        _timeRange = range;
        if (_selectedDevice != null) {
          _filterReadings();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика показателей'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Пульс'),
            Tab(text: 'Давление'),
            Tab(text: 'Положение'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _devices.isEmpty
                ? const Center(child: Text('Нет подключенных устройств'))
                : Column(
                    children: [
                      _buildDeviceSelector(),
                      _buildTimeRangeSelector(),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildPulseTab(),
                            _buildPressureTab(),
                            _buildPositionTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildDeviceSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DeviceModel>(
              isExpanded: true,
              value: _selectedDevice,
              hint: const Text('Выберите устройство'),
              items: _devices.map((device) {
                return DropdownMenuItem<DeviceModel>(
                  value: device,
                  child: Text(device.name),
                );
              }).toList(),
              onChanged: _onDeviceChanged,
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(
            begin: 0.1,
            end: 0,
            duration: 300.ms,
            curve: Curves.easeOutQuad,
          ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeRangeChip('day', 'День'),
          _buildTimeRangeChip('week', 'Неделя'),
          _buildTimeRangeChip('month', 'Месяц'),
        ],
      ),
    );
  }

  Widget _buildTimeRangeChip(String value, String label) {
    final isSelected = _timeRange == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _onTimeRangeChanged(value),
      backgroundColor: Colors.white.withOpacity(0.1),
      selectedColor: AppTheme.primaryColor.withOpacity(0.3),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
      ),
    ).animate(target: isSelected ? 1 : 0).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }

  Widget _buildPulseTab() {
    if (_selectedDevice == null) {
      return const Center(child: Text('Выберите устройство'));
    }

    if (_filteredReadings.isEmpty) {
      return const Center(child: Text('Нет данных за выбранный период'));
    }

    final pulseReadings = _filteredReadings.where((r) => r.pulseRate != null).toList();
    
    if (pulseReadings.isEmpty) {
      return const Center(child: Text('Нет данных о пульсе за выбранный период'));
    }

    // Находим минимальное и максимальное значения для графика
    final minPulse = pulseReadings.map((r) => r.pulseRate!).reduce(
          (min, value) => min < value ? min : value,
        );
    final maxPulse = pulseReadings.map((r) => r.pulseRate!).reduce(
          (max, value) => max > value ? max : value,
        );
    
    // Средний пульс
    final avgPulse = pulseReadings.map((r) => r.pulseRate!).reduce((a, b) => a + b) / pulseReadings.length;
    
    // Аномальные показания
    final anomalies = pulseReadings.where((r) => r.isAnomaly).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(
            avgValue: avgPulse.toStringAsFixed(0),
            minValue: minPulse.toString(),
            maxValue: maxPulse.toString(),
            unit: 'уд/мин',
            anomalyCount: anomalies.length,
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'График пульса',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      _buildPulseLineChart(pulseReadings),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(
                begin: 0.2,
                end: 0,
                duration: 500.ms,
                curve: Curves.easeOutQuad,
              ),
        ],
      ),
    );
  }

  Widget _buildPressureTab() {
    if (_selectedDevice == null) {
      return const Center(child: Text('Выберите устройство'));
    }

    if (_filteredReadings.isEmpty) {
      return const Center(child: Text('Нет данных за выбранный период'));
    }

    final pressureReadings = _filteredReadings
        .where((r) => r.systolicPressure != null && r.diastolicPressure != null)
        .toList();
    
    if (pressureReadings.isEmpty) {
      return const Center(child: Text('Нет данных о давлении за выбранный период'));
    }

    // Средние значения
    final avgSystolic = pressureReadings.map((r) => r.systolicPressure!).reduce((a, b) => a + b) / pressureReadings.length;
    final avgDiastolic = pressureReadings.map((r) => r.diastolicPressure!).reduce((a, b) => a + b) / pressureReadings.length;
    
    // Аномальные показания
    final anomalies = pressureReadings.where((r) => r.isAnomaly).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(
            avgValue: '${avgSystolic.toStringAsFixed(0)}/${avgDiastolic.toStringAsFixed(0)}',
            minValue: '-',
            maxValue: '-',
            unit: 'мм рт.ст.',
            anomalyCount: anomalies.length,
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'График артериального давления',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      _buildPressureLineChart(pressureReadings),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Систолическое', Colors.red),
                      const SizedBox(width: 16),
                      _buildLegendItem('Диастолическое', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(
                begin: 0.2,
                end: 0,
                duration: 500.ms,
                curve: Curves.easeOutQuad,
              ),
        ],
      ),
    );
  }

  Widget _buildPositionTab() {
    if (_selectedDevice == null) {
      return const Center(child: Text('Выберите устройство'));
    }

    if (_filteredReadings.isEmpty) {
      return const Center(child: Text('Нет данных за выбранный период'));
    }

    final positionReadings = _filteredReadings.where((r) => r.bodyAngle != null).toList();
    
    if (positionReadings.isEmpty) {
      return const Center(child: Text('Нет данных о положении тела за выбранный период'));
    }

    return const Center(
      child: Text('График положения тела будет доступен в следующей версии'),
    );
  }

  Widget _buildStatCards({
    required String avgValue,
    required String minValue,
    required String maxValue,
    required String unit,
    required int anomalyCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Среднее',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$avgValue $unit',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(
                begin: 0.1,
                end: 0,
                delay: 100.ms,
                duration: 300.ms,
                curve: Curves.easeOutQuad,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Мин/Макс',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$minValue - $maxValue',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(
                begin: 0.1,
                end: 0,
                delay: 200.ms,
                duration: 300.ms,
                curve: Curves.easeOutQuad,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Аномалии',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    anomalyCount.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: anomalyCount > 0 ? Colors.redAccent : null,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(
                begin: 0.1,
                end: 0,
                delay: 300.ms,
                duration: 300.ms,
                curve: Curves.easeOutQuad,
              ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  LineChartData _buildPulseLineChart(List<DeviceReading> readings) {
    final spots = readings.asMap().entries.map((entry) {
      final reading = entry.value;
      return FlSpot(
        entry.key.toDouble(),
        reading.pulseRate!.toDouble(),
      );
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value % 5 != 0 && value != spots.length - 1) {
                return const SizedBox.shrink();
              }
              
              final index = value.toInt();
              if (index < 0 || index >= readings.length) {
                return const SizedBox.shrink();
              }

              final dateFormat = _timeRange == 'day' ? _shortDateFormat : _dateFormat;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  dateFormat.format(readings[index].timestamp),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white24),
      ),
      minX: 0,
      maxX: spots.length - 1,
      minY: 0,
      maxY: 200,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              final reading = readings[index];
              final date = _dateFormat.format(reading.timestamp);
              
              return LineTooltipItem(
                '${reading.pulseRate} уд/мин\n$date',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppTheme.primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final reading = readings[index];
              return FlDotCirclePainter(
                radius: reading.isAnomaly ? 5 : 3,
                color: reading.isAnomaly ? Colors.red : AppTheme.primaryColor,
                strokeWidth: 1,
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
    );
  }

  LineChartData _buildPressureLineChart(List<DeviceReading> readings) {
    final systolicSpots = readings.asMap().entries.map((entry) {
      final reading = entry.value;
      return FlSpot(
        entry.key.toDouble(),
        reading.systolicPressure!.toDouble(),
      );
    }).toList();

    final diastolicSpots = readings.asMap().entries.map((entry) {
      final reading = entry.value;
      return FlSpot(
        entry.key.toDouble(),
        reading.diastolicPressure!.toDouble(),
      );
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value % 5 != 0 && value != systolicSpots.length - 1) {
                return const SizedBox.shrink();
              }
              
              final index = value.toInt();
              if (index < 0 || index >= readings.length) {
                return const SizedBox.shrink();
              }

              final dateFormat = _timeRange == 'day' ? _shortDateFormat : _dateFormat;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  dateFormat.format(readings[index].timestamp),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white24),
      ),
      minX: 0,
      maxX: systolicSpots.length - 1,
      minY: 0,
      maxY: 200,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              final reading = readings[index];
              final date = _dateFormat.format(reading.timestamp);
              
              if (spot.barIndex == 0) {
                return LineTooltipItem(
                  'Систолическое: ${reading.systolicPressure} мм рт.ст.\n$date',
                  const TextStyle(color: Colors.white),
                );
              } else {
                return LineTooltipItem(
                  'Диастолическое: ${reading.diastolicPressure} мм рт.ст.\n$date',
                  const TextStyle(color: Colors.white),
                );
              }
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: systolicSpots,
          isCurved: true,
          color: Colors.red,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final reading = readings[index];
              return FlDotCirclePainter(
                radius: reading.isAnomaly ? 5 : 3,
                color: reading.isAnomaly ? Colors.redAccent : Colors.red,
                strokeWidth: 1,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
        LineChartBarData(
          spots: diastolicSpots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final reading = readings[index];
              return FlDotCirclePainter(
                radius: reading.isAnomaly ? 5 : 3,
                color: reading.isAnomaly ? Colors.redAccent : Colors.blue,
                strokeWidth: 1,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
      ],
    );
  }
} 