import 'package:flutter/material.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health & Well-being'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _SectionHeader(title: 'Psychological Health'),
          _AdviceCard(
            title: 'Manage Stress',
            description: 'Break your study sessions into smaller chunks using the Pomodoro technique. Remember to take short breaks to prevent burnout.',
            icon: Icons.psychology,
            color: Colors.purple,
          ),
          _AdviceCard(
            title: 'Sleep Hygiene',
            description: 'Aim for 7-9 hours of sleep. Try to go to bed and wake up at the same time every day to keep your circadian rhythm balanced.',
            icon: Icons.nights_stay,
            color: Colors.indigo,
          ),
          
          SizedBox(height: 24),
          
          _SectionHeader(title: 'Physical Health'),
          _AdviceCard(
            title: 'Stay Active',
            description: 'Incorporate at least 30 minutes of moderate physical activity into your daily routine. A brisk walk or a quick stretching session helps!',
            icon: Icons.directions_run,
            color: Colors.teal,
          ),
          _AdviceCard(
            title: 'Healthy Eating',
            description: 'Fuel your brain with nutritious food. Drink plenty of water throughout the day and keep healthy snacks like nuts or fruit nearby while studying.',
            icon: Icons.restaurant,
            color: Colors.orange,
          ),

          SizedBox(height: 24),

          _SectionHeader(title: 'Relaxation Techniques'),
          _AdviceCard(
            title: 'Deep Breathing',
            description: 'Try the 4-7-8 breathing technique: breathe in for 4 seconds, hold for 7 seconds, and exhale slowly for 8 seconds. Repeat 4 times.',
            icon: Icons.air,
            color: Colors.lightBlue,
          ),
          _AdviceCard(
            title: 'Digital Detox',
            description: 'Set aside at least an hour before bedtime to disconnect from all screens. Read a physical book or listen to calming music instead.',
            icon: Icons.mobile_off,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _AdviceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
