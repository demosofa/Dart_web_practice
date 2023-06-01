import 'dart:html';

final class PointerUtil {
  static (int, int) getAxis(MouseEvent e, {isTarget = true}) {
    final Point<num> points = e.page;
    final num pageX = points.x, pageY = points.y;
    final target = isTarget ? e.target : e.currentTarget;
    final trueBound = getTrueBound(target as Element);
    final x = (pageX - trueBound.left) / trueBound.width;
    final y = (pageY - trueBound.top) / trueBound.height;
    return (x.round(), y.round());
  }

  static ({int left, int top, int height, int width}) getTrueBound(
      Element elem) {
    final Rectangle<num> clientRect = elem.getBoundingClientRect();
    final (x, y, width, height) =
        (clientRect.left, clientRect.top, clientRect.width, clientRect.height);
    final (pageXOffset, pageYOffset) = (window.pageXOffset, window.pageYOffset);
    final documentElement = elem.ownerDocument!.documentElement;
    final (clientLeft, clientTop) =
        (documentElement!.clientLeft, documentElement.clientTop);
    return (
      top: y.round() + pageYOffset - clientTop!,
      left: x.round() + pageXOffset - clientLeft!,
      height: height.round(),
      width: width.round(),
    );
  }
}

void main() {
  final card = querySelector('.card')!;
  const THRESHOLD = 15;
  card.addEventListener("pointermove", (e) {
    final (x, y) = PointerUtil.getAxis(e as MouseEvent);
    final rotateX = (THRESHOLD / 2 - x * THRESHOLD).roundToDouble();
    final rotateY = (y * THRESHOLD - THRESHOLD / 2).roundToDouble();
    final target = e.currentTarget as Element;
    card.style.transform = '''perspective(${target.clientWidth}px) 
                          rotateX(${rotateY}deg) rotateY(${rotateX}deg) 
                          scale(1.2)''';
  });

  card.addEventListener("pointerleave", (e) {
    final target = e.currentTarget as Element;
    card.style.transform = '''perspective(${target.clientWidth}px) 
                          rotateX(0deg) rotateY(0deg) scale(1)''';
  });
}
