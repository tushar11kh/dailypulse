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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Returns emoji for the given positivity ratio (0..1)
  String _emojiForRatio(double ratio) {
    if (ratio >= 0.66) return '😊';
    if (ratio >= 0.33) return '😐';
    return '😔';
  }

  /// Returns color for the given positivity ratio (0..1)
  Color _colorForRatio(double ratio) {
    if (ratio >= 0.66) {
      return Colors.green[300]!;
    } else if (ratio >= 0.33) {
      return Colors.yellow[300]!;
    } else {
      return Colors.red[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MoodProvider>();
    final total = provider.totalForSelectedRange;
    final positives = provider.positivesForSelectedRange;
    final negatives = provider.negativesForSelectedRange;
    final neutrals = provider.neutralsForSelectedRange;

    // positivity ratio 0..1
    final ratio = total == 0 ? 0.0 : (positives / total);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Summary')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ToggleButtonsRow(),
              const SizedBox(height: 18),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  _statCard('Total Entries', '$total', Colors.grey[300]!),
                  _statCard('Positive Days', '$positives', Colors.green[50]!),
                  _statCard('Negative Days', '$negatives', Colors.purple[50]!),
                  _statCard('Neutral Days', '$neutrals', Colors.grey[200]!),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Mood Balance',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // -- NEW: progress bar with emoji indicator --
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LayoutBuilder(builder: (context, constraints) {
                  final barWidth = constraints.maxWidth;
                  // width reserved for emoji widget (so it doesn't overflow)
                  const emojiWidth = 36.0;
                  // compute left offset for emoji (clamped)
                  final leftPos = (barWidth - emojiWidth) * ratio;
                  final clampedLeft = leftPos.isNaN
                      ? 0.0
                      : leftPos.clamp(0.0, barWidth - emojiWidth);

                  final barColor = _colorForRatio(ratio);
                  final emoji = _emojiForRatio(ratio);

                  return SizedBox(
                    height: 56, // enough room for emoji above the bar
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // background bar
                        Positioned.fill(
                          top: 20,
                          bottom: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        // actual progress indicator (clipped)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 20,
                          bottom: 12,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              minHeight: 24,
                              value: ratio,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(barColor),
                            ),
                          ),
                        ),

                        // animated emoji indicator
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          left: clampedLeft,
                          top: 0,
                          child: SizedBox(
                            width: emojiWidth,
                            child: Column(
                              children: [
                                // emoji bubble
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),
              const SizedBox(height: 8),
              // a short legend / explanation
              Text(
                total == 0 ? 'No entries yet' : '${(ratio * 100).toStringAsFixed(0)}% positive',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
