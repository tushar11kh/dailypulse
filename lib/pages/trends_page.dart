// lib/pages/trends_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/mood_provider.dart';
import '../widgets/toggle_buttons_row.dart';

class TrendsPage extends StatelessWidget {
  const TrendsPage({Key? key}) : super(key: key);

  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _rangeName(int index) {
    switch (index) {
      case 0:
        return 'This Week';
      case 1:
        return 'This Month';
      case 2:
      default:
        return 'This Year';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MoodProvider>();
    final selectedRange = provider.selectedRangeIndex;
    final rawDays = provider.lastNDaysForSelectedRange(); // daily list, possibly size 7/30/365

    // Decide how to build chart points:
    // - Week / Month => use daily points (rawDays)
    // - Year => aggregate into 12 monthly averages (one point per month)
    final bool isYear = selectedRange == 2;

    // Function to convert mood score (-1..1) -> chart Y (0..2)
    double _scoreToY(int score) => (score + 1).toDouble();

    // Chart data containers
    List<FlSpot> spots = [];
    List<String> xLabels = [];

    if (!isYear) {
      // Daily view: keep daily points in order
      for (var i = 0; i < rawDays.length; i++) {
        spots.add(FlSpot(i.toDouble(), _scoreToY(rawDays[i].score)));
      }

      // X labels: if week show weekday names, if month show day numbers
      final rangeDays = rawDays.length;
      if (rangeDays <= 7) {
        xLabels = rawDays.map((d) {
          const w = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          return w[d.date.weekday - 1];
        }).toList();
      } else {
        xLabels = rawDays.map((d) => '${d.date.day}').toList();
      }
    } else {
      // Year view: aggregate by calendar month (Jan..Dec)
      // Build buckets for the last 12 months based on the dates in rawDays.
      // rawDays is ordered oldest -> newest (provider returns that), but to be safe we'll map by month.
      final now = DateTime.now();
      // Determine which 12 months we're showing: starting from (now - 11 months) to now.
      final months = List.generate(12, (i) {
        final dt = DateTime(now.year, now.month - 11 + i, 1);
        return DateTime(dt.year, dt.month, 1);
      });

      // Initialize buckets
      final Map<int, List<int>> buckets = {}; // key = monthIndex (0..11), value = scores
      for (int i = 0; i < months.length; i++) buckets[i] = [];

      // Fill buckets with scores from rawDays
      for (final entry in rawDays) {
        // find index in months (match year & month)
        for (int i = 0; i < months.length; i++) {
          final m = months[i];
          if (entry.date.year == m.year && entry.date.month == m.month) {
            buckets[i]!.add(entry.score);
            break;
          }
        }
      }

      // Compute average per bucket -> one spot per month
      for (int i = 0; i < months.length; i++) {
        final scores = buckets[i]!;
        double y;
        if (scores.isEmpty) {
          // no data -> neutral
          y = _scoreToY(0);
        } else {
          final avg = scores.reduce((a, b) => a + b) / scores.length; // average between -1..1
          // round to nearest step that we want to show? Keep as float for smoother curve
          y = (avg + 1.0);
        }
        spots.add(FlSpot(i.toDouble(), y));
        xLabels.add(_monthLabels[months[i].month - 1]);
      }
    }

    // Compute a small summary sentence
    final positives = provider.positivesForSelectedRange;
    final negatives = provider.negativesForSelectedRange;
    final total = provider.totalForSelectedRange;
    String moodTrend;
    if (total == 0) moodTrend = "No data yet";
    else if (positives > negatives) moodTrend = "Mostly Positive";
    else if (negatives > positives) moodTrend = "Mostly Negative";
    else moodTrend = "Balanced Mood";

    // Build chart widget
    Widget chartCard() {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 260,
            child: spots.isEmpty
                ? const Center(
                    child: Text(
                      'No data yet.\nLog your moods to visualize trends.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 2,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.12),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.deepPurple,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.deepPurple.withOpacity(0.22),
                                Colors.deepPurple.withOpacity(0.03),
                              ],
                            ),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            reservedSize: 46,
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value == 0 || value == 1 || value == 2) {
                                final labels = ['Sad', 'Neutral', 'Happy'];
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 6,
                                  child: Text(
                                    labels[value.toInt()],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: isYear ? 28 : 32,
                            interval: isYear ? 1 : (spots.length <= 7 ? 1 : (spots.length / 6)),
                            getTitlesWidget: (v, meta) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= xLabels.length) return const SizedBox.shrink();
                              final label = xLabels[idx];
                              return SideTitleWidget(
                                meta: meta,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(label, style: const TextStyle(fontSize: 11)),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Mood Trends'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              const Center(child: ToggleButtonsRow()),
              const SizedBox(height: 22),
              Text(
                _rangeName(selectedRange),
                style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                moodTrend,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.deepPurple),
              ),
              const SizedBox(height: 6),
              Text(total == 0 ? 'No entries yet' : "$positives Positive • $negatives Negative • $total total"),
              const SizedBox(height: 18),

              chartCard(),

              const SizedBox(height: 14),

              if (selectedRange == 2)
                // small legend and hint for year mode
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        "Each point is a day. Higher lines mean happier moods.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),

              if (total > 0 && selectedRange != 2) ...[
                const SizedBox(height: 12),
                Text(
                  "Each point is a day. Higher lines mean happier moods.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
