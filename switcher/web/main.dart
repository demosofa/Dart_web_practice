import 'dart:html';
import 'dart:core';

enum TargetBtn { ok, cancel }

class Modal {
  DialogElement? modal;
  Element? header;
  Element? containerContent;
  Element? containerBtn;
  Element? _okBtn;
  Element? _cancelBtn;
  EventListener? _onOk;
  EventListener? _onCancel;
  Modal(String className) {
    _okBtn = document.createElement("button");
    _cancelBtn = document.createElement("button");
    _okBtn!.text = "Ok";
    _cancelBtn!.text = "Cancel";
    header = document.createElement("h3");
    containerContent = document.createElement("div");
    containerBtn = document.createElement("div");
    containerBtn!.append(_cancelBtn!);
    containerBtn!.append(_okBtn!);
    modal = document.createElement("dialog") as DialogElement;
    modal!.className = className;
    modal!.append(header!);
    modal!.append(containerContent!);
    modal!.append(containerBtn!);
    document.body!.append(modal!);
  }

  Element get okBtn => _okBtn!;
  set okBtn(Element? newBtn) {
    _removeBtn(_okBtn, _onOk);
    _okBtn = newBtn;
    _addBtn(_okBtn, _onOk);
  }

  Element get cancelBtn => _cancelBtn!;
  set cancelBtn(Element? newBtn) {
    _removeBtn(_cancelBtn, _onCancel);
    _cancelBtn = newBtn;
    _addBtn(_cancelBtn, _onCancel);
  }

  EventListener get onOk => _onOk!;
  set onOk(EventListener handleOk) {
    _onOk = handleOk;
    _okBtn!.addEventListener("click", _onOk);
  }

  EventListener get onCancel => _onCancel!;
  set onCancel(EventListener handleCancel) {
    _onCancel = handleCancel;
    _cancelBtn!.addEventListener("click", _onCancel);
  }

  void _addBtn(Element? btn, EventListener? event, [String type = "click"]) {
    if (btn != null) {
      btn.addEventListener(type, event);
      containerBtn!.append(btn);
    }
  }

  void _removeBtn(Element? btn, EventListener? event, [String type = "click"]) {
    if (btn != null) {
      btn.removeEventListener(type, event);
      btn.remove();
    }
  }

  void open({String? content = "", String? title = ""}) {
    header!.text = title;
    containerContent!.innerHtml = content;
    modal!.showModal();
  }

  void close() {
    header!.text = "";
    containerContent!.innerHtml = "";
    modal!.close();
  }
}

void main() {
  final switcherContainer = querySelector(".switcher-container")!;
  final switcher = querySelector(".switch-icon")!;
  final switchBoxes = querySelectorAll(".sw-even > a");
  final boxTypeContainer = querySelector(".sw-box")!;
  final boxStyles = querySelectorAll(".sw-box > a");
  final boxColors = querySelectorAll(".sw-color > a");
  final sections = querySelectorAll("body > section");
  final toggleModalBtn = querySelectorAll(".toggle-edit-modal");

  Element cloneWithStyle(Element element, [bool? deep = true]) {
    final css = element.getComputedStyle();
    element = element.clone(deep) as Element;
    for (var i = 0; i < css.length; i++) {
      final prop = css.item(i);
      final value = css.getPropertyValue(prop);
      if (value.isNotEmpty) {
        element.style.setProperty(prop, value);
      }
    }
    return element;
  }

  final editModal = Modal("edit-modal");
  editModal.okBtn = null;

  editModal.onCancel = (e) {
    editModal.close();
  };

  void setStyle(key, value) {
    window.localStorage[key] = value;
    document.documentElement!.style.setProperty(key, value);
  }

  void removeStyle(key) {
    window.localStorage.remove(key);
    document.documentElement!.style.removeProperty(key);
  }

  void toggleSection(bool toggle) {
    for (var element in sections) {
      if (toggle) {
        element.classes.add("boxed");
      } else {
        element.classes.remove("boxed");
      }
    }
  }

  void addChildToModal(ElementList elements) {
    for (var child in elements) {
      child = cloneWithStyle(child);
      editModal.containerContent!.append(child);
    }
  }

  toggleModalBtn.asMap().forEach((key, btn) {
    btn.addEventListener("click", (e) {
      String name = btn.getAttribute("data-target")!;
      editModal.open(title: "Hello there", content: "Edit $name");
      switch (name) {
        case "sw-color":
          addChildToModal(boxColors);
          break;
        case "sw-box":
          addChildToModal(boxStyles);
          break;
      }
    });
  });

  var isSwitchOff = true;
  switcher.addEventListener("click", (e) {
    if (isSwitchOff) {
      switcherContainer.style.left = "0";
    } else {
      switcherContainer.style.left =
          "-${switcherContainer.getComputedStyle().width}";
    }
    switcher.classes.toggle("active");
    isSwitchOff = !isSwitchOff;
  });

  int? checkedBoxColor;
  boxColors.asMap().forEach((index, swColor) {
    swColor.addEventListener("click", (e) {
      if (checkedBoxColor != null) {
        boxColors[checkedBoxColor!].classes.remove("checked");
      }
      checkedBoxColor = index;
      swColor.classes.add("checked");
      final value = swColor.style.getPropertyValue("--switcher");
      setStyle("--switcher", value);
    });
  });

  int? checkedBoxStyle;
  boxStyles.asMap().forEach((index, bxStyle) {
    bxStyle.addEventListener("click", (e) {
      if (checkedBoxStyle != null) {
        boxStyles[checkedBoxStyle!].classes.remove("checked");
      }
      checkedBoxStyle = index;
      bxStyle.classes.add("checked");
      final value = bxStyle.style.getPropertyValue("--background");
      setStyle("--background", value);
    });
  });

  for (var swBox in switchBoxes) {
    swBox.addEventListener("click", (e) {
      if (swBox.text == "box") {
        boxTypeContainer.classes.remove("hidden");
        toggleSection(true);
      } else {
        boxTypeContainer.classes.add("hidden");
        if (checkedBoxStyle != null) {
          boxStyles[checkedBoxStyle!].classes.remove("checked");
        }
        toggleSection(false);
        removeStyle("--background");
      }
    });
  }

  void loadBoxColor() {
    var value = window.localStorage["--switcher"];
    if (value != null) {
      checkedBoxColor = boxColors.indexWhere((element) {
        var check = element.style.getPropertyValue("--switcher") == value;
        if (check) {
          element.classes.add("checked");
        }
        return check;
      });
    } else {
      boxColors.first.classes.add("checked");
      value = boxColors.first.style.getPropertyValue("--switcher");
    }
    setStyle("--switcher", value);
  }

  void loadBoxStyle() {
    final value = window.localStorage["--background"];
    if (value != null) {
      checkedBoxStyle = boxStyles.indexWhere((element) {
        final check = element.style.getPropertyValue("--background") == value;
        if (check) {
          element.classes.add("checked");
        }
        return check;
      });
      setStyle("--background", value);
    }
  }

  loadBoxStyle();
  loadBoxColor();
}
