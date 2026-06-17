import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef AvatarSphereImageBuilder =
    Widget Function(BuildContext context, String imageUrl, double size);

typedef AvatarSphereTapCallback = void Function(int index, String imageUrl);

class AvatarSphereWidget extends StatefulWidget {
  const AvatarSphereWidget({
    super.key,
    required this.avatarUrls,
    this.imageBuilder,
    this.onAvatarTap,
    this.radius = 140,
    this.avatarSize = 56,
    this.padding = 56,
    this.autoRotateSpeed = 0.002,
    this.dragSensitivity = 0.005,
    this.inertiaFriction = 0.985,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.imageHeaders = const {'User-Agent': 'Mozilla/5.0'},
    this.errorBuilder,
  });

  final List<String> avatarUrls;
  final AvatarSphereImageBuilder? imageBuilder;
  final AvatarSphereTapCallback? onAvatarTap;
  final double radius;
  final double avatarSize;
  final double padding;
  final double autoRotateSpeed;
  final double dragSensitivity;
  final double inertiaFriction;
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;
  final Map<String, String>? imageHeaders;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  State<AvatarSphereWidget> createState() => _AvatarSphereWidgetState();
}

class _AvatarSphereWidgetState extends State<AvatarSphereWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<_SpherePoint> _items = [];
  final Map<String, ImageProvider> _imageCache = {};
  var _rotation = _Matrix3.identity();

  Offset _velocity = Offset.zero;
  bool _userTouching = false;
  bool _inertiaActive = false;

  @override
  void initState() {
    super.initState();
    _buildImageCache();
    _initSphere();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant AvatarSphereWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarUrls != widget.avatarUrls ||
        oldWidget.radius != widget.radius ||
        oldWidget.avatarSize != widget.avatarSize ||
        oldWidget.imageHeaders != widget.imageHeaders) {
      _buildImageCache();
      _initSphere();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _buildImageCache() {
    _imageCache
      ..clear()
      ..addEntries(
        widget.avatarUrls.map(
          (url) =>
              MapEntry(url, NetworkImage(url, headers: widget.imageHeaders)),
        ),
      );
  }

  void _initSphere() {
    final count = widget.avatarUrls.length;
    final radius = widget.radius;

    _items.clear();
    if (count == 0) {
      return;
    }

    for (var index = 0; index < count; index++) {
      final phi = math.acos(-1.0 + (2.0 * index + 1.0) / count);
      final theta = math.sqrt(count * math.pi) * phi;

      _items.add(
        _SpherePoint(
          index: index,
          imageUrl: widget.avatarUrls[index],
          x: radius * math.sin(phi) * math.cos(theta),
          y: radius * math.sin(phi) * math.sin(theta),
          z: radius * math.cos(phi),
        ),
      );
    }

    _updateSphere();
  }

  void _onTick(Duration elapsed) {
    if (_userTouching || !mounted) {
      return;
    }

    setState(() {
      if (_inertiaActive) {
        _applyDragRotation(_velocity);
        _velocity *= widget.inertiaFriction;

        if (_velocity.distance < 0.001) {
          _velocity = Offset.zero;
          _inertiaActive = false;
        }
      } else {
        _rotation = _Matrix3.rotationAxis(
          1,
          1,
          0,
          widget.autoRotateSpeed,
        ).multiply(_rotation);
      }

      _updateSphere();
    });
  }

  void _updateSphere() {
    for (final point in _items) {
      final rotated = _rotation.transform(point.x, point.y, point.z);

      point
        ..currentX = rotated.x
        ..currentY = rotated.y
        ..currentZ = rotated.z;
    }

    _items.sort((a, b) => a.currentZ.compareTo(b.currentZ));
  }

  void _applyDragRotation(Offset delta) {
    final distance = delta.distance;
    if (distance == 0) {
      return;
    }

    final angle = distance * widget.dragSensitivity;
    final axisX = -delta.dy / distance;
    final axisY = delta.dx / distance;
    _rotation = _Matrix3.rotationAxis(
      axisX,
      axisY,
      0,
      angle,
    ).multiply(_rotation);
  }

  void _handlePanStart(DragStartDetails details) {
    _userTouching = true;
    _inertiaActive = false;
    _velocity = Offset.zero;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _applyDragRotation(details.delta);
      _updateSphere();
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    _userTouching = false;
    _inertiaActive = true;
    _velocity = details.velocity.pixelsPerSecond / 1000;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2 + widget.padding;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final item in _items)
              _PositionedAvatar(
                key: ValueKey(item.index),
                item: item,
                sphereSize: size,
                radius: widget.radius,
                avatarSize: widget.avatarSize,
                borderColor: widget.borderColor,
                borderWidth: widget.borderWidth,
                backgroundColor: widget.backgroundColor,
                imageProvider: _imageCache[item.imageUrl],
                imageBuilder: widget.imageBuilder,
                errorBuilder: widget.errorBuilder,
                onTap: widget.onAvatarTap == null
                    ? null
                    : () => widget.onAvatarTap!(item.index, item.imageUrl),
              ),
          ],
        ),
      ),
    );
  }
}

