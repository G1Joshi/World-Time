import 'package:material_ui/material_ui.dart';

class DayProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final bool isDaylight;

  const DayProgressIndicator({
    super.key,
    required this.progress,
    required this.isDaylight,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDaylight
                        ? Icons.wb_sunny_rounded
                        : Icons.nightlight_round,
                    size: 13,
                    color: isDaylight
                        ? Colors.amberAccent
                        : Colors.indigoAccent,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isDaylight ? 'DAYTIME' : 'NIGHTTIME',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '$percent% of day elapsed',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDaylight ? Colors.amberAccent : Colors.indigoAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
