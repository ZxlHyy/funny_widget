import 'package:flutter/material.dart';
import 'package:funny_widget/widget/clipper/physical_shape.dart';

import 'trigger_border.dart';

enum ClipperShape {
  ///三角
  trigger,

  ///五角星
  star,

  ///圆型
  circle,

  ///切角
  beveled,

  ///连续矩形
  continuous,

  ///圆角矩形
  rounded,

  ///体育场，胶囊型
  stadium,

  ///自定义，需设置customShape
  custom,
}

class ClipperView extends StatelessWidget {
  const ClipperView({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.shape,
    this.elevation = 0.0,
    this.shadowColor = Colors.black,
    this.starValleyRounding = 0.0,
    this.starInnerRadiusRatio = 0.4,
    this.starPointRounding = 0,
    this.starPoints = 5,
    this.starRotation = 0,
    this.radius = 20,
    this.eccentricity = 0.0,
    this.clipBehavior = Clip.none,
    this.child,
    this.customShape,
    this.side = BorderSide.none,
  });

  final double width;
  final double height;
  final Color color;

  /// 形状类型：[ClipperShape.trigger], [ClipperShape.star], [ClipperShape.circle], [ClipperShape.beveled], [ClipperShape.continuous], [ClipperShape.rounded], [ClipperShape.stadium], [ClipperShape.custom]
  final ClipperShape shape;
  final double elevation;
  final Color shadowColor;

  /// 五角星参数
  /// 内角的圆润程度
  final double starValleyRounding;

  /// 五角星内角半径
  final double starInnerRadiusRatio;

  /// 尖角的圆润程度
  final double starPointRounding;

  /// 五角星顶点数
  final double starPoints;

  /// 五角星旋转角度
  final double starRotation;

  /// 有圆角的圆角
  final double radius;

  /// [ClipperShape.circle]中圆到椭圆的离心率0.0-1.0
  final double eccentricity;
  final Clip clipBehavior;
  final Widget? child;

  /// 自定义形状，[ClipperShape.custom]需设置此参数
  final ShapeBorder? customShape;
  final BorderSide side;

  @override
  Widget build(BuildContext context) {
    final ShapeBorder shapeBorder;
    switch (shape) {
      case ClipperShape.trigger:
        shapeBorder = TriangleBorder(side: side);
        break;
      case ClipperShape.star:
        shapeBorder = StarBorder(
          side: side,
          valleyRounding: starValleyRounding,
          innerRadiusRatio: starInnerRadiusRatio,
          pointRounding: starPointRounding,
          points: starPoints,
          rotation: starRotation,
        );
        break;
      case ClipperShape.circle:
        shapeBorder = CircleBorder(side: side, eccentricity: eccentricity);
        break;
      case ClipperShape.beveled:
        shapeBorder = BeveledRectangleBorder(
          side: side,
          borderRadius: BorderRadius.circular(radius),
        );
        break;
      case ClipperShape.continuous:
        shapeBorder = ContinuousRectangleBorder(
          side: side,
          borderRadius: BorderRadius.circular(radius),
        );
        break;
      case ClipperShape.rounded:
        shapeBorder = RoundedRectangleBorder(
          side: side,
          borderRadius: BorderRadius.circular(radius),
        );
        break;
      case ClipperShape.stadium:
        shapeBorder = StadiumBorder(side: side);
        break;
      case ClipperShape.custom:
        shapeBorder = customShape!;
        break;
    }
    return PhysicalShapeWidget(
      elevation: elevation,
      shadowColor: shadowColor,
      clipper: ShapeBorderClipper(shape: shapeBorder),
      clipBehavior: clipBehavior,
      color: color,
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}
