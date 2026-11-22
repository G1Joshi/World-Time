import 'package:material_ui/material_ui.dart';

class TimeScrubber extends StatelessWidget {
  final double hourOffset;
  final ValueChanged<double> onChanged;
  final VoidCallback onReset;

  const TimeScrubber({
    super.key,
    required this.hourOffset,
    required this.onChanged,
    required this.onReset,
  });

  bool get isLive => hourOffset == 0.0;

  String get offsetLabel {
    if (isLive) return 'LIVE (NOW)';
    final sign = hourOffset > 0 ? '+' : '';
    final abs = hourOffset.abs();
    final h = abs.toInt();
    final m = ((abs - h) * 60).round();
    if (m == 0) {
      return 'TIME TRAVEL: $sign${h}h';
    }
    return 'TIME TRAVEL: $sign${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLive
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.amberAccent.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isLive
                        ? Icons.history_toggle_off_rounded
                        : Icons.timelapse_rounded,
                    color: isLive ? Colors.white70 : Colors.amberAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    offsetLabel,
                    style: TextStyle(
                      color: isLive ? Colors.white70 : Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              if (!isLive)
                InkWell(
                  onTap: onReset,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Reset to Now',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: isLive
                  ? Colors.lightBlueAccent
                  : Colors.amberAccent,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
              thumbColor: isLive ? Colors.lightBlueAccent : Colors.amberAccent,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: hourOffset,
              min: -12.0,
              max: 12.0,
              divisions: 48, // 30-minute intervals
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '-12h',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
              ),
              Row(
                children: [
                  _QuickShiftButton(label: '-1h', onTap: () => _shift(-1.0)),
                  const SizedBox(width: 8),
                  _QuickShiftButton(label: 'Now', onTap: onReset),
                  const SizedBox(width: 8),
                  _QuickShiftButton(label: '+1h', onTap: () => _shift(1.0)),
                ],
              ),
              Text(
                '+12h',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _shift(double delta) {
    final next = (hourOffset + delta).clamp(-12.0, 12.0);
    onChanged(next);
  }
}

class _QuickShiftButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickShiftButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
