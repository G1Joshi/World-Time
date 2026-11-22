import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_time/models/sharedprefs.dart';
import 'package:world_time/services/region.dart';
import 'package:world_time/services/worldtime.dart';
import 'package:world_time/views/home.dart';
import 'package:world_time/views/location.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'location': 'india',
      'gmt': '+05:30',
      'favorite_locations': <String>[],
      'is_24_hour': false,
    });
    await SharedPrefs.init();
  });

  group('WorldTime Model Tests', () {
    test('Correctly parses offset duration', () {
      final wt = WorldTime(location: 'india', gmt: '+05:30');
      expect(wt.offsetDuration.inMinutes, 330);
    });

    test('Correctly formats 12H and 24H times', () {
      final wt = WorldTime(location: 'uk', gmt: '+00:00');
      final refTime = DateTime(2026, 9, 24, 15, 45, 30);

      expect(
        wt.formatTime(is24Hour: false, showSeconds: false, now: refTime),
        '03:45 PM',
      );
      expect(
        wt.formatTime(is24Hour: true, showSeconds: false, now: refTime),
        '15:45',
      );
    });
  });

  group('Region Catalog & Search Tests', () {
    test('Contains locations and searches by keyword', () {
      expect(Region.locations.isNotEmpty, isTrue);
      final results = Region.search(query: 'york');
      expect(results.first.id, 'usa');
    });

    test('Filters favorites accurately', () {
      final favs = Region.search(
        category: 'Favorites',
        favoriteIds: ['india', 'uk'],
      );
      expect(favs.length, 2);
    });
  });

  group('SharedPrefs Integration Tests', () {
    test('Toggles favorite state correctly', () async {
      expect(SharedPrefs.isFavorite('france'), isFalse);
      final added = await SharedPrefs.toggleFavorite('france');
      expect(added, isTrue);
      expect(SharedPrefs.isFavorite('france'), isTrue);
    });
  });

  group('UI Widget Tests', () {
    testWidgets('Home renders country, city, and action buttons', (
      WidgetTester tester,
    ) async {
      final india = Region.findById('india');
      await tester.pumpWidget(MaterialApp(home: Home(initialLocation: india)));

      expect(find.text('India'), findsWidgets);
      expect(find.textContaining('New Delhi'), findsOneWidget);
      expect(find.text('Explore All Locations'), findsOneWidget);

      await tester.tap(find.byTooltip('Add to favorites'));
      await tester.pump();
      expect(find.text('PINNED CLOCKS'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('Location picker displays search and filters locations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Location(currentLocationId: 'africa')),
      );

      expect(find.text('Choose Location'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'london');
      await tester.pump();
      expect(find.text('United Kingdom'), findsOneWidget);
    });
  });
}
