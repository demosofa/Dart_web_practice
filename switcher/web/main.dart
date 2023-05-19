import 'dart:html';

class Modal {
  DialogElement? modal;
  Element? head;
  Element? desc;
  Element? body;
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
    head = document.createElement("h3");
    desc = document.createElement("h4");
    body = document.createElement("div");
    containerBtn = document.createElement("div");
    containerBtn!.append(_cancelBtn!);
    containerBtn!.append(_okBtn!);
    modal = document.createElement("dialog") as DialogElement;
    modal!.className = className;
    modal!.append(head!);
    modal!.append(desc!);
    modal!.append(body!);
    modal!.append(containerBtn!);
    document.body!.append(modal!);
  }

  Element? get okBtn => _okBtn;
  set okBtn(Element? newBtn) {
    _removeBtn(_okBtn, _onOk);
    _okBtn = newBtn;
    _addBtn(_okBtn, _onOk);
  }

  Element? get cancelBtn => _cancelBtn;
  set cancelBtn(Element? newBtn) {
    _removeBtn(_cancelBtn, _onCancel);
    _cancelBtn = newBtn;
    _addBtn(_cancelBtn, _onCancel);
  }

  EventListener? get onOk => _onOk;
  set onOk(EventListener? handleOk) {
    _removeBtn(_okBtn, _onOk);
    _onOk = handleOk;
    _addBtn(_okBtn, _onOk);
  }

  EventListener? get onCancel => _onCancel;
  set onCancel(EventListener? handleCancel) {
    _removeBtn(_cancelBtn, _onCancel);
    _onCancel = handleCancel;
    _addBtn(_cancelBtn, _onCancel);
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

  void open({String? title = "", String? subTitle = ""}) {
    head!.text = title;
    desc!.text = subTitle;
    modal!.showModal();
  }

  void close() {
    head!.text = "";
    desc!.text = "";
    body!.innerHtml = "";
    modal!.close();
  }
}

enum SwKey { color, background }

extension ParseToString on SwKey {
  String toShortString() {
    return "--${toString().split('.').last}";
  }
}

final List<String> colors = ["#f63440", "#7cc576", "#cfc300", "#f8b334"];
final List<String> boxes = [
  "https://img.freepik.com/free-vector/colorful-watercolor-rainbow-background_125540-151.jpg?w=360",
  "https://img.freepik.com/free-photo/vivid-blurred-colorful-background_58702-2545.jpg",
  "https://img.freepik.com/free-photo/vivid-blurred-colorful-background_58702-2554.jpg",
  "https://img.freepik.com/free-photo/vivid-blurred-colorful-wallpaper-background_58702-2745.jpg"
];

var isSwitchOn = true;
var isBoxed = false;
ElementList? sections;
Element? switcher;
void loadSwitcher([Event? event]) {
  final html = '''
      <a class="sw-icon"><i></i></a>
      <h2>STYLE SWITCHER</h2>
      <div class="selector-box">
        <div class="clearfix"></div>
        <div class="sw-odd">
          <button class="sw-example" type="submit">Example</button>
          <h3>SCHEME COLOR</h3>
          <div class="sw-color">
            ${colors.map((value) {
    final key = SwKey.color.toShortString();
    final check = window.localStorage[key];
    return '''
                <a class=${check == value ? "checked" : "unchecked"} 
                  style="$key: $value"
                >
                </a>
              ''';
  }).join("")}
            <button class="toggle-edit-modal" data-target="sw-color"></button>
          </div>
        </div>
        <div class="sw-even">
          <h3>Layout:</h3>
          <a class="sw-light">box</a>
          <a class="sw-dark">wide</a>
        </div>
        <div class="sw-box ${isBoxed ? "show" : "hidden"}">
          <h3>Background pattern:</h3>
          ${boxes.map((value) {
    final key = SwKey.background.toShortString();
    final check = window.localStorage[key];
    value = "url($value)";
    return '''
              <a class=${check == value ? "checked" : "unchecked"} 
                style="$key: $value"
              >
              </a>
            ''';
  }).join("")}
          <button class="toggle-edit-modal" data-target="sw-box"></button>
        </div>
      </div>
    ''';
  final validator = NodeValidatorBuilder.common()
    ..allowElement('a', attributes: ['style'])
    ..allowElement('button', attributes: ['data-target']);
  switcher!.setInnerHtml(html, validator: validator);
  loadSwitcherLogic();
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

void setStyle(String key, String value) {
  window.localStorage[key] = value;
  document.documentElement!.style.setProperty(key, value);
}

void removeStyle(String key) {
  window.localStorage.remove(key);
  document.documentElement!.style.removeProperty(key);
}

void handleSwitchOn([Event? event]) {
  if (isSwitchOn) {
    switcher!.style.left = "0";
  } else {
    switcher!.style.left = "-${switcher!.getComputedStyle().width}";
  }
  switcher!.classes.toggle("active");
  isSwitchOn = !isSwitchOn;
}

EventListener? handleStyle(SwKey swKey) {
  return (e) {
    final key = swKey.toShortString();
    final value = (e.target as Element).style.getPropertyValue(key);
    setStyle(key, value);
    loadSwitcher();
  };
}

void loadSwitcherLogic([Event? _]) {
  final swIcon = querySelector(".sw-icon");
  final boxColors = querySelectorAll(".sw-color > a");
  final boxStyles = querySelectorAll(".sw-box > a");
  final swLight = querySelector(".sw-light");
  final swDark = querySelector(".sw-dark");

  swIcon!.addEventListener("click", handleSwitchOn);

  for (var element in boxColors) {
    element.addEventListener("click", handleStyle(SwKey.color));
  }

  for (var element in boxStyles) {
    element.addEventListener("click", handleStyle(SwKey.background));
  }

  swLight!.addEventListener("click", (event) {
    isBoxed = true;
    for (var element in sections!) {
      element.classes.add("boxed");
    }
    loadSwitcher();
  });

  swDark!.addEventListener("click", (event) {
    isBoxed = false;
    for (var element in sections!) {
      element.classes.remove("boxed");
    }
    removeStyle("--background");
    loadSwitcher();
  });
}

void main() async {
  sections = querySelectorAll("body > section");
  final editModal = Modal("edit-modal");
  editModal.okBtn = null;
  editModal.onCancel = (e) {
    editModal.close();
  };

  switcher = document.createElement("div");
  switcher!.className = "switcher";
  document.body!.append(switcher!);

  ((List<SwKey> args) {
    for (var key in args) {
      var value = window.localStorage[key.toShortString()];
      if (value != null) setStyle(key.toShortString(), value);
    }
    if (window.localStorage[SwKey.background.toShortString()] != null) {
      isBoxed = true;
    }
    if (isBoxed) {
      for (var element in sections!) {
        element.classes.add("boxed");
      }
    }
    loadSwitcher();
  })([SwKey.background, SwKey.color]);
}
