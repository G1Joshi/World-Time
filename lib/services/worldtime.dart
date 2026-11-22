import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

enum DayPhase {
  morning('Morning', '🌅', 'assets/time/morning.png', Color(0xFFF59E0B)),
  noon('Noon', '☀️', 'assets/time/noon.png', Color(0xFFEAB308)),
  afternoon('Afternoon', '🌤️', 'assets/time/afternoon.png', Color(0xFF38BDF8)),
  evening('Evening', '🌆', 'assets/time/evening.png', Color(0xFFF97316)),
  night('Night', '🌙', 'assets/time/night.png', Color(0xFF6366F1));

  final String title;
  final String emoji;
  final String assetPath;
  final Color accentColor;

  const DayPhase(this.title, this.emoji, this.assetPath, this.accentColor);

  static DayPhase fromHour(int hour) => switch (hour) {
    >= 4 && < 10 => DayPhase.morning,
    >= 10 && < 13 => DayPhase.noon,
    >= 13 && < 16 => DayPhase.afternoon,
    >= 16 && < 21 => DayPhase.evening,
    _ => DayPhase.night,
  };
}

class WorldTime implements Comparable<WorldTime> {
  final String id;
  final String name;
  final String city;
  final String continent;
  final String gmt;
  final Duration offsetDuration;

  String time = '';
  String day = 'morning';
  DayPhase period = DayPhase.morning;

  WorldTime({
    required String location,
    required this.gmt,
    String? name,
    String? city,
    String? continent,
    Duration? precomputedOffset,
  }) : id = location.toLowerCase().trim(),
       name = name ?? _formatDefaultName(location),
       city = city ?? '',
       continent = continent ?? 'Other',
       offsetDuration = precomputedOffset ?? parseGmtOffset(gmt) {
    updateTime();
  }

  static Duration parseGmtOffset(String rawGmt) {
    try {
      final trimmed = rawGmt.trim();
      final isNegative = trimmed.startsWith('-');
      final clean = trimmed.replaceAll('+', '').replaceAll('-', '').trim();
      final parts = clean.split(':');
      final hours = int.parse(parts[0]);
      final minutes = parts.length > 1 ? int.parse(parts[1]) : 0;
      final totalMinutes = (hours * 60 + minutes) * (isNegative ? -1 : 1);
      return Duration(minutes: totalMinutes);
    } catch (_) {
      return Duration.zero;
    }
  }

  String get location => id;

  DateTime get currentTime {
    return DateTime.now().toUtc().add(offsetDuration);
  }

  DateTime timeAt({DateTime? utcTime, Duration shift = Duration.zero}) {
    final base = utcTime ?? DateTime.now().toUtc();
    return base.add(offsetDuration).add(shift);
  }

  DayPhase periodAt(DateTime referenceTime) =>
      DayPhase.fromHour(referenceTime.hour);

  void updateTime({DateTime? referenceTime}) {
    final now = referenceTime ?? currentTime;
    period = DayPhase.fromHour(now.hour);
    day = period.name;
    time = DateFormat.jm().format(now);
  }

  Future<void> getTime() async {
    updateTime();
  }

  String formatTime({
    bool is24Hour = false,
    bool showSeconds = false,
    DateTime? now,
  }) {
    final target = now ?? currentTime;
    if (is24Hour) {
      return showSeconds
          ? DateFormat('HH:mm:ss').format(target)
          : DateFormat('HH:mm').format(target);
    } else {
      return showSeconds
          ? DateFormat('hh:mm:ss a').format(target)
          : DateFormat('hh:mm a').format(target);
    }
  }

  String formatDate({DateTime? now}) {
    final target = now ?? currentTime;
    return DateFormat('EEEE, d MMMM yyyy').format(target);
  }

  String get relativeTimeDifference {
    final localOffset = DateTime.now().timeZoneOffset;
    final diffMinutes = offsetDuration.inMinutes - localOffset.inMinutes;

    if (diffMinutes == 0) {
      return 'Same time as your device';
    }

    final absMinutes = diffMinutes.abs();
    final hours = absMinutes ~/ 60;
    final minutes = absMinutes % 60;

    final parts = <String>[];
    if (hours > 0) {
      parts.add('${hours}h');
    }
    if (minutes > 0 || hours == 0) {
      parts.add('${minutes}m');
    }

    final diffString = parts.join(' ');
    if (diffMinutes > 0) {
      return '$diffString ahead of local time';
    } else {
      return '$diffString behind local time';
    }
  }

  String relativeOffsetTo(WorldTime other) {
    final diffMinutes =
        offsetDuration.inMinutes - other.offsetDuration.inMinutes;

    if (diffMinutes == 0) {
      return 'Same time';
    }

    final absMinutes = diffMinutes.abs();
    final hours = absMinutes ~/ 60;
    final minutes = absMinutes % 60;

    final parts = <String>[];
    if (hours > 0) {
      parts.add('${hours}h');
    }
    if (minutes > 0 || hours == 0) {
      parts.add('${minutes}m');
    }

    final diffString = parts.join(' ');
    if (diffMinutes > 0) {
      return '+$diffString ahead';
    } else {
      return '-$diffString behind';
    }
  }

  double getDayProgress({DateTime? now}) {
    final target = now ?? currentTime;
    final secondsPassed =
        target.hour * 3600 + target.minute * 60 + target.second;
    return (secondsPassed / 86400).clamp(0.0, 1.0);
  }

  bool isDaylight({DateTime? now}) {
    final target = now ?? currentTime;
    return target.hour >= 6 && target.hour < 18;
  }

  String get flagAssetPath => 'assets/flag/$id.png';

  String get timeAssetPath => 'assets/time/$day.png';

  String get periodTitle => period.title;

  String get periodEmoji => period.emoji;

  @override
  int compareTo(WorldTime other) => name.compareTo(other.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorldTime && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WorldTime($id, $name, $city, GMT$gmt)';

  static String _formatDefaultName(String raw) {
    if (raw.isEmpty) return '';
    return raw
        .split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
