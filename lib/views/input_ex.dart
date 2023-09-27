import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import 'tiny_widgets.dart';
import 'titled_cards.dart';

class InputEx extends StatefulWidget {
  final AppController? controller;
  final String? field;
  final ValueChanged? onChange;
  final String? hintText;
  final String? title;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool hasClear;
  final int maxLines;
  final TextEditingController? txtController;

  const InputEx({
    Key? key,
    @required this.controller,
    @required this.field,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.onChange,
    this.hasClear = true,
    this.maxLines = 1,
    this.title, this.txtController,
  }) : super(key: key);

  @override
  State<InputEx> createState() => _InputExState();
}

class _InputExState extends State<InputEx> {
  void _onChange(String value) {
    if (widget.onChange != null) widget.onChange!(value);
    if (widget.field == null) return;
    widget.controller?.setValue(widget.field ?? "NA", value);
  }

  @override
  void initState() {
    String text = widget.controller?.getValue(widget.field ?? "NA") ?? "";
    _editingController = widget.txtController ?? TextEditingController(text: text);
    super.initState();
  }



  late final TextEditingController _editingController;

  @override
  Widget build(BuildContext context) {
    return widget.title == null
        ? input
        : Column(
      children: [
        CardTitle(
          title: widget.title,
        ),
        input,
      ],
    );
  }

  Widget get input {
    String text = widget.controller?.getValue(widget.field ?? "NA") ?? "";
    return TextField(
      maxLines: widget.maxLines,
      controller: _editingController,
      style: AppStyles.darkText,
      obscureText: widget.isPassword,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      onChanged: _onChange,
      decoration: InputDecoration(
        suffixIcon: !widget.hasClear || text == ""
            ? null
            : GestureDetector(
          onTap: () {
            widget.controller?.setValue(widget.field ?? "NA", "");
            _editingController.text = "";
            if (widget.onChange != null) widget.onChange!("");
          },
          child: const Icon(
            Icons.close,
            // size: 16,
            color: AppColors.grey2,
          ),
        ),
        hintStyle: AppStyles.greyText,
        isDense: true,
        filled: true,
        fillColor: AppColors.white,
        // isCollapsed: true,
        suffixIconColor: AppColors.accent,
        border: AppStyles.inputBorder,
        focusedBorder: AppStyles.inputBorder,
        hintText: widget.hintText,
      ),
    );
  }
}
