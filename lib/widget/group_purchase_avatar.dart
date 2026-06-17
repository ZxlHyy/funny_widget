import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef AvatarImageBuilder =
    Widget Function(BuildContext context, String imageUrl, double size);

enum GroupAvatarMode { dense, fixed }

class GroupPurchaseAvatar extends StatefulWidget {
  const GroupPurchaseAvatar({
    super.key,
    required this.avatars,
    this.imageBuilder,
    this.size = 40,
    this.overlapRatio = 0.45,
    this.maxVisibleCount = 4,
    this.mode = GroupAvatarMode.dense,
    this.duration = const Duration(milliseconds: 500),
    this.width,
    this.autoPlay = true,
    this.interval = const Duration(seconds: 1),
    this.loop = true,
    this.fixedCount = 3,
    this.textDirection,
    this.showExtraCount = true,
    this.scaleSpacingToFitWidth = true,
    this.borderColor = Colors.white,
    this.borderWidth = 3,
    this.border,
    this.useBoxShadow = true,
    this.extraBackgroundColor = const Color(0xFF1E6B58),
    this.extraTextStyle,
    this.imageHeaders = const {'User-Agent': 'Mozilla/5.0'},
    this.errorBuilder,
    this.placeholder,
    this.useDefaultPlaceholder = true,
    this.placeholderBuilder,
  });

  final List<String> avatars;
  final AvatarImageBuilder? imageBuilder;
  final double size;
  final double overlapRatio;
  final int maxVisibleCount;
  final GroupAvatarMode mode;
  final Duration duration;
  final double? width;
  final bool autoPlay;
  final Duration interval;
  final bool loop;
  final int fixedCount;
  final TextDirection? textDirection;
  final bool showExtraCount;
  final bool scaleSpacingToFitWidth;
  final Color borderColor;
  final double borderWidth;
  final BoxBorder? border;
  final bool useBoxShadow;
  final Color extraBackgroundColor;
  final TextStyle? extraTextStyle;
  final Map<String, String>? imageHeaders;
  final ImageErrorWidgetBuilder? errorBuilder;
  final String? placeholder;
  final bool useDefaultPlaceholder;
  final WidgetBuilder? placeholderBuilder;

  @override
  State<GroupPurchaseAvatar> createState() => _GroupPurchaseAvatarState();
}

