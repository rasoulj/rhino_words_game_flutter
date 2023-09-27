import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pishgaman/models/match_enum.dart';



class SuggestView extends StatelessWidget {
  final String correct, suggest;
  final VoidCallback onTap;
  const SuggestView({Key? key, required this.correct, required this.suggest, required this.onTap}) : super(key: key);

  int get length => correct.length;
  double get fieldWidth => Get.width/(1.9*length);


  
  Widget buildLetter(int i, MatchEnum m) {
    final w = fieldWidth;
    Color color = m.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w,
        height: w,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              color.withAlpha(130),
              color,
            ],
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: Center(
            child: Text(i < suggest.length ? suggest[i] : "",
              style: TextStyle(
                color: Colors.white,
                // fontWeight: FontWeight.w600,
                fontSize: fieldWidth/1.8,
              ),
            ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MatchEnum> m = match(correct, suggest);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(length, (i) => buildLetter(i, m[i])),
      ),
    );
  }
}
