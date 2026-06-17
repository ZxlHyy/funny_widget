# funny_widget

`funny_widget` provides a small set of animated Flutter widgets:

- `GroupPurchaseAvatar` for overlapping avatar stacks with optional count labels and fixed-window autoplay.
- `AvatarSphereWidget` for draggable, auto-rotating spherical avatar walls.
- `ClipperView` for rendering clipped widgets with built-in and custom `ShapeBorder` shapes.
- `Swiper3DWidget` for touch-driven 3D carousel layouts with controller support.

[![pub package](https://img.shields.io/pub/v/funny_widget.svg)](https://pub.dev/packages/funny_widget)

![swiper_3d](https://raw.githubusercontent.com/ZxlHyy/funny_widget/master/images/swiper_3d.gif)
![group_purchase_avatar](https://raw.githubusercontent.com/ZxlHyy/funny_widget/master/images/group_purchase_avatar.gif)
![avatar_sphere](https://raw.githubusercontent.com/ZxlHyy/funny_widget/master/images/avatar_sphere.gif)
![clipper_view](https://raw.githubusercontent.com/ZxlHyy/funny_widget/master/images/clipper_view.gif)

## Installation

```yaml
dependencies:
  funny_widget: ^0.0.2
```

## Usage

### GroupPurchaseAvatar

```dart
import 'package:flutter/material.dart';
import 'package:funny_widget/funny_widget.dart';

class AvatarStackExample extends StatelessWidget {
  const AvatarStackExample({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupPurchaseAvatar(
      avatars: const [
        'https://picsum.photos/seed/funny-widget-1/80/80',
        'https://picsum.photos/seed/funny-widget-2/80/80',
        'https://picsum.photos/seed/funny-widget-3/80/80',
        'https://picsum.photos/seed/funny-widget-4/80/80',
      ],
      size: 48,
      maxVisibleCount: 3,
    );
  }
}
```

### AvatarSphereWidget

```dart
class AvatarSphereExample extends StatelessWidget {
  const AvatarSphereExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AvatarSphereWidget(
        avatarUrls: const [
          'https://picsum.photos/seed/funny-widget-a/80/80',
          'https://picsum.photos/seed/funny-widget-b/80/80',
          'https://picsum.photos/seed/funny-widget-c/80/80',
          'https://picsum.photos/seed/funny-widget-d/80/80',
          'https://picsum.photos/seed/funny-widget-e/80/80',
          'https://picsum.photos/seed/funny-widget-f/80/80',
        ],
        radius: 140,
        avatarSize: 56,
      ),
    );
  }
}
```

### ClipperView

```dart
class ClipperViewExample extends StatelessWidget {
  const ClipperViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipperView(
      width: 120,
      height: 120,
      color: Colors.orange,
      shape: ClipperShape.star,
      elevation: 6,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      child: const Center(
        child: Icon(Icons.star, color: Colors.white, size: 48),
      ),
    );
  }
}
```

### Swiper3DWidget

```dart
class Swiper3DExample extends StatelessWidget {
  const Swiper3DExample({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Swiper3DController();

    return Swiper3DWidget(
      controller: controller,
      childWidth: 120,
      childHeight: 80,
      onPageChanged: (page) {},
      children: const [
        ColoredBox(color: Colors.red),
        ColoredBox(color: Colors.green),
        ColoredBox(color: Colors.blue),
      ],
    );
  }
}
```

See the `example/` app for interactive demos of every widget.
