import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PhysicalShapeWidget extends SingleChildRenderObjectWidget {
  /// Creates a physical model with an arbitrary shape clip.
  ///
  /// The [color] is required; physical things have a color.
  ///
  /// The [elevation] must be non-negative.
  const PhysicalShapeWidget({
    super.key,
    required this.clipper,
    this.clipBehavior = Clip.none,
    this.elevation = 0.0,
    required this.color,
    this.shadowColor = const Color(0xFF000000),
    super.child,
  }) : assert(elevation >= 0.0);

  /// Determines which clip to use.
  ///
  /// If the path in question is expressed as a [ShapeBorder] subclass,
  /// consider using the [ShapeBorderClipper] delegate class to adapt the
  /// shape for use with this widget.
  final ShapeBorderClipper clipper;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;

  /// The z-coordinate relative to the parent at which to place this physical
  /// object.
  ///
  /// The value is non-negative.
  final double elevation;

  /// The background color.
  final Color color;

  /// When elevation is non zero the color to use for the shadow color.
  final Color shadowColor;

  @override
  RenderPhysicalShape createRenderObject(BuildContext context) {
    return RenderPhysicalShape(
      clipper: clipper,
      clipBehavior: clipBehavior,
      elevation: elevation,
      color: color,
      shadowColor: shadowColor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPhysicalShape renderObject,
  ) {
    renderObject
      ..clipper = clipper
      ..clipBehavior = clipBehavior
      ..elevation = elevation
      ..color = color
      ..shadowColor = shadowColor;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ShapeBorderClipper>('clipper', clipper));
    properties.add(DoubleProperty('elevation', elevation));
    properties.add(ColorProperty('color', color));
    properties.add(ColorProperty('shadowColor', shadowColor));
  }
}

class RenderProxyBox extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin<RenderBox> {
  /// Creates a proxy render box.
  ///
  /// Proxy render boxes are rarely created directly because they proxy
  /// the render box protocol to [child]. Instead, consider using one of the
  /// subclasses.
  RenderProxyBox([RenderBox? child]) {
    this.child = child;
  }
}

abstract class _RenderCustomClip<T> extends RenderProxyBox {
  _RenderCustomClip({
    RenderBox? child,
    ShapeBorderClipper? clipper,
    Clip clipBehavior = Clip.antiAlias,
  }) : _clipper = clipper,
       _clipBehavior = clipBehavior,
       super(child);

  /// If non-null, determines which clip to use on the child.
  ShapeBorderClipper? get clipper => _clipper;
  ShapeBorderClipper? _clipper;
  set clipper(ShapeBorderClipper? newClipper) {
    if (_clipper == newClipper) {
      return;
    }
    final ShapeBorderClipper? oldClipper = _clipper;
    _clipper = newClipper;
    assert(newClipper != null || oldClipper != null);
    if (newClipper == null ||
        oldClipper == null ||
        newClipper.runtimeType != oldClipper.runtimeType ||
        newClipper.shouldReclip(oldClipper)) {
      _markNeedsClip();
    }
    if (attached) {
      oldClipper?.removeListener(_markNeedsClip);
      newClipper?.addListener(_markNeedsClip);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _clipper?.addListener(_markNeedsClip);
  }

  @override
  void detach() {
    _clipper?.removeListener(_markNeedsClip);
    super.detach();
  }

  void _markNeedsClip() {
    _clip = null;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  Path get _defaultClip;
  Path? _clip;

  Clip get clipBehavior => _clipBehavior;
  set clipBehavior(Clip value) {
    if (value != _clipBehavior) {
      _clipBehavior = value;
      markNeedsPaint();
    }
  }

  Clip _clipBehavior;

  @override
  void performLayout() {
    final Size? oldSize = hasSize ? size : null;
    super.performLayout();
    if (oldSize != size) {
      _clip = null;
    }
  }

  void _updateClip() {
    _clip ??= _clipper?.getClip(size) ?? _defaultClip;
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) {
    switch (clipBehavior) {
      case Clip.none:
        return null;
      case Clip.hardEdge:
      case Clip.antiAlias:
      case Clip.antiAliasWithSaveLayer:
        return _clipper?.getApproximateClipRect(size) ?? Offset.zero & size;
    }
  }

  Paint? _debugPaint;
  TextPainter? _debugText;
  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    assert(() {
      _debugPaint ??= Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          const Offset(10.0, 10.0),
          <Color>[
            const Color(0x00000000),
            const Color(0xFFFF00FF),
            const Color(0xFFFF00FF),
            const Color(0x00000000),
          ],
          <double>[0.25, 0.25, 0.75, 0.75],
          TileMode.repeated,
        )
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      _debugText ??= TextPainter(
        text: const TextSpan(
          text: '✂',
          style: TextStyle(color: Color(0xFFFF00FF), fontSize: 14.0),
        ),
        textDirection: TextDirection.rtl, // doesn't matter, it's one character
      )..layout();
      return true;
    }());
  }

