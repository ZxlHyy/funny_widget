import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:funny_widget/funny_widget.dart';

class AvatarSphereDemoPage extends StatefulWidget {
  const AvatarSphereDemoPage({super.key});

  @override
  State<AvatarSphereDemoPage> createState() => _AvatarSphereDemoPageState();
}

class _AvatarSphereDemoPageState extends State<AvatarSphereDemoPage> {
  double _radius = 150;
  double _avatarSize = 56;
  int _count = 24;

  List<String> get _avatars => List.generate(
    _count,
    (index) => 'https://picsum.photos/seed/funny-widget-sphere-$index/80/80',
  );

  void _setCount(int next) {
    setState(() {
      _count = next.clamp(3, 48);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final radiusMax = math.min(screenWidth * 0.42, 220).toDouble();
    final radiusMin = 80.0;
    final avatarMax = math.min(_radius * 0.42, 72).toDouble();
    final avatarMin = 28.0;

    return Scaffold(
      appBar: AppBar(title: const Text('头像球')),
      body: Column(
        children: [
          Center(
            child: AvatarSphereWidget(
              avatarUrls: _avatars,
              radius: _radius,
              avatarSize: _avatarSize,
              onAvatarTap: (index, imageUrl) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('点击头像：$index')));
              },
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _count > 3 ? () => _setCount(_count - 1) : null,
                icon: const Icon(Icons.remove),
                label: const Text('减少头像'),
              ),
              OutlinedButton.icon(
                onPressed: _count < 48 ? () => _setCount(_count + 1) : null,
                icon: const Icon(Icons.add),
                label: const Text('增加头像'),
              ),
              Chip(
                avatar: const Icon(Icons.photo_library_outlined, size: 18),
                label: Text('头像数：$_count'),
              ),
            ],
          ),
          _SliderBlock(
            label: '球体大小',
            value: _radius,
            min: radiusMin,
            max: radiusMax,
            divisions: 140,
            onChanged: (value) {
              setState(() {
                _radius = value;
                final avatarMaxNext = math.min(_radius * 0.42, 72).toDouble();
                _avatarSize = _avatarSize
                    .clamp(avatarMin, avatarMaxNext)
                    .toDouble();
              });
            },
          ),
          _SliderBlock(
            label: '头像大小',
            value: _avatarSize,
            min: avatarMin,
            max: avatarMax,
            divisions: 44,
            onChanged: (value) {
              setState(() {
                _avatarSize = value.toDouble();
              });
            },
          ),
        ],
      ),
    );
  }
}

class _SliderBlock extends StatelessWidget {
  const _SliderBlock({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: textStyle)),
            Text(value.toStringAsFixed(0), style: textStyle),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
