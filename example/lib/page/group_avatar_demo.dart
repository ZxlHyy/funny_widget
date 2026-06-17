import 'package:flutter/material.dart';
import 'package:funny_widget/funny_widget.dart';

class GroupAvatarDemoPage extends StatefulWidget {
  const GroupAvatarDemoPage({super.key});

  @override
  State<GroupAvatarDemoPage> createState() => _GroupAvatarDemoPageState();
}

class _GroupAvatarDemoPageState extends State<GroupAvatarDemoPage> {
  var _count = 4;

  List<String> get _avatars => List.generate(
    _count,
    (index) => 'https://picsum.photos/seed/funny-widget-group-$index/80/80',
  );

  void _addAvatar() {
    setState(() {
      _count = _count >= 10 ? 1 : _count + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('团购头像')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _DemoRow(
            title: '动画切换',
            child: GroupPurchaseAvatar(
              avatars: _avatars,
              size: 56,
              mode: GroupAvatarMode.fixed,
              fixedCount: 3,
              overlapRatio: 0.35,
              interval: const Duration(milliseconds: 900),
            ),
          ),
          const SizedBox(height: 28),
          _DemoRow(
            title: '多余人数',
            child: GestureDetector(
              onTap: _addAvatar,
              child: GroupPurchaseAvatar(
                avatars: _avatars,
                size: 56,
                maxVisibleCount: 4,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _DemoRow(
            title: '间距缩放',
            child: GroupPurchaseAvatar(
              avatars: _avatars,
              size: 56,
              width: 148,
              maxVisibleCount: 5,
              overlapRatio: 0.2,
            ),
          ),
          const SizedBox(height: 28),
          _DemoRow(
            title: '常规排列',
            child: GroupPurchaseAvatar(
              avatars: _avatars,
              size: 56,
              maxVisibleCount: 5,
              showExtraCount: false,
              scaleSpacingToFitWidth: false,
              overlapRatio: 0.35,
            ),
          ),
          const SizedBox(height: 32),
          Center(child: Text('当前人数：$_count')),
          const SizedBox(height: 16),
          Center(
            child: FilledButton(
              onPressed: _addAvatar,
              child: const Text('增加头像'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoRow extends StatelessWidget {
  const _DemoRow({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        const SizedBox(width: 16),
        child,
      ],
    );
  }
}