class _PositionedAvatar extends StatelessWidget {
  const _PositionedAvatar({
    super.key,
    required this.item,
    required this.sphereSize,
    required this.radius,
    required this.avatarSize,
    required this.borderColor,
    required this.borderWidth,
    required this.backgroundColor,
    required this.imageProvider,
    required this.imageBuilder,
    required this.errorBuilder,
    required this.onTap,
  });

  final _SpherePoint item;
  final double sphereSize;
  final double radius;
  final double avatarSize;
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;
  final ImageProvider? imageProvider;
  final AvatarSphereImageBuilder? imageBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final depthScale = ((item.currentZ + radius * 1.5) / (radius * 3)).clamp(
      0.0,
      1.0,
    );
    final visualScale = depthScale.clamp(0.5, 1.2);
    final visualSize = avatarSize * visualScale;
    final opacity = depthScale.clamp(0.3, 1.0);

    return Positioned(
      left: sphereSize / 2 + item.currentX - visualSize / 2,
      top: sphereSize / 2 + item.currentY - visualSize / 2,
      width: visualSize,
      height: visualSize,
      child: Opacity(
        opacity: opacity,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: _SphereAvatar(
            imageUrl: item.imageUrl,
            size: visualSize,
            imageProvider: imageProvider,
            imageBuilder: imageBuilder,
            borderColor: borderColor,
            borderWidth: borderWidth,
            backgroundColor: backgroundColor,
            errorBuilder: errorBuilder,
          ),
        ),
      ),
    );
  }
}

class _SphereAvatar extends StatelessWidget {
  const _SphereAvatar({
    required this.imageUrl,
    required this.size,
    required this.borderColor,
    required this.borderWidth,
    required this.backgroundColor,
    required this.imageProvider,
    required this.imageBuilder,
    required this.errorBuilder,
  });

  final String imageUrl;
  final double size;
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;
  final ImageProvider? imageProvider;
  final AvatarSphereImageBuilder? imageBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(context),
    );
  }

  Widget _buildImage(BuildContext context) {
    final image = imageBuilder?.call(context, imageUrl, size);
    if (image != null) {
      return SizedBox.expand(child: image);
    }

    final provider = imageProvider;
    if (provider == null) {
      return _defaultErrorBuilder(context, '', null);
    }

    return Image(
      image: provider,
      width: size,
      height: size,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: errorBuilder ?? _defaultErrorBuilder,
    );
  }

  Widget _defaultErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return ColoredBox(
      color: const Color(0xFF1E6B58),
      child: Icon(Icons.person, color: Colors.white, size: size * 0.52),
    );
  }
}

class _SpherePoint {
  _SpherePoint({
    required this.index,
    required this.imageUrl,
    required this.x,
    required this.y,
    required this.z,
  }) : currentX = x,
       currentY = y,
       currentZ = z;

  final int index;
  final String imageUrl;
  final double x;
  final double y;
  final double z;
  double currentX;
  double currentY;
  double currentZ;
}

class _Vector3 {
  const _Vector3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;
}

class _Matrix3 {
  const _Matrix3(this.values);

  factory _Matrix3.identity() {
    return const _Matrix3([1, 0, 0, 0, 1, 0, 0, 0, 1]);
  }

  factory _Matrix3.rotationAxis(
    double axisX,
    double axisY,
    double axisZ,
    double angle,
  ) {
    final length = math.sqrt(axisX * axisX + axisY * axisY + axisZ * axisZ);
    if (length == 0 || angle == 0) {
      return _Matrix3.identity();
    }

    final x = axisX / length;
    final y = axisY / length;
    final z = axisZ / length;
    final c = math.cos(angle);
    final s = math.sin(angle);
    final t = 1 - c;

    return _Matrix3([
      t * x * x + c,
      t * x * y - s * z,
      t * x * z + s * y,
      t * x * y + s * z,
      t * y * y + c,
      t * y * z - s * x,
      t * x * z - s * y,
      t * y * z + s * x,
      t * z * z + c,
    ]);
  }

  final List<double> values;

  _Vector3 transform(double x, double y, double z) {
    return _Vector3(
      values[0] * x + values[1] * y + values[2] * z,
      values[3] * x + values[4] * y + values[5] * z,
      values[6] * x + values[7] * y + values[8] * z,
    );
  }

  _Matrix3 multiply(_Matrix3 other) {
    final a = values;
    final b = other.values;

    return _Matrix3([
      a[0] * b[0] + a[1] * b[3] + a[2] * b[6],
      a[0] * b[1] + a[1] * b[4] + a[2] * b[7],
      a[0] * b[2] + a[1] * b[5] + a[2] * b[8],
      a[3] * b[0] + a[4] * b[3] + a[5] * b[6],
      a[3] * b[1] + a[4] * b[4] + a[5] * b[7],
      a[3] * b[2] + a[4] * b[5] + a[5] * b[8],
      a[6] * b[0] + a[7] * b[3] + a[8] * b[6],
      a[6] * b[1] + a[7] * b[4] + a[8] * b[7],
      a[6] * b[2] + a[7] * b[5] + a[8] * b[8],
    ]);
  }
}
