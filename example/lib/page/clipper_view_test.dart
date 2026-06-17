import 'package:flutter/material.dart';
import 'package:funny_widget/funny_widget.dart';
import 'package:funny_widget_example/clipper/custom_clipper.dart';

class ClipperViewTest extends StatefulWidget {
  const ClipperViewTest({super.key});

  @override
  State<ClipperViewTest> createState() => _ClipperViewTestState();
}

class _ClipperViewTestState extends State<ClipperViewTest> {
  var width = 100.0;
  var height = 100.0;
  var color = const Color(0xFFFB8C00);
  var shape = ClipperShape.trigger;
  var elevation = 5.0;
  var shadowColor = const Color(0xFF00897B);
  var starValleyRounding = 0.0;
  var starInnerRadiusRatio = 0.4;
  var starPointRounding = 0.0;
  var starPoints = 5.0;
  var starRotation = 0.0;
  var radius = 20.0;
  var borderWidth = 0.0;

  void changeWidth(double value) {
    width = value;
    setState(() {});
  }

  void changeElevation(double value) {
    elevation = value;
    setState(() {});
  }

  void changeHeight(double value) {
    height = value;
    setState(() {});
  }

  void changeShape(ClipperShape value) {
    shape = value;
    setState(() {});
  }

  void changeStarValleyRounding(double value) {
    if (value + starPointRounding > 1.0) {
      starPointRounding = 1.0 - value;
      // return;
    }
    starValleyRounding = value;
    setState(() {});
  }

  void changeStarInnerRadiusRatio(double value) {
    starInnerRadiusRatio = value;
    setState(() {});
  }

  void changeStarPointRounding(double value) {
    if (value + starValleyRounding > 1.0) {
      starValleyRounding = 1.0 - value;
      // return;
    }
    starPointRounding = value;
    setState(() {});
  }

  void changeStarPoints(double value) {
    starPoints = value;
    setState(() {});
  }

  void changeStarRotation(double value) {
    starRotation = value;
    setState(() {});
  }

  void changeRadius(double value) {
    radius = value;
    setState(() {});
  }

  void changeColor(Color value) {
    color = value;
    setState(() {});
  }

  void changeShadowColor(Color value) {
    shadowColor = value;
    setState(() {});
  }

  void changeBorderWidth(double value) {
    borderWidth = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ClipperViewTest")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10,),
            ClipperView(
              width: width,
              height: height,
              color: color,
              shape: shape,
              elevation: elevation,
              shadowColor: shadowColor,
              starValleyRounding: starValleyRounding,
              starInnerRadiusRatio: starInnerRadiusRatio,
              starPointRounding: starPointRounding,
              starPoints: starPoints,
              starRotation: starRotation,
              radius: radius,
              side: BorderSide(width: borderWidth, color: Colors.green),
              clipBehavior: Clip.hardEdge,
              customShape: MyCustomShapeBorder(
                side: BorderSide(width: borderWidth, color: Colors.green),
              ),
              child: Image.network(
                'https://img0.baidu.com/it/u=2191392668,814349101&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=1399',
                width: width,
                height: height,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('width: '),
                  Expanded(
                    child: Slider(
                      min: 10.0,
                      max: 360.0,
                      value: width,
                      onChanged: changeWidth,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('height: '),
                  Expanded(
                    child: Slider(
                      min: 10.0,
                      max: 360.0,
                      value: height,
                      onChanged: changeHeight,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('elevation: '),
                  Expanded(
                    child: Slider(
                      min: 0.0,
                      max: 12.0,
                      value: elevation,
                      onChanged: changeElevation,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: .0),
              child: Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('shape: '),
                  ...ClipperShape.values.map(
                    (e) => TextButton(
                      onPressed: () {
                        changeShape(e);
                      },
                      style: TextButton.styleFrom(
                        side: e == shape
                            ? const BorderSide(color: Colors.lightBlue, width: 2)
                            : const BorderSide(color: Colors.grey),
                      ),
                      child: Text(e.name),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('starValleyRounding: '),
                  Expanded(
                    child: Slider(
                      min: 0.0,
                      max: 1.0,
                      value: starValleyRounding,
                      onChanged: changeStarValleyRounding,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('starInnerRadiusRatio: '),
                  Expanded(
                    child: Slider(
                      min: 0.0,
                      max: 1.0,
                      value: starInnerRadiusRatio,
                      onChanged: changeStarInnerRadiusRatio,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('starPointRounding: '),
                  Expanded(
                    child: Slider(
                      min: 0.0,
                      max: 1.0,
                      value: starPointRounding,
                      onChanged: changeStarPointRounding,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('starPoints: '),
                  Expanded(
                    child: Slider(
                      min: 2.0,
                      max: 12.0,
                      value: starPoints,
                      onChanged: changeStarPoints,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('starRotation: '),
                  Expanded(
                    child: Slider(
                      min: 0.0,
                      max: 360.0,
                      value: starRotation,
                      onChanged: changeStarRotation,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('radius: '),
                  Expanded(
                    child: Slider(
                      min: 0.0,
                      max: 30.0,
                      value: radius,
                      onChanged: changeRadius,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('borderWidth: '),
                  Expanded(
                    child: Slider(
                      min: 0.0,
                      max: 10.0,
                      value: borderWidth,
                      onChanged: changeBorderWidth,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
