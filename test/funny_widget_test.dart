import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funny_widget/funny_widget.dart';

void main() {
  testWidgets('GroupPurchaseAvatar shows extra count label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: GroupPurchaseAvatar(
            avatars: const ['1', '2', '3', '4', '5', '6'],
            maxVisibleCount: 4,
            imageBuilder: _avatarBuilder,
          ),
        ),
      ),
    );

    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('GroupPurchaseAvatar fixed mode renders fixed avatars', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: GroupPurchaseAvatar(
            avatars: const ['1', '2', '3', '4'],
            mode: GroupAvatarMode.fixed,
            fixedCount: 3,
            autoPlay: false,
            imageBuilder: _avatarBuilder,
          ),
        ),
      ),
    );

    expect(find.byType(GroupPurchaseAvatar), findsOneWidget);
    expect(find.byType(ColoredBox), findsNWidgets(3));
  });
}

Widget _avatarBuilder(BuildContext context, String imageUrl, double size) {
  return ColoredBox(
    color: Colors.primaries[int.parse(imageUrl) % Colors.primaries.length],
  );
}
