import 'package:flutter/material.dart';
import 'package:pishgaman/utils/app_colors.dart';

import '../../consts/t.dart';
import '../../models/app_settings.dart';
import '../../models/rank.dart';

class RankRow extends StatelessWidget {
  final Rank rank;
  final bool header;
  final String uid;
  final Color? color;
  const RankRow(
      {Key? key,
      required this.rank,
      required this.header,
      required this.uid,
      this.color})
      : super(key: key);

  bool get you => uid == rank.id;

  String get title => you
      ? T.you
      : header
          ? T.userName
          : rank.userName;
  String get rankText => header ? T.rankText : (rank.rank + 1).toString();
  String get score => header ? T.score : rank.score.toString();
  String get subTitle => header
      ? "${T.wins2}/${T.loses2}"
      : "${rank.wins}/${rank.loses}"; // rank.score.toString();
  Color get _clr => you ? color ?? AppColors.success : Colors.white;

  @override
  Widget build(BuildContext context) {
    Color clr = _clr;
    TextStyle style = TextStyle(color: clr);
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white, width: 0.5))),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: clr, fontWeight: FontWeight.bold),
        ),
        leading: Text(
          rankText,
          style: style,
        ),
        trailing: Text(
          score,
          style: TextStyle(color: clr, fontSize: 20),
        ),
        subtitle: Text(
          subTitle,
          style: style,
        ),
      ),
    );
  }
}

class RanksList extends StatelessWidget {
  final AppSettings? settings;
  final List<Rank> ranks;
  final Color? color;

  const RanksList(
      {Key? key, required this.settings, required this.ranks, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String uid = settings?.id ?? "NA";

    ranks.sort((a, b) => a.rank - b.rank);

    return ListView.builder(
        itemCount: ranks.length + 1,
        itemBuilder: (BuildContext context, int index) {
          return RankRow(
            rank: index == 0 ? Rank() : ranks[index - 1],
            header: index == 0,
            uid: uid,
            color: color,
          );
        });
  }
}
