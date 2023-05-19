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

void main() {
  final modal = Modal("modal");
  modal.okBtn = null;
  modal.onCancel = (_) {
    modal.close();
  };

  modal.modal!.style.cssText = "border: none !important;";

  final output = document.getElementById("output")!;
  output.onClick.listen((event) {
    modal.open(title: "Hello world");
  });
}
