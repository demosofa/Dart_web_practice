import 'dart:html';

enum TargetBtn { ok, cancel }

class Modal {
  Element? modal;
  Element? header;
  Element? containerContent;
  Element? containerBtn;
  Element? _okBtn;
  Element? _cancelBtn;
  EventListener? _onOk;
  EventListener? _onCancel;
  bool isOpen = false;
  Modal(String id) {
    _okBtn = document.createElement("button");
    _cancelBtn = document.createElement("button");
    _okBtn!.text = "Ok";
    _cancelBtn!.text = "Cancel";
    header = document.createElement("h3");
    containerContent = document.createElement("div");
    containerBtn = document.createElement("div");
    modal = document.createElement("div");
    modal!.id = id;
    modal!.append(header!);
    modal!.append(containerContent!);
    modal!.append(containerBtn!);
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
    if (btn != null && event != null) {
      btn.addEventListener(type, event);
      containerBtn!.append(btn);
    }
  }

  void _removeBtn(Element? btn, EventListener? event, [String type = "click"]) {
    if (btn != null && event != null) {
      btn.removeEventListener(type, event);
      btn.remove();
    }
  }

  void open({String? content = "", String? title = ""}) {
    isOpen = true;
    _addBtn(_okBtn, _onOk);
    _addBtn(_cancelBtn, _onCancel);
    header!.text = title;
    containerContent!.innerHtml = content;
    document.body!.append(modal!);
  }

  void close() {
    isOpen = false;
    _removeBtn(_okBtn, _onOk);
    _removeBtn(_cancelBtn, _onCancel);
    header!.text = "";
    containerContent!.innerHtml = "";
    modal!.remove();
  }
}

void main() {
  final switcherContainer = querySelector(".switcher-container")!;
  final switcher = querySelector(".switch-icon")!;
  final switchColors = querySelectorAll(".sw-color > a");
  final switchBoxes = querySelectorAll(".sw-even > a");
  final boxTypeContainer = querySelector(".sw-box")!;
  final boxStyles = querySelectorAll(".sw-box > a");
  final sections = querySelectorAll("body > section");
  final toggleModalBtn = querySelectorAll(".toggle-edit-modal");

  final editModal = Modal("edit-modal");
  editModal.okBtn = null;

  editModal.onCancel = (e) {
    editModal.close();
  };

  void setColor(key, value) {
    window.localStorage[key] = value;
    document.documentElement!.style.setProperty(key, value);
  }

  void removeColor(key) {
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

  void toggleModal(ElementList? elements) {
    if (elements == null) {
      editModal.close();
    } else {
      editModal.open(title: "Hello there");
      for (var child in elements) {
        child = cloneWithStyle(child);
        editModal.containerContent!.append(child);
      }
    }
  }

  toggleModalBtn.asMap().forEach((key, btn) {
    btn.addEventListener("click", (e) {
      String name = btn.getAttribute("data-target")!;
      editModal.isOpen = !editModal.isOpen;
      switch (name) {
        case "sw-color":
          toggleModal(editModal.isOpen ? switchColors : null);
          break;
        case "sw-box":
          toggleModal(editModal.isOpen ? boxStyles : null);
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
  switchColors.asMap().forEach((index, swColor) {
    swColor.addEventListener("click", (e) {
      if (checkedBoxColor != null) {
        switchColors[checkedBoxColor!].classes.remove("checked");
      }
      checkedBoxColor = index;
      swColor.classes.add("checked");
      window.localStorage["checkedBoxColor"] = index.toString();
      setColor("--switcher", swColor.style.getPropertyValue("--switcher"));
    });
  });

  int? checkedBoxStyle;
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
        removeColor("--background");
      }
    });
  }

  boxStyles.asMap().forEach((index, bxStyle) {
    bxStyle.addEventListener("click", (e) {
      if (checkedBoxStyle != null) {
        boxStyles[checkedBoxStyle!].classes.remove("checked");
      }
      checkedBoxStyle = index;
      bxStyle.classes.add("checked");
      window.localStorage["checkedBoxStyle"] = index.toString();
      final child = bxStyle.children[0] as ImageElement;
      setColor("--background", "url(${child.src})");
    });
  });

  void loadCheck() {
    String? loadBoxColor = window.localStorage["checkedBoxColor"];
    String? loadBoxStyle = window.localStorage["checkedBoxStyle"];
    if (loadBoxColor != null) {
      checkedBoxColor = int.parse(loadBoxColor);
    } else {
      checkedBoxColor = 0;
    }
    switchColors[checkedBoxColor!].classes.add("checked");

    if (loadBoxStyle != null) {
      checkedBoxStyle = int.parse(loadBoxStyle);
      toggleSection(true);
      boxStyles[checkedBoxStyle!].classes.add("checked");
    } else {
      toggleSection(false);
    }
  }

  void initColor(List<String> args) {
    for (final key in args) {
      final value = window.localStorage[key];
      if (value != null) setColor(key, value);
    }
  }

  initColor(["--switcher", "--background"]);
  loadCheck();
}
