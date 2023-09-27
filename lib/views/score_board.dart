import 'package:flutter/material.dart';
import 'package:pishgaman/models/match_enum.dart';
import 'package:pishgaman/utils/app_colors.dart';
import 'package:pishgaman/utils/etc.dart';
import 'package:segment_display/segment_display.dart';

///  Created by rasoulj on 6/17/2022 AD.
class ScoreBoard extends StatelessWidget {
  final int? score;
  final MatchEnum state;
  final String tooltip;
  final String? title;

  const ScoreBoard({
    Key? key,
    this.title,
    required this.score,
    required this.state,
    required this.tooltip,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Color disColor =
        state.color.lighten(state == MatchEnum.perfect ? 0.4437 : 0.3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            style: TextStyle(fontSize: 12, color: AppColors.empty),
          ),
        GestureDetector(
          onTap: () => showInfo(tooltip),
          child: SevenSegmentDisplay(
            characterSpacing: 3,
            segmentStyle: HexSegmentStyle(
              segmentSpacing: 1,
              enabledColor: state.color, //.darken(0.25),
              disabledColor: disColor,
            ),
            backgroundColor: Colors.transparent,
            value: (score ?? 0) < 0 ? "-----" : score?.toString() ?? "0",
            characterCount: 5,
            size: 2.5,
          ),
        ),
      ],
    );
  }
}
