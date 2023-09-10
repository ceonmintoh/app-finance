// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_classes/structure/navigation/app_route.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/routes/abstract_page_state.dart';
import 'package:app_finance/widgets/_wrappers/full_sized_button_widget.dart';
import 'package:app_finance/widgets/_wrappers/tab_widget.dart';
import 'package:app_finance/widgets/start/account_tab.dart';
import 'package:app_finance/widgets/start/budget_tab.dart';
import 'package:app_finance/widgets/start/privacy_tab.dart';
import 'package:app_finance/widgets/start/setting_tab.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  StartPageState createState() => StartPageState();
}

class StartPageState extends AbstractPageState<StartPage> {
  int currentStep = 0;
  Widget button = ThemeHelper.emptyBox;
  late String buttonName = AppLocale.labels.goNextTooltip;

  @override
  String getTitle() => AppLocale.labels.appStartHeadline;

  @override
  String getButtonName() => buttonName;

  @override
  Widget buildButton(BuildContext context, BoxConstraints constraints) => button;

  @override
  AppBar buildBar(BuildContext context, [bool isBottom = false]) {
    final text = Text(
      getTitle(),
      style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
    );
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      toolbarHeight: 40,
      automaticallyImplyLeading: false,
      actions: const [],
      title: isBottom ? text : Center(child: text),
    );
  }

  void updateState(Widget? btn, NavigatorState nav) {
    if (btn != null) {
      setState(() {
        button = btn;
        buttonName = (btn as FullSizedButtonWidget).title;
      });
    } else if (currentStep > 2) {
      nav.popAndPushNamed(AppRoute.homeRoute);
    } else {
      setState(() {
        button = ThemeHelper.emptyBox;
        currentStep += 1;
      });
    }
  }

  @override
  Widget buildContent(BuildContext context, BoxConstraints constraints) {
    NavigatorState nav = Navigator.of(context);
    fn([Widget? btn]) => updateState(btn, nav);
    final isEmpty = button == ThemeHelper.emptyBox;
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: TabWidget(
        asDots: true,
        focus: currentStep,
        children: [
          SettingTab(setState: fn, isFirstBoot: currentStep < 1 && isEmpty),
          PrivacyTab(setState: fn, isFirstBoot: currentStep < 2 && isEmpty),
          AccountTab(setState: fn, isFirstBoot: currentStep < 3 && isEmpty),
          BudgetTab(setState: fn, isFirstBoot: currentStep < 4 && isEmpty),
        ],
      ),
    );
  }
}
