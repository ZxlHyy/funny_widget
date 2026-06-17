import 'dart:math';

import 'package:flutter/material.dart';

class Swiper3DController {
  _Swiper3DState? _state;

  /// 由 Widget 在 initState 中绑定
  void _attach(_Swiper3DState state) {
    _state = state;
  }

  /// 由 Widget 在 dispose 中解绑
  void _detach(_Swiper3DState state) {
    if (_state == state) {
      _state = null;
    }
  }

  void animateToPage(int page) {
    _state?.animateToPage(page);
  }

  void jumpToPage(int page) {
    _state?.jumpToPage(page);
  }
}

class Swiper3DWidget extends StatefulWidget {
  const Swiper3DWidget({
    super.key,
    this.controller,
    this.children = const [],
    this.childWidth = 80,
    this.childHeight = 80,
    this.deviationRatio = 1.0,
    this.minScale = 0.8,
    this.padding,
    this.radius,
    this.onPageChanged, // 添加页面切换回调
    this.loop = true, // 添加循环滚动支持
    this.onTap,
  });

  final Swiper3DController? controller;
  final List<Widget> children;
  final double childWidth;
  final double childHeight;
  final double deviationRatio;
  final double minScale;
  final EdgeInsets? padding;
  final double? radius;
  final ValueChanged<int>? onPageChanged;
  final bool loop;
  final ValueChanged<int>? onTap;

  @override
  State<StatefulWidget> createState() => _Swiper3DState();
}

