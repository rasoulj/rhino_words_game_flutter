import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:pishgaman/db/sembast_db.dart';
import 'package:pishgaman/utils/etc.dart';
import 'package:pishgaman/views/ranks/ranks_list.dart';
import 'package:tab_container/tab_container.dart';

import '../../consts/f.dart';
import '../../consts/t.dart';
import '../../models/app_settings.dart';
import '../../models/rank.dart';
import '../../models/rest_response.dart';
import '../../utils/app_colors.dart';
import '../../utils/rest_api.dart';

class RanksView extends StatefulWidget {
  final AppSettings? settings;
  final SembastDb? db;

  const RanksView({Key? key, required this.settings, required this.db})
      : super(key: key);

  @override
  State<RanksView> createState() => _RanksViewState();
}

class _RanksViewState extends State<RanksView> {
  List<Rank> _ranks = [];

  @override
  void initState() {
    loadData();
    _tabController = TabContainerController(length: 2);
    super.initState();
  }

  late final TabContainerController _tabController;

  void loadData() async {
    showLoading();

    ApiResponse<Map<String, List<Rank>>> response = await RestApi.getTopRanks(
      widget.settings?.score ?? 0,
    );

    setState(() {
      _ranks = !response.ok ? [] : response.data?[F.ranks] ?? [];
    });

    final update =
        (response.data?[F.update] ?? []).map((e) => e.toJson()).toList();

    await AppSettings.saveLocalJson(widget.db, {F.ranks: update});

    Get.forceAppUpdate();

    if (!response.ok) {
      showError(response.message ?? T.unknownError);
    }

    EasyLoading.dismiss();
  }

  // Color get activeColor => _tabController.index == 0 ? AppColors.accent : AppColors.success;
  Color _activeColor = AppColors.accent;
  Color get activeColor => _activeColor;
  set activeColor(Color value) => setState(() => _activeColor = value);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: loadData,
              icon: const Icon(
                Icons.refresh,
              ),
            ),
          ],
          title: const Text(T.ranksTitle),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: activeColor,
        ),
        body: TabContainer(
          onEnd: () {
            activeColor = _tabController.index == 0
                ? AppColors.accent
                : AppColors.success;
          },
          controller: _tabController,
          colors: [
            AppColors.accent.withOpacity(0.8),
            AppColors.success.withOpacity(0.7),
          ],
          // color: AppColors.accent,
          children: [
            StreamBuilder<AppSettings>(
              stream: AppSettings.getStream(widget.db),
              initialData: null,
              builder:
                  (BuildContext context, AsyncSnapshot<AppSettings> snapshot) {
                final update = snapshot.data?.ranks ?? [];
                return RanksList(
                  settings: widget.settings,
                  ranks: update,
                  color: Colors.amberAccent,
                );
              },
            ),
            RanksList(
              settings: widget.settings,
              ranks: _ranks,
              color: Colors.amberAccent,
            ),
          ],
          tabs: const [
            T.ranksTitleMe,
            T.ranksTitleAll,
            // 'Tab 3',
          ],
        ),
      ),
    );
  }
}