  @override
  void dispose() {
    _debugText?.dispose();
    _debugText = null;
    super.dispose();
  }
}

abstract class _RenderPhysicalModelBase<T> extends _RenderCustomClip<T> {
  /// The [elevation] parameter must be non-negative.
  _RenderPhysicalModelBase({
    required super.child,
    required double elevation,
    required Color color,
    required Color shadowColor,
    super.clipBehavior = Clip.none,
    super.clipper,
  }) : assert(elevation >= 0.0),
       _elevation = elevation,
       _color = color,
       _shadowColor = shadowColor;

  /// The z-coordinate relative to the parent at which to place this material.
  ///
  /// The value is non-negative.
  ///
  /// If [debugDisableShadows] is set, this value is ignored and no shadow is
  /// drawn (an outline is rendered instead).
  double get elevation => _elevation;
  double _elevation;
  set elevation(double value) {
    assert(value >= 0.0);
    if (elevation == value) {
      return;
    }
    final bool didNeedCompositing = alwaysNeedsCompositing;
    _elevation = value;
    if (didNeedCompositing != alwaysNeedsCompositing) {
      markNeedsCompositingBitsUpdate();
    }
    markNeedsPaint();
  }

  /// The shadow color.
  Color get shadowColor => _shadowColor;
  Color _shadowColor;
  set shadowColor(Color value) {
    if (shadowColor == value) {
      return;
    }
    _shadowColor = value;
    markNeedsPaint();
  }

  /// The background color.
  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (color == value) {
      return;
    }
    _color = value;
    markNeedsPaint();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DoubleProperty('elevation', elevation));
    description.add(ColorProperty('color', color));
    description.add(ColorProperty('shadowColor', color));
  }
}

class RenderPhysicalShape extends _RenderPhysicalModelBase<Path> {
  /// Creates an arbitrary shape clip.
  ///
  /// The [color] and [clipper] parameters are required.
  ///
  /// The [elevation] parameter must be non-negative.
  RenderPhysicalShape({
    super.child,
    required ShapeBorderClipper super.clipper,
    super.clipBehavior,
    super.elevation = 0.0,
    required super.color,
    super.shadowColor = const Color(0xFF000000),
  }) : assert(elevation >= 0.0);

  @override
  Path get _defaultClip => Path()..addRect(Offset.zero & size);

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (_clipper != null) {
      _updateClip();
      assert(_clip != null);
      if (!_clip!.contains(position)) {
        return false;
      }
    }
    return super.hitTest(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      layer = null;
      return;
    }

    _updateClip();
    final Path offsetPath = _clip!.shift(offset);
    bool paintShadows = true;
    assert(() {
      if (debugDisableShadows) {
        if (elevation > 0.0) {
          context.canvas.drawPath(
            offsetPath,
            Paint()
              ..color = shadowColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = elevation * 2.0,
          );
        }
        paintShadows = false;
      }
      return true;
    }());

    final Canvas canvas = context.canvas;
    if (elevation != 0.0 && paintShadows) {
      canvas.drawShadow(offsetPath, shadowColor, elevation, color.a != 1.0);
    }
    final bool usesSaveLayer = clipBehavior == Clip.antiAliasWithSaveLayer;
    if (!usesSaveLayer) {
      canvas.drawPath(offsetPath, Paint()..color = color);

      if (clipper?.shape is OutlinedBorder) {
        final border = clipper?.shape as OutlinedBorder;
        canvas.drawPath(
          offsetPath,
          Paint()
            ..color = border.side.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = border.side.width * 2.0,
        );
      }
    }
    layer = context.pushClipPath(
      needsCompositing,
      offset,
      Offset.zero & size,
      _clip!,
      (PaintingContext context, Offset offset) {
        if (usesSaveLayer) {
          // If we want to avoid the bleeding edge artifact
          // (https://github.com/flutter/flutter/issues/18057#issue-328003931)
          // using saveLayer, we have to call drawPaint instead of drawPath as
          // anti-aliased drawPath will always have such artifacts.
          context.canvas.drawPaint(Paint()..color = color);
        }
        super.paint(context, offset);
      },
      oldLayer: layer as ClipPathLayer?,
      clipBehavior: clipBehavior,
    );

    assert(() {
      layer?.debugCreator = debugCreator;
      return true;
    }());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(
      DiagnosticsProperty<ShapeBorderClipper>('clipper', clipper),
    );
  }

  Path _insetPath(Path src, double inset) {
    final metrics = src.computeMetrics();
    final result = Path();

    for (final m in metrics) {
      final extract = m.extractPath(0.0, m.length);
      result.addPath(extract.shift(Offset(inset, inset)), Offset.zero);
    }

    return result;
  }
}