class _GroupPurchaseAvatarState extends State<GroupPurchaseAvatar>
    with SingleTickerProviderStateMixin {
  late List<String> _avatars;
  late final AnimationController _controller;
  late final Animation<double> _curve;

  Timer? _timer;
  int _startIndex = 0;

  bool get _canAnimate =>
      widget.mode == GroupAvatarMode.fixed &&
      widget.autoPlay &&
      widget.fixedCount > 0 &&
      _avatars.length > widget.fixedCount;

  int get _safeMaxVisibleCount => math.max(0, widget.maxVisibleCount);

  int get _safeFixedCount => math.max(0, widget.fixedCount);

  double get _safeSize => math.max(0, widget.size);

  @override
  void initState() {
    super.initState();
    _avatars = List<String>.from(widget.avatars);
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.addStatusListener(_handleAnimationStatus);
    _scheduleNext();
  }

  @override
  void didUpdateWidget(covariant GroupPurchaseAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.avatars != widget.avatars ||
        oldWidget.fixedCount != widget.fixedCount) {
      _avatars = List<String>.from(widget.avatars);
      _startIndex = _normalizedStartIndex(_startIndex);
      if (!_canAnimate) {
        _controller.reset();
      }
    }
    if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.interval != widget.interval ||
        oldWidget.loop != widget.loop ||
        oldWidget.mode != widget.mode ||
        oldWidget.fixedCount != widget.fixedCount ||
        oldWidget.avatars != widget.avatars) {
      _timer?.cancel();
      _scheduleNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_safeSize == 0 || _avatars.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (widget.mode) {
      case GroupAvatarMode.dense:
        return _buildDense(context);
      case GroupAvatarMode.fixed:
        return _buildFixed(context);
    }
  }

  Widget _buildDense(BuildContext context) {
    final visibleCount = math.min(_avatars.length, _safeMaxVisibleCount);
    if (visibleCount == 0) {
      return const SizedBox.shrink();
    }

    final extraCount = _avatars.length - visibleCount;
    return _buildAvatarStack(
      context: context,
      avatars: _avatars.take(visibleCount).toList(),
      labelIndex: widget.showExtraCount && extraCount > 0
          ? visibleCount - 1
          : null,
      label: '+$extraCount',
      width: _stackWidth(visibleCount),
      step: _stackStep(visibleCount),
      animateNewLast: true,
    );
  }

  Widget _buildFixed(BuildContext context) {
    final fixedCount = _safeFixedCount;
    if (fixedCount == 0) {
      return const SizedBox.shrink();
    }

    final visibleCount = math.min(_avatars.length, fixedCount);
    if (_avatars.length <= fixedCount || !_canAnimate) {
      final start = widget.loop
          ? _normalizedStartIndex(_startIndex)
          : _startIndex;
      final visibleAvatars = _windowAvatars(start, visibleCount);
      return _buildAvatarStack(
        context: context,
        avatars: visibleAvatars,
        width: _fixedWidth(visibleCount),
        step: _baseStep,
      );
    }

    final width = _fixedWidth(fixedCount);
    return SizedBox(
      width: width,
      height: _safeSize,
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, _) {
          final t = _curve.value;
          final display = _animatedWindowAvatars();
          final ltr = _isLtr(context);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (var index = 0; index < display.length; index++)
                _buildFixedPositionedAvatar(
                  context: context,
                  imageUrl: display[index],
                  index: index,
                  t: t,
                  ltr: ltr,
                  fixedCount: fixedCount,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatarStack({
    required BuildContext context,
    required List<String> avatars,
    required double width,
    required double step,
    int? labelIndex,
    String? label,
    bool animateNewLast = false,
  }) {
    final ltr = _isLtr(context);
    return SizedBox(
      width: width,
      height: _safeSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = 0; index < avatars.length; index++)
            AnimatedPositioned(
              key: _avatarKey(avatars[index], index, 'dense'),
              duration: widget.duration,
              curve: Curves.easeInOut,
              left: ltr ? step * index : null,
              right: ltr ? null : step * index,
              child: _maybeScaleNewLast(
                enabled: animateNewLast && index == avatars.length - 1,
                child: _buildCircleAvatar(
                  context: context,
                  imageUrl: avatars[index],
                  label: labelIndex == index ? label : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFixedPositionedAvatar({
    required BuildContext context,
    required String imageUrl,
    required int index,
    required double t,
    required bool ltr,
    required int fixedCount,
  }) {
    final step = _baseStep;
    final isEntering = index == fixedCount;
    final baseLeft = ltr ? index * step : (fixedCount - 1 - index) * step;
    final left = isEntering
        ? (ltr ? (fixedCount - 1) * step : 0.0)
        : baseLeft + (ltr ? -step * t : step * t);

    Widget avatar = _buildCircleAvatar(context: context, imageUrl: imageUrl);
    if (index == 0) {
      avatar = Opacity(opacity: (1 - t).clamp(0.0, 1.0), child: avatar);
    }
    if (isEntering) {
      avatar = Transform.scale(
        scale: t.clamp(0.0, 1.0),
        alignment: Alignment.center,
        child: avatar,
      );
    }

    return Positioned(
      key: _avatarKey(imageUrl, index, 'fixed_$_startIndex'),
      left: left,
      top: 0,
      child: avatar,
    );
  }

  Widget _maybeScaleNewLast({required bool enabled, required Widget child}) {
    if (!enabled) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey<Key?>(child.key),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }

  Widget _buildCircleAvatar({
    required BuildContext context,
    required String imageUrl,
    String? label,
  }) {
    return _GroupAvatarCircle(
      imageUrl: imageUrl,
      size: _safeSize,
      label: label,
      imageBuilder: widget.imageBuilder,
      border: widget.border,
      borderColor: widget.borderColor,
      borderWidth: widget.borderWidth,
      useBoxShadow: widget.useBoxShadow,
      extraBackgroundColor: widget.extraBackgroundColor,
      extraTextStyle: widget.extraTextStyle,
      imageHeaders: widget.imageHeaders,
      errorBuilder: widget.errorBuilder,
      placeholder: widget.placeholder,
      useDefaultPlaceholder: widget.useDefaultPlaceholder,
      placeholderBuilder: widget.placeholderBuilder,
    );
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }

    _controller.reset();
    setState(() {
      _startIndex = widget.loop
          ? (_startIndex + 1) % _avatars.length
          : math.min(
              _startIndex + 1,
              math.max(0, _avatars.length - _safeFixedCount),
            );
    });
    _scheduleNext();
  }

  void _scheduleNext() {
    _timer?.cancel();
    if (!_canAnimate) {
      return;
    }

    _timer = Timer(widget.interval, () {
      if (mounted) {
        _tryStartNext();
      }
    });
  }

  void _tryStartNext() {
    if (!_canAnimate || _controller.isAnimating) {
      return;
    }

    if (widget.loop || _startIndex + _safeFixedCount < _avatars.length) {
      _controller.forward();
    }
  }

  List<String> _animatedWindowAvatars() {
    final length = _controller.isAnimating
        ? _safeFixedCount + 1
        : _safeFixedCount;
    return _windowAvatars(_startIndex, length);
  }

  List<String> _windowAvatars(int start, int length) {
    if (_avatars.isEmpty || length <= 0) {
      return const [];
    }

    final result = <String>[];
    for (var index = 0; index < length; index++) {
      final avatarIndex = start + index;
      if (widget.loop) {
        result.add(_avatars[avatarIndex % _avatars.length]);
      } else if (avatarIndex < _avatars.length) {
        result.add(_avatars[avatarIndex]);
      }
    }
    return result;
  }

  int _normalizedStartIndex(int index) {
    if (_avatars.isEmpty) {
      return 0;
    }

    if (widget.loop) {
      return index % _avatars.length;
    }

    return index.clamp(0, math.max(0, _avatars.length - _safeFixedCount));
  }

  bool _isLtr(BuildContext context) {
    return (widget.textDirection ?? Directionality.of(context)) ==
        TextDirection.ltr;
  }

  double get _baseStep {
    final overlapRatio = widget.overlapRatio.clamp(0.0, 1.0);
    return _safeSize * (1 - overlapRatio);
  }

  double _stackStep(int visibleCount) {
    if (visibleCount <= 1 ||
        widget.width == null ||
        !widget.scaleSpacingToFitWidth) {
      return _baseStep;
    }

    return math.max(0, (widget.width! - _safeSize) / (visibleCount - 1));
  }

  double _stackWidth(int visibleCount) {
    if (widget.width != null) {
      return math.max(0, widget.width!);
    }

    return _fixedWidth(visibleCount);
  }

  double _fixedWidth(int visibleCount) {
    if (visibleCount <= 1) {
      return _safeSize;
    }

    return _safeSize + _baseStep * (visibleCount - 1);
  }

  Key _avatarKey(String imageUrl, int index, String scope) {
    if (imageUrl.isEmpty) {
      return ValueKey('group_purchase_avatar_${scope}_$index');
    }
    return ValueKey('group_purchase_avatar_${scope}_${index}_$imageUrl');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }
}

class _GroupAvatarCircle extends StatelessWidget {
  const _GroupAvatarCircle({
    required this.imageUrl,
    required this.size,
    required this.borderColor,
    required this.borderWidth,
    required this.extraBackgroundColor,
    required this.useBoxShadow,
    required this.useDefaultPlaceholder,
    this.border,
    this.label,
    this.imageBuilder,
    this.extraTextStyle,
    this.imageHeaders,
    this.errorBuilder,
    this.placeholder,
    this.placeholderBuilder,
  });

  final String imageUrl;
  final double size;
  final String? label;
  final AvatarImageBuilder? imageBuilder;
  final BoxBorder? border;
  final Color borderColor;
  final double borderWidth;
  final bool useBoxShadow;
  final Color extraBackgroundColor;
  final TextStyle? extraTextStyle;
  final Map<String, String>? imageHeaders;
  final ImageErrorWidgetBuilder? errorBuilder;
  final String? placeholder;
  final bool useDefaultPlaceholder;
  final WidgetBuilder? placeholderBuilder;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle =
        extraTextStyle ??
        const TextStyle(color: Colors.white, fontWeight: FontWeight.w700);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: useBoxShadow
            ? const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
        color: label == null ? null : extraBackgroundColor,
      ),
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border ?? Border.all(color: borderColor, width: borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: label == null
          ? _buildImage(context)
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: size * 0.12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label!, style: defaultTextStyle),
              ),
            ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder(context);
    }

    final image = imageBuilder?.call(context, imageUrl, size);
    if (image != null) {
      return SizedBox.expand(child: image);
    }

    return Image.network(
      imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      headers: imageHeaders,
      errorBuilder: errorBuilder ?? _defaultErrorBuilder,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final placeholderWidget = placeholderBuilder?.call(context);
    if (placeholderWidget != null) {
      return SizedBox.expand(child: placeholderWidget);
    }

    if (placeholder != null) {
      return Image.asset(
        placeholder!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    if (!useDefaultPlaceholder) {
      return SizedBox(width: size, height: size);
    }

    return _defaultAvatarIcon();
  }

  Widget _defaultErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return _defaultAvatarIcon();
  }

  Widget _defaultAvatarIcon() {
    return ColoredBox(
      color: extraBackgroundColor,
      child: Icon(Icons.person, color: Colors.white, size: size * 0.52),
    );
  }
}