class _Swiper3DState extends State<Swiper3DWidget>
    with SingleTickerProviderStateMixin {
  List<Point> childPointList = [];
  final slipRatio = 0.5;
  double startAngle = 0;
  double rotateAngle = 0.0;
  double targetAngle = 0.0; // 定义 targetAngle
  double downX = 0.0;
  double downAngle = 0.0;
  late Size size;
  double radius = 0.0;
  late AnimationController _controller;
  late Animation<double> animation;
  late double velocityX;
  int currentPage = 0;
  late int _lastPage; // 添加上一页记录

  // 添加一个 ValueNotifier 来监听角度变化
  late final ValueNotifier<double> _rotateNotifier;

  late double averageAngle;

  Duration animationDuration = const Duration(milliseconds: 300);
  DateTime? _lastTapDownTime; //防重点击，防止动画未结束卡住

  @override
  void initState() {
    widget.controller?._attach(this);
    super.initState();
    averageAngle = widget.children.isEmpty
        ? 0
        : (360 / widget.children.length).roundToDouble();
    _rotateNotifier = ValueNotifier(rotateAngle);
    _lastPage = currentPage;
    _controller = AnimationController(vsync: this, duration: animationDuration);

    animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(covariant Swiper3DWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.children.length != widget.children.length) {
      averageAngle = widget.children.isEmpty
          ? 0
          : (360 / widget.children.length).roundToDouble();
      currentPage = _normalizePage(currentPage);
      rotateAngle = currentPage * averageAngle;
      downAngle = rotateAngle;
      _rotateNotifier.value = rotateAngle;
      if (_lastPage != currentPage) {
        _lastPage = currentPage;
        widget.onPageChanged?.call(currentPage);
      }
    }
  }

  int _normalizePage(int page) {
    final count = widget.children.length;
    if (count == 0) return 0;

    if (widget.loop) {
      return ((page % count) + count) % count;
    } else {
      return page.clamp(0, count - 1);
    }
  }

  // 修改动画处理方法
  void _animateToPage(double targetAngle) {
    final Tween<double> tween = Tween<double>(
      begin: rotateAngle,
      end: targetAngle,
    );

    animation =
        tween.animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          )
          ..addListener(() {
            rotateAngle = animation.value;
            _rotateNotifier.value = rotateAngle;
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              // 处理循环逻辑
              if (widget.loop) {
                int actualPage = currentPage % widget.children.length;
                if (actualPage < 0) {
                  actualPage += widget.children.length;
                }
                currentPage = actualPage;
              } else {
                currentPage = currentPage.clamp(0, widget.children.length - 1);
              }

              rotateAngle = currentPage * averageAngle;
              downAngle = rotateAngle;
              _rotateNotifier.value = rotateAngle;

              if (_lastPage != currentPage) {
                _lastPage = currentPage;
                widget.onPageChanged?.call(currentPage);
              }
            }
          });

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _rotateNotifier.dispose(); // 记得释放资源
    _controller.dispose();
    super.dispose();
  }

  void animateToPage(int page) {
    final targetPage = _normalizePage(page);
    if (targetPage == currentPage) return;

    currentPage = targetPage;
    targetAngle = currentPage * averageAngle;

    _animateToPage(targetAngle);
  }

  void jumpToPage(int page) {
    final targetPage = _normalizePage(page);
    if (targetPage == currentPage) return;

    currentPage = targetPage;
    rotateAngle = currentPage * averageAngle;
    downAngle = rotateAngle;

    _rotateNotifier.value = rotateAngle;

    if (_lastPage != currentPage) {
      _lastPage = currentPage;
      widget.onPageChanged?.call(currentPage);
    }
  }

  List<Point> _childPointList({Size size = Size.zero}) {
    childPointList.clear();
    if (widget.children.isNotEmpty) {
      int count = widget.children.length;
      double averageAngle = 360 / count;
      radius = widget.radius ?? (size.width - widget.childWidth) / 2;
      for (int i = 0; i < count; i++) {
        double angle = startAngle + averageAngle * i - rotateAngle;
        var centerX = size.width / 2 + sin(radian(angle)) * radius;
        var centerY =
            size.height / 2 +
            cos(radian(angle)) * radius * cos(pi / 2 * widget.deviationRatio);
        var minScale = min(widget.minScale, 0.99);
        var scale =
            (1 - minScale) / 2 * (1 + cos(radian(angle - startAngle))) +
            minScale;
        childPointList.add(
          Point(
            centerX,
            centerY,
            widget.childWidth,
            widget.childHeight,
            centerX - widget.childWidth * scale / 2,
            centerY - widget.childHeight * scale / 2,
            centerX + widget.childWidth * scale / 2,
            centerY + widget.childHeight * scale / 2,
            scale,
            angle,
            i,
          ),
        );
      }
      childPointList.sort((a, b) {
        return a.scale.compareTo(b.scale);
      });
    }
    return childPointList;
  }

  @override
  Widget build(BuildContext context) {
    final children = List.generate(
      widget.children.length,
      (index) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () {},
        onTap: () {
          // 检查动画是否正在执行
          if (_controller.isAnimating) {
            return;
          }
          // 防抖处理
          if (_lastTapDownTime != null &&
              DateTime.now().difference(_lastTapDownTime!) <
                  animationDuration) {
            return;
          }
          _lastTapDownTime = DateTime.now();
          if (index != currentPage) {
            // print("当前页面：index: $index, currentPage: $currentPage");
            if (index - currentPage > 1) {
              currentPage--;
            } else if (index - currentPage < -1) {
              currentPage++;
            } else {
              currentPage = index;
            }

            targetAngle = currentPage * averageAngle;

            _animateToPage(targetAngle);
          } else {
            widget.onTap?.call(index);
          }
        },
        child: KeyedSubtree(
          key: ValueKey('item_$index'),
          child: widget.children[index],
        ),
      ),
    );

    return ValueListenableBuilder<double>(
      valueListenable: _rotateNotifier, // 使用角度通知器
      builder: (context, rotateValue, child) {
        return ClipRect(
          child: SizedBox(
            height:
                widget.childHeight +
                (widget.padding?.top ?? 0) +
                (widget.padding?.bottom ?? 0),
            child: OverflowBox(
              maxHeight:
                  widget.childHeight +
                  (widget.padding?.top ?? 0) +
                  (widget.padding?.bottom ?? 0) +
                  56,
              alignment: Alignment.center,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  size = Size(constraints.maxWidth, constraints.maxHeight);

                  // 移到这里创建子项列表
                  final stackChildren = _childPointList(size: size)
                      .map(
                        (Point point) => Positioned(
                          key: ValueKey('position_${point.index}'),
                          width: point.width,
                          height: point.height,
                          left: point.centerX - point.width / 2,
                          top: point.centerY - point.height / 2,
                          child: RepaintBoundary(
                            child: Transform.scale(
                              scale: point.scale,
                              child: Container(
                                foregroundDecoration: BoxDecoration(
                                  color: Colors.black.withValues(
                                    alpha: 1 - point.scale,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: children[point.index],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList();

                  return GestureDetector(
                    onHorizontalDragDown: (DragDownDetails details) {},
                    onHorizontalDragStart: (DragStartDetails details) {
                      downAngle = rotateAngle;
                      downX = details.globalPosition.dx;
                    },
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      var updateX = details.globalPosition.dx;
                      rotateAngle = (downX - updateX) * slipRatio + downAngle;
                      if (!widget.loop && widget.children.isNotEmpty) {
                        rotateAngle = rotateAngle.clamp(
                          0,
                          (widget.children.length - 1) * averageAngle,
                        );
                      }
                      // print("斤斤计较急急急急急急急急急急急急:$rotateAngle");
                      _rotateNotifier.value =
                          rotateAngle; // 直接更新通知器的值，不需要 setState
                      currentPage = (rotateAngle / averageAngle).round();
                    },
                    onHorizontalDragEnd: (DragEndDetails details) {
                      // print("onHorizontalDragEnd");
                      velocityX = details.velocity.pixelsPerSecond.dx;

                      if (currentPage == _lastPage) {
                        if (velocityX.abs() > widget.childWidth / 2) {
                          if (velocityX > 0) {
                            if (widget.loop || currentPage > 0) {
                              currentPage--;
                            }
                          } else {
                            if (widget.loop ||
                                currentPage < widget.children.length - 1) {
                              currentPage++;
                            }
                          }
                        }
                      }
                      if (!widget.loop && widget.children.isNotEmpty) {
                        currentPage = currentPage.clamp(
                          0,
                          widget.children.length - 1,
                        );
                      }
                      targetAngle = currentPage * averageAngle;

                      _animateToPage(targetAngle);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: CustomPaint(
                      size: size,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: stackChildren,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class Point {
  Point(
    this.centerX,
    this.centerY,
    this.width,
    this.height,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.scale,
    this.angle,
    this.index,
  );

  double centerX;
  double centerY;
  double width;
  double height;
  double left;
  double top;
  double right;
  double bottom;
  double scale;
  double angle;
  int index;
}

double radian(double angle) {
  return angle * pi / 180;
}
