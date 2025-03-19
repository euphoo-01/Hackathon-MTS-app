import 'package:flutter/material.dart';
import 'package:healarm/theme/app_theme.dart';
import 'package:healarm/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLightColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Декоративные элементы фона
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withOpacity(0.1),
                ),
              ),
            ),
            
            // Основное содержимое
            CustomScrollView(
              slivers: [
                // Шапка (AppBar)
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(
                    'Уведомления',
                    style: AppTheme.headingStyle.copyWith(
                      fontSize: 24,
                    ),
                  ),
                  floating: true,
                ),
                
                // Контент
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ваши уведомления и оповещения',
                          style: AppTheme.captionStyle,
                        ).animate().fade(delay: 200.ms, duration: 400.ms),
                        
                        const SizedBox(height: 32),
                        
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                size: 80,
                                color: AppTheme.primaryColor.withOpacity(0.3),
                              ).animate().scale(duration: 600.ms),
                              
                              const SizedBox(height: 24),
                              
                              Text(
                                'У вас пока нет уведомлений',
                                style: AppTheme.subheadingStyle.copyWith(
                                  color: AppTheme.textLightColor,
                                ),
                                textAlign: TextAlign.center,
                              ).animate().fade(delay: 300.ms, duration: 400.ms),
                              
                              const SizedBox(height: 12),
                              
                              Text(
                                'Здесь будут отображаться уведомления о критических показателях и событиях от ваших устройств',
                                style: AppTheme.captionStyle,
                                textAlign: TextAlign.center,
                              ).animate().fade(delay: 400.ms, duration: 400.ms),
                              
                              const SizedBox(height: 32),
                              
                              GlassCard(
                                hasShadow: true,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppTheme.primaryColor.withOpacity(0.1),
                                            ),
                                            child: const Icon(
                                              Icons.tips_and_updates_outlined,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          
                                          const SizedBox(width: 16),
                                          
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Совет',
                                                  style: AppTheme.subheadingStyle.copyWith(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                
                                                const SizedBox(height: 4),
                                                
                                                Text(
                                                  'Подключите ваше первое устройство, чтобы начать мониторинг здоровья',
                                                  style: AppTheme.bodyStyle,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pushNamed(context, '/add_device');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryColor,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Добавить устройство'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 