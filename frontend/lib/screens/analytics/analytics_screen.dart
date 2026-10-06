import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/mock_data.dart';
import '../../models/job.dart';
import '../../utils/helpers.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalCompleted = MockData.jobs.where((job) => job.status == JobStatus.completed).length;
    final fixedOnFirstVisit = MockData.jobs.where((job) => job.isFixedOnFirstVisit).length;
    final firstTimeFixRate = AppHelpers.calculateFirstTimeFixRate(fixedOnFirstVisit, totalCompleted);
    final metricAspectRatio = MediaQuery.sizeOf(context).width < 360 ? 1.0 : 1.35;

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Understand your service performance',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'First-Time Fix Rate',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$firstTimeFixRate%',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '↑ 6% this month',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: metricAspectRatio,
                children: const [
                  _MetricCard(label: 'Jobs Completed', value: '0', color: AppTheme.primary),
                  _MetricCard(label: 'On-Time Arrival', value: '86%', color: AppTheme.green),
                  _MetricCard(label: 'Repeat Visits', value: '14%', color: AppTheme.amber),
                  _MetricCard(label: 'Utilization', value: '71%', color: AppTheme.blue),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Service Patterns', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.navy)),
              const SizedBox(height: 12),
              _IssueList(),
              const SizedBox(height: 24),
              const Text('Dispatch Insight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.navy)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primarySoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'AC cooling issues are driving repeat visits this month. Assigning senior specialists to these cases will improve first-time fix performance.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.navy,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
        ],
      ),
    );
  }
}

class _IssueList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'AC', 'value': 35},
      {'label': 'Refrigerator', 'value': 25},
      {'label': 'Washing Machine', 'value': 20},
      {'label': 'Microwave', 'value': 12},
      {'label': 'Other', 'value': 8},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: items.map((item) {
          final value = item['value'] as int;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(item['label'] as String, style: const TextStyle(color: AppTheme.charcoal, fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: value / 100,
                      backgroundColor: AppTheme.line,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('$value%', style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w700)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
