// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:adaptive_breakpoints/adaptive_breakpoints.dart';
import 'package:app_finance/classes/app_menu.dart';
import 'package:app_finance/classes/budget_app_data.dart';
import 'package:app_finance/data.dart';
import 'package:app_finance/helpers/theme_helper.dart';
import 'package:app_finance/classes/app_route.dart';
import 'package:app_finance/routes/abstract_page.dart';
import 'package:app_finance/widgets/home/base_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class BudgetViewPage extends AbstractPage {
  String uuid;

  BudgetViewPage({
    required this.uuid,
  }) : super();

  @override
  BudgetViewPageState createState() => BudgetViewPageState();
}

class BudgetViewPageState extends AbstractPageState<BudgetViewPage> {
  @override
  String getTitle(context) {
    final item = widget.state?.getByUuid(widget.uuid) as BudgetAppData;
    return item.title;
  }

  void deactivateAccount(BuildContext context) {
    var data = widget.state?.getByUuid(widget.uuid) as BudgetAppData;
    data.hidden = true;
    widget.state?.update(AppDataType.budgets, widget.uuid, data);
    Navigator.pop(context);
  }

  @override
  Widget buildButton(BuildContext context, BoxConstraints constraints) {
    String route =
        AppMenu(context: context).uuid(AppRoute.budgetEditRoute, widget.uuid);
    double indent =
        ThemeHelper(windowType: getWindowType(context)).getIndent() * 4;
    return Container(
      margin: EdgeInsets.only(left: indent),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        FloatingActionButton(
          onPressed: () => deactivateAccount(context),
          tooltip: AppLocalizations.of(context)!.deleteBudgetTooltip,
          child: const Icon(Icons.delete),
        ),
        FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, route),
          tooltip: AppLocalizations.of(context)!.editBudgetTooltip,
          child: const Icon(Icons.edit),
        ),
      ]),
    );
  }

  @override
  Widget buildContent(BuildContext context, BoxConstraints constraints) {
    final item = widget.state?.getByUuid(widget.uuid) as BudgetAppData;
    item.updateContext(context);
    double indent =
        ThemeHelper(windowType: getWindowType(context)).getIndent() * 2;
    double offset = MediaQuery.of(context).size.width - indent * 3;
    return Column(
      children: [
        BaseLineWidget(
          uuid: item.uuid ?? '',
          title: item.title,
          description: item.description,
          details: item.detailsFormatted,
          progress: item.progress,
          color: item.color ?? Colors.transparent,
          offset: offset,
          route: AppRoute.budgetViewRoute,
        )
      ],
    );
  }
}
