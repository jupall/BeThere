import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// -------------------------------------------------

typedef ChipSelected<T> = void Function(T data, bool selected);
typedef ChipsBuilder<T> = Widget Function(
    BuildContext context, ChipsInputState<T> state, T data);

class ChipsInput<T> extends StatefulWidget {
  const ChipsInput({
    Key? key,
    this.decoration = const InputDecoration(),
    required this.chipBuilder,
    required this.onChanged,
    this.onChipTapped,
  }) : super(key: key);

  final InputDecoration decoration;
  final ValueChanged<List<T>> onChanged;
  final ValueChanged<T>? onChipTapped;
  final ChipsBuilder<T> chipBuilder;

  @override
  ChipsInputState<T> createState() => ChipsInputState<T>();
}

class ChipsInputState<T> extends State<ChipsInput<T>>
    implements TextInputClient {
  static const kObjectReplacementChar = 0xFFFC;

  Set<T> _chips = Set<T>();
  List<T>? _suggestions;
  int _searchId = 0;

  FocusNode? _focusNode;
  TextEditingValue _value = TextEditingValue();
  TextInputConnection? _connection;

  String get text => String.fromCharCodes(
        _value.text.codeUnits.where((ch) => ch != kObjectReplacementChar),
      );

  bool get _hasInputConnection =>
      _connection != null && (_connection?.attached ?? false);

  void requestKeyboard() {
    if (_focusNode?.hasFocus ?? false) {
      _openInputConnection();
    } else {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void selectSuggestion(T data) {
    setState(() {
      _chips.add(data);
      _updateTextInputState();
      _suggestions = null;
    });
    widget.onChanged(_chips.toList(growable: false));
  }

  void deleteChip(T data) {
    setState(() {
      _chips.remove(data);
      _updateTextInputState();
    });
    widget.onChanged(_chips.toList(growable: false));
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode?.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (_focusNode?.hasFocus ?? false) {
      _openInputConnection();
    } else {
      _closeInputConnectionIfNeeded();
    }
    setState(() {
      // rebuild so that _TextCursor is hidden.
    });
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _closeInputConnectionIfNeeded();
    super.dispose();
  }

  void _openInputConnection() {
    if (!_hasInputConnection) {
      _connection = TextInput.attach(this, TextInputConfiguration());
      _connection?.setEditingState(_value);
    }
    _connection?.show();
  }

  void _closeInputConnectionIfNeeded() {
    if (_hasInputConnection) {
      _connection?.close();
      _connection = null;
    }

    // setState(() {
    //   _chips.add(_value.text as T);
    // });
  }

  @override
  Widget build(BuildContext context) {
    var chipsChildren = _chips
        .map<Widget>(
          (data) => widget.chipBuilder(context, this, data),
        )
        .toList();

    final theme = Theme.of(context);

    chipsChildren.add(
      Container(
        height: 32.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              text,
              style: theme.textTheme.subtitle1?.copyWith(
                height: 1.5,
              ),
            ),
            _TextCaret(
              resumed: _focusNode?.hasFocus ?? false,
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      //mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: requestKeyboard,
          child: InputDecorator(
            decoration: widget.decoration,
            isFocused: _focusNode?.hasFocus ?? false,
            isEmpty: _value.text.length == 0,
            child: Wrap(
              children: chipsChildren,
              spacing: 4.0,
              runSpacing: 4.0,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    final oldCount = _countReplacements(_value);
    final newCount = _countReplacements(value);
    setState(() {
      if (newCount < oldCount) {
        _chips = Set.from(_chips.take(newCount));
      }
      _value = value;
    });
    // _onSearchChanged(text);
  }

  int _countReplacements(TextEditingValue value) {
    return value.text.codeUnits
        .where((ch) => ch == kObjectReplacementChar)
        .length;
  }

  @override
  void performAction(TextInputAction action) {
    _focusNode?.unfocus();
    if (action == TextInputAction.done) {
      _chips.add(_value.text as T);
      _value = TextEditingValue.empty;
    }
  }

  void _updateTextInputState() {
    final text =
        String.fromCharCodes(_chips.map((_) => kObjectReplacementChar));
    _value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange(start: 0, end: text.length),
    );
    _connection?.setEditingState(_value);
  }

  // void _onSearchChanged(String value) async {
  //   final localId = ++_searchId;
  //   final results = await widget.findSuggestions(value);
  //   if (_searchId == localId && mounted) {
  //     setState(() => _suggestions = results
  //         .where((profile) => !_chips.contains(profile))
  //         .toList(growable: false) as List<T>?);
  //   }
  // }

  @override
  void connectionClosed() {
    // TODO: implement connectionClosed
  }

  @override
  // TODO: implement currentAutofillScope
  AutofillScope? get currentAutofillScope => throw UnimplementedError();

  @override
  // TODO: implement currentTextEditingValue
  TextEditingValue? get currentTextEditingValue => throw UnimplementedError();

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {
    // TODO: implement performPrivateCommand
  }

  @override
  void showAutocorrectionPromptRect(int start, int end) {
    // TODO: implement showAutocorrectionPromptRect
  }

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    // TODO: implement updateFloatingCursor
  }

  @override
  void didChangeInputControl(
      TextInputControl? oldControl, TextInputControl? newControl) {
    // TODO: implement didChangeInputControl
  }

  @override
  void insertTextPlaceholder(Size size) {
    // TODO: implement insertTextPlaceholder
  }

  @override
  void performSelector(String selectorName) {
    // TODO: implement performSelector
  }

  @override
  void removeTextPlaceholder() {
    // TODO: implement removeTextPlaceholder
  }

  @override
  void showToolbar() {
    // TODO: implement showToolbar
  }
}

class _TextCaret extends StatefulWidget {
  const _TextCaret({
    Key? key,
    this.duration = const Duration(milliseconds: 500),
    this.resumed = false,
  }) : super(key: key);

  final Duration duration;
  final bool resumed;

  @override
  _TextCursorState createState() => _TextCursorState();
}

class _TextCursorState extends State<_TextCaret>
    with SingleTickerProviderStateMixin {
  bool _displayed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.duration, _onTimer);
  }

  void _onTimer(Timer timer) {
    setState(() => _displayed = !_displayed);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Opacity(
        opacity: _displayed && widget.resumed ? 1.0 : 0.0,
        child: Container(
          width: 2.0,
          color: theme.primaryColor,
        ),
      ),
    );
  }
}
