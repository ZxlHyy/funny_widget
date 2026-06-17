import 'package:flutter/material.dart';
import 'package:funny_widget_example/page/avatar_sphere_demo.dart';
import 'package:funny_widget_example/page/clipper_view_test.dart';
import 'package:funny_widget_example/page/group_avatar_demo.dart';
import 'package:funny_widget_example/page/swiper_demo.dart';

void main() {
  runApp(const FunnyWidgetExampleApp());
}

class FunnyWidgetExampleApp extends StatelessWidget {
  const FunnyWidgetExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Funny Widget Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E6B58)),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = [
      _DemoEntry(
        title: '3D旋转',
        subtitle: '动态调试尺寸、偏移、缩放、间距、半径和循环',
        icon: Icons.view_carousel_outlined,
        builder: (_) => const Swiper3DDemoPage(),
      ),
      _DemoEntry(
        title: '团购头像',
        subtitle: '点击头像组增加人数，超过上限后重置',
        icon: Icons.group_outlined,
        builder: (_) => const GroupAvatarDemoPage(),
      ),
      _DemoEntry(
        title: '头像球',
        subtitle: '自动旋转的球形头像墙',
        icon: Icons.public_outlined,
        builder: (_) => const AvatarSphereDemoPage(),
      ),
      _DemoEntry(
        title: 'Clipper View',
        subtitle: '多形状裁剪与自定义 clipper 预览',
        icon: Icons.cut_outlined,
        builder: (_) => const ClipperViewTest(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Funny Widget 示例')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final demo = demos[index];
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            leading: Icon(demo.icon),
            title: Text(demo.title),
            subtitle: Text(demo.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: demo.builder));
            },
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemCount: demos.length,
      ),
    );
  }
}

class _DemoEntry {
  const _DemoEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}
