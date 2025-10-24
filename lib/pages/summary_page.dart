// lib/pages/summary_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../widgets/toggle_buttons_row.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({Key? key}) : super(key: key);

  Widget _statCard(String title, String value, Color bg) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.black54)),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MoodProvider>();
    final total = provider.totalForSelectedRange;
    final positives = provider.positivesForSelectedRange;
    final negatives = provider.negativesForSelectedRange;
    final neutrals = provider.neutralsForSelectedRange;

    return Scaffold(
      appBar: AppBar(title: Text('Your Summary')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ToggleButtonsRow(),
              SizedBox(height: 18),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  _statCard('Total Entries', '$total', Colors.grey[200]!),
                  _statCard('Positive Days', '$positives', Colors.green[50]!),
                  _statCard('Negative Days', '$negatives', Colors.purple[50]!),
                  _statCard('Neutral Days', '$neutrals', Colors.grey[100]!),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Mood Balance',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Builder(
                  builder: (_) {
                    // Calculate positivity percentage
                    final ratio = total == 0 ? 0.0 : positives / total;

                    // Determine color based on range
                    Color barColor;
                    if (ratio >= 0.66) {
                      barColor = Colors.green[300]!;
                    } else if (ratio >= 0.33) {
                      barColor = Colors.yellow[300]!;
                    } else {
                      barColor = Colors.red[300]!;
                    }

                    return LinearProgressIndicator(
                      minHeight: 16,
                      value: ratio,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
