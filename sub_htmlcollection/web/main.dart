import 'dart:html';

final class SubHTMLCollection {
  Element parent;
  SubHTMLCollection(this.parent);

  List<Element> _update() {
    return parent.children;
  }

  List<Element> get child {
    return _update();
  }

  /// like Array.splice but for HTMLCollection
  List<Node> splice(int start, {int count = 0, List<Node>? elements}) {
    List<Node> removes = [];
    start = start >= 0 ? start : child.length + start;
    for (var i = 0; i < elements!.length; i++) {
      if (child.length <= start) {
        parent.append(elements[i]);
      } else {
        parent.insertBefore(elements[i], child[start + i]);
      }
    }
    for (var i = 0; i < count; i++) {
      Node removed = child[start + elements.length];
      removes.add(removed);
      removed.remove();
    }
    return removes;
  }

  /// like Array.slice but for HTMLCollection
  List<Node> slice(int start, [int? end, Node? source]) {
    start = start >= 0 ? start : child.length + start;
    if (end != null) end = end >= 0 ? end : child.length + end;
    List<Node> sliced = child.sublist(start, end);
    if (source == null) return sliced;
    return sliced.map((elem) {
      Element target = document.importNode(elem, true) as Element;
      Map<String, String> sourceProps = (source as Element).attributes;
      target.attributes.addAll(sourceProps);
      return target;
    }).toList();
  }
}

void main() {
  final lst = querySelector(".lst__test")!;
  final btnLeft = querySelector(".btn.left");
  final btnRight = querySelector(".btn.right");
  final nodeArray = SubHTMLCollection(lst);
  final size = lst.offsetWidth / 3;

  void resetPos() {
    var pos = -size;
    for (var child in [...lst.children]) {
      child.style.left = "${pos.toString()}px";
      child.style.width = "${size.toString()}px";
      pos += size;
    }
  }

  void onLeft(Event e) {
    final clones = nodeArray.slice(0, 1);
    nodeArray.splice(-1, count: 0, elements: clones);
    resetPos();
  }

  void onRight(Event e) {
    final clones = nodeArray.slice(-2, -1);
    nodeArray.splice(0, count: 0, elements: clones);
    resetPos();
  }

  btnLeft!.onClick.listen(onLeft);
  btnRight!.onClick.listen(onRight);

  resetPos();
}
