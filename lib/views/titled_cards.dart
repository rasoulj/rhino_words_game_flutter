import 'package:flutter/material.dart';
import 'package:pishgaman/utils/app_colors.dart';

import 'tiny_widgets.dart';

class CardTitle extends StatelessWidget {
  final String? title;
  final bool hasDiv;
  final bool isEmpty;
  const CardTitle(
      {Key? key, this.title, this.hasDiv = true, this.isEmpty = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) => title == null
      ? const ZeroWidget()
      : Padding(
          padding: EdgeInsets.only(left: 8.0, top: hasDiv ? 12 : 0),
          child: Row(
            children: [
              if (!isEmpty)
                Text(
                  title ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (isEmpty)
                const GrayBox(
                  color: AppColors.grey2,
                  height: 17,
                ),
            ],
          ),
        );
}

class TitledCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final VoidCallback? onPressed;
  final bool hasDiv;
  final bool isEmpty;

  const TitledCard(
      {Key? key,
      this.title,
      this.child = const ZeroWidget(),
      this.onPressed,
      this.hasDiv = true,
      this.isEmpty = false})
      : super(key: key);

  Widget get _body0 => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(padding: const EdgeInsets.all(8.0), child: child),
      );

  Widget get _body => onPressed == null
      ? _body0
      : GestureDetector(
          onTap: onPressed,
          child: _body0,
        );

  @override
  Widget build(BuildContext context) {
    return title == null
        ? _body
        : Column(children: [
            CardTitle(
              isEmpty: isEmpty,
              hasDiv: hasDiv,
              title: title,
            ),
            _body,
          ]);
  }
}
