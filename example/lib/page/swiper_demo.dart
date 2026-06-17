import 'package:flutter/material.dart';
import 'package:funny_widget/funny_widget.dart';

class Swiper3DDemoPage extends StatefulWidget {
  const Swiper3DDemoPage({super.key});

  @override
  State<Swiper3DDemoPage> createState() => _Swiper3DDemoPageState();
}

class _Swiper3DDemoPageState extends State<Swiper3DDemoPage> {
  final _controller = Swiper3DController();
  var _imageCount = 3;

  double _childWidth = 130;
  double _childHeight = 80;
  double _deviationRatio = 1.0;
  double _minScale = 0.8;
  double _horizontalPadding = 0;
  double _verticalPadding = 0;
  double _radius = 130;
  bool _useCustomRadius = false;
  bool _loop = true;
  int _currentPage = 0;
  int? _lastTappedPage;

  List<int> get _items => List.generate(_imageCount, (index) => index);

  EdgeInsets? get _padding {
    if (_horizontalPadding == 0 && _verticalPadding == 0) {
      return null;
    }

    return EdgeInsets.symmetric(
      horizontal: _horizontalPadding,
      vertical: _verticalPadding,
    );
  }

  void _reset() {
    setState(() {
      _imageCount = 3;
      _childWidth = 80;
      _childHeight = 80;
      _deviationRatio = 1.0;
      _minScale = 0.8;
      _horizontalPadding = 0;
      _verticalPadding = 0;
      _radius = 130;
      _useCustomRadius = false;
      _loop = true;
      _currentPage = 0;
      _lastTappedPage = null;
    });
    _controller.jumpToPage(0);
  }

  void _changeImageCount(int delta) {
    setState(() {
      _imageCount = (_imageCount + delta).clamp(3, 8);
      _currentPage = _currentPage.clamp(0, _imageCount - 1);
      if (_lastTappedPage != null) {
        _lastTappedPage = _lastTappedPage!.clamp(0, _imageCount - 1);
      }
    });
    _controller.jumpToPage(_currentPage);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('3D旋转'),
        actions: [
          IconButton(
            tooltip: '重置参数',
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Swiper3DWidget(
                key: ValueKey(_items.length),
                controller: _controller,
                childWidth: _childWidth,
                childHeight: _childHeight,
                deviationRatio: _deviationRatio,
                minScale: _minScale,
                padding: _padding,
                radius: _useCustomRadius ? _radius : null,
                loop: _loop,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                onTap: (page) {
                  setState(() {
                    _lastTappedPage = page;
                  });
                },
                children: [
                  for (final item in _items)
                    _SwiperCard(
                      index: item,
                      width: _childWidth,
                      height: _childHeight,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _imageCount > 3 ? () => _changeImageCount(-1) : null,
                icon: const Icon(Icons.remove),
                label: const Text('减少图片'),
              ),
              FilledButton.icon(
                onPressed: _imageCount < 8 ? () => _changeImageCount(1) : null,
                icon: const Icon(Icons.add),
                label: const Text('增加图片'),
              ),
              Chip(
                avatar: const Icon(Icons.photo_library_outlined, size: 18),
                label: Text('图片数：$_imageCount'),
              ),
              Chip(
                avatar: const Icon(Icons.filter_1, size: 18),
                label: Text('当前页：${_currentPage + 1}'),
              ),
              Chip(
                avatar: const Icon(Icons.touch_app_outlined, size: 18),
                label: Text(
                  _lastTappedPage == null ? '未点击当前页' : '点击：$_lastTappedPage',
                ),
              ),
              FilterChip(
                avatar: const Icon(Icons.all_inclusive, size: 18),
                label: const Text('loop'),
                selected: _loop,
                onSelected: (selected) {
                  setState(() {
                    _loop = selected;
                  });
                },
              ),
              FilterChip(
                avatar: const Icon(Icons.radio_button_checked, size: 18),
                label: const Text('自定义 radius'),
                selected: _useCustomRadius,
                onSelected: (selected) {
                  setState(() {
                    _useCustomRadius = selected;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _controller.animateToPage(_currentPage - 1),
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('上一页'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _controller.animateToPage(_currentPage + 1),
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('下一页'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SliderTile(
            label: 'childWidth',
            value: _childWidth,
            min: 56,
            max: 180,
            divisions: 62,
            onChanged: (value) {
              setState(() {
                _childWidth = value;
              });
            },
          ),
          _SliderTile(
            label: 'childHeight',
            value: _childHeight,
            min: 56,
            max: 180,
            divisions: 62,
            onChanged: (value) {
              setState(() {
                _childHeight = value;
              });
            },
          ),
          _SliderTile(
            label: 'deviationRatio',
            value: _deviationRatio,
            min: 0,
            max: 2,
            divisions: 40,
            fractionDigits: 2,
            onChanged: (value) {
              setState(() {
                _deviationRatio = value;
              });
            },
          ),
          _SliderTile(
            label: 'minScale',
            value: _minScale,
            min: 0.3,
            max: 1,
            divisions: 70,
            fractionDigits: 2,
            onChanged: (value) {
              setState(() {
                _minScale = value;
              });
            },
          ),
          _SliderTile(
            label: 'padding.horizontal',
            value: _horizontalPadding,
            min: 0,
            max: 64,
            divisions: 32,
            onChanged: (value) {
              setState(() {
                _horizontalPadding = value;
              });
            },
          ),
          _SliderTile(
            label: 'padding.vertical',
            value: _verticalPadding,
            min: 0,
            max: 64,
            divisions: 32,
            onChanged: (value) {
              setState(() {
                _verticalPadding = value;
              });
            },
          ),
          _SliderTile(
            label: 'radius',
            value: _radius,
            min: 60,
            max: 220,
            divisions: 80,
            enabled: _useCustomRadius,
            onChanged: (value) {
              setState(() {
                _radius = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _SwiperCard extends StatelessWidget {
  const _SwiperCard({
    required this.index,
    required this.width,
    required this.height,
  });

  final int index;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFEF5350),
      const Color(0xFFFFA726),
      const Color(0xFFFFD54F),
      const Color(0xFF66BB6A),
      const Color(0xFF26A69A),
      const Color(0xFF42A5F5),
      const Color(0xFF5C6BC0),
      const Color(0xFFAB47BC),
    ];
    final color = colors[index % colors.length];

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        '${index + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.fractionDigits = 0,
    this.enabled = true,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int? divisions;
  final int fractionDigits;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: textStyle)),
              Text(value.toStringAsFixed(fractionDigits), style: textStyle),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(fractionDigits),
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
