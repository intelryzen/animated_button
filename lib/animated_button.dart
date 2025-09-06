library animated_button;

import 'package:flutter/material.dart';
import 'package:gaimon/gaimon.dart';

/// Using [ShadowDegree] with values [ShadowDegree.dark] or [ShadowDegree.light]
/// to get a darker version of the used color.
/// [duration] in milliseconds
///
class AnimatedButton extends StatefulWidget {
  final Color color;
  final Widget child;
  final bool enabled;
  final double? width;
  final int duration;
  final double height;
  final Color disabledColor;
  final double borderRadius;
  final VoidCallback onPressed;
  final ShadowDegree shadowDegree;
  final bool hasBorder;

  const AnimatedButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.height = 40,
    this.width,
    this.duration = 70,
    this.enabled = true,
    this.borderRadius = 12,
    this.color = Colors.blue,
    this.disabledColor = Colors.grey,
    this.shadowDegree = ShadowDegree.light,
    this.hasBorder = false,
  }) : super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  static const Curve _curve = Curves.easeIn;
  static const double _shadowHeight = 4;
  final GlobalKey _buttonKey = GlobalKey();

  double _position = 4;

  @override
  Widget build(BuildContext context) {
    final double _height = widget.height - _shadowHeight;
    final bool isWidthInfinite = widget.width == double.infinity;

    return GestureDetector(
      key: _buttonKey,
      // width here is required for centering the button in parent
      child: Container(
        width: widget.width,
        height: _height + _shadowHeight,
        child: Stack(
          children: <Widget>[
            // background shadow serves as drop shadow
            // width is necessary for bottom shadow
            Positioned(
              bottom: 0,
              left: isWidthInfinite ? 0 : null,
              right: isWidthInfinite ? 0 : null,
              child: Container(
                height: _height,
                width: widget.width,
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? darken(widget.color, widget.shadowDegree)
                      : darken(widget.disabledColor, widget.shadowDegree),
                  borderRadius: _getBorderRadius(),
                ),
                child: widget.width == null
                    ? Opacity(opacity: 0, child: widget.child)
                    : null,
              ),
            ),
            AnimatedPositioned(
              curve: _curve,
              duration: Duration(milliseconds: widget.duration),
              bottom: _position,
              left: isWidthInfinite ? 0 : null,
              right: isWidthInfinite ? 0 : null,
              child: Container(
                height: _height,
                width: widget.width,
                decoration: BoxDecoration(
                  color: widget.enabled ? widget.color : widget.disabledColor,
                  borderRadius: _getBorderRadius(),
                  border: widget.hasBorder
                      ? Border.all(
                          color: widget.enabled
                              ? darken(widget.color, widget.shadowDegree)
                              : darken(
                                  widget.disabledColor, widget.shadowDegree),
                          width: 1,
                        )
                      : null,
                ),
                child: Center(child: widget.child),
              ),
            ),
          ],
        ),
      ),
      onLongPressEnd:
          widget.enabled ? (details) => _onEnd(details.globalPosition) : null,
      onLongPressCancel: widget.enabled
          ? () {
              setState(() {
                _position = 4;
              });
            }
          : null,
      onTapDown: widget.enabled ? _pressed : null,
      onTapUp: widget.enabled ? _onTapUp : null,
      onPanUpdate: widget.enabled ? _onPanUpdate : null,
      onPanEnd:
          widget.enabled ? (details) => _onEnd(details.globalPosition) : null,
    );
  }

  void _pressed(_) {
    Gaimon.selection();
    setState(() {
      _position = 0;
    });
  }

  void _onTapUp(_) => _onPressed();

  void _onPressed() {
    setState(() {
      _position = 4;
    });
    widget.onPressed();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(details.globalPosition);
      final buttonRect =
          Rect.fromLTWH(0, 0, renderBox.size.width, renderBox.size.height);

      if (!buttonRect.contains(localPosition)) {
        setState(() {
          _position = 4;
        });
      } else {
        setState(() {
          _position = 0;
        });
      }
    }
  }

  void _onEnd(Offset globalPosition) {
    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(globalPosition);
      final buttonRect =
          Rect.fromLTWH(0, 0, renderBox.size.width, renderBox.size.height);

      if (buttonRect.contains(localPosition)) {
        _onPressed();
      } else {
        setState(() {
          _position = 4;
        });
      }
    }
  }

  BorderRadius? _getBorderRadius() {
    return BorderRadius.circular(widget.borderRadius);
  }
}

// Get a darker color from any entered color.
// Thanks to @NearHuscarl on StackOverflow
Color darken(Color color, ShadowDegree degree) {
  double amount = degree == ShadowDegree.dark ? 0.15 : 0.12;
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

enum ShadowDegree { light, dark }
