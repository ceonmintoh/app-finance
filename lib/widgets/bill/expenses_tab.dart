// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_classes/structure/navigation/app_route.dart';
import 'package:app_finance/_classes/structure/currency/currency_provider.dart';
import 'package:app_finance/_classes/structure/bill_app_data.dart';
import 'package:app_finance/_classes/controller/focus_controller.dart';
import 'package:app_finance/_mixins/shared_preferences_mixin.dart';
import 'package:app_finance/_classes/storage/app_data.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/widgets/_forms/currency_exchange_input.dart';
import 'package:app_finance/widgets/_forms/currency_selector.dart';
import 'package:app_finance/widgets/_forms/date_time_input.dart';
import 'package:app_finance/widgets/_forms/full_sized_button.dart';
import 'package:app_finance/widgets/_forms/list_account_selector.dart';
import 'package:app_finance/widgets/_forms/list_budget_selector.dart';
import 'package:app_finance/widgets/_forms/simple_input.dart';
import 'package:app_finance/widgets/_wrappers/required_widget.dart';
import 'package:app_finance/widgets/_wrappers/row_widget.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpensesTab<T> extends StatefulWidget {
  final String? account;
  final String? budget;
  final Currency? currency;
  final double? bill;
  final String? description;
  final DateTime? createdAt;

  const ExpensesTab({
    super.key,
    this.account,
    this.budget,
    this.currency,
    this.bill,
    this.description,
    this.createdAt,
  });

  @override
  ExpensesTabState createState() => ExpensesTabState();
}

class ExpensesTabState<T extends ExpensesTab> extends State<T> with SharedPreferencesMixin {
  late AppData state;
  String? account;
  String? budget;
  Currency? currency;
  late TextEditingController bill;
  late TextEditingController description;
  double? billValue;
  DateTime? createdAt;
  bool hasErrors = false;
  bool isFresh = true;

  @override
  void initState() {
    account = widget.account;
    budget = widget.budget;
    currency = widget.currency;
    bill = TextEditingController(text: widget.bill != null ? widget.bill.toString() : '');
    billValue = widget.bill;
    description = TextEditingController(text: widget.description);
    createdAt = widget.createdAt;
    super.initState();
  }

  void _loadPreferences() {
    setState(() {
      isFresh = false;

      final accountId = getPreference(prefAccount);
      final objAccount = state.getByUuid(accountId ?? '');
      account ??= objAccount?.uuid;
      currency ??= objAccount?.currency;

      final budgetId = getPreference(prefBudget);
      final objBudget = state.getByUuid(budgetId ?? '');
      budget ??= objBudget?.uuid;
      currency ??= objBudget?.currency;

      final currencyId = getPreference(prefCurrency);
      currency ??= CurrencyProvider.findByCode(currencyId);
    });
  }

  bool hasFormErrors() {
    setState(() => hasErrors = account == null || budget == null || bill.text.isEmpty);
    return hasErrors;
  }

  void updateStorage() {
    setPreference(prefAccount, account ?? '');
    setPreference(prefBudget, budget ?? '');
    state.add(BillAppData(
      account: account ?? '',
      category: budget ?? '',
      currency: currency,
      title: description.text,
      details: double.tryParse(bill.text) ?? 0.0,
      createdAt: createdAt ?? DateTime.now(),
    ));
  }

  String getButtonTitle() {
    return AppLocale.labels.createBillTooltip;
  }

  Widget buildButton(BuildContext context, BoxConstraints constraints) {
    NavigatorState nav = Navigator.of(context);
    return FullSizedButton(
      constraints: constraints,
      setState: () => {
        setState(() {
          if (hasFormErrors()) {
            return;
          }
          updateStorage();
          nav.popAndPushNamed(AppRoute.homeRoute);
        })
      },
      title: getButtonTitle(),
      icon: Icons.save,
    );
  }

  @override
  Widget build(BuildContext context) {
    // FocusController.dispose();
    final TextTheme textTheme = Theme.of(context).textTheme;
    double indent = ThemeHelper.getIndent(2);
    double width = ThemeHelper.getWidth(context, 6);
    FocusController.init();

    return LayoutBuilder(builder: (context, constraints) {
      return Consumer<AppData>(builder: (context, appState, _) {
        state = appState;
        if (isFresh) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _loadPreferences());
        }
        return Scaffold(
          body: SingleChildScrollView(
            controller: FocusController.getController(runtimeType),
            child: Container(
              margin: EdgeInsets.fromLTRB(indent, indent, indent, 240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RequiredWidget(
                    title: AppLocale.labels.account,
                    showError: hasErrors && account == null,
                  ),
                  ListAccountSelector(
                    value: account,
                    hintText: AppLocale.labels.titleAccountTooltip,
                    state: state,
                    setState: (value) => setState(() {
                      account = value;
                      currency = state.getByUuid(value).currency;
                    }),
                    indent: indent,
                    width: width,
                  ),
                  ThemeHelper.hIndent2x,
                  RequiredWidget(
                    title: AppLocale.labels.budget,
                    showError: hasErrors && budget == null,
                  ),
                  ListBudgetSelector(
                    value: budget,
                    hintText: AppLocale.labels.titleBudgetTooltip,
                    state: state,
                    setState: (value) => setState(() {
                      budget = value;
                      var bdgCurrency = state.getByUuid(value).currency;
                      currency ??= bdgCurrency;
                    }),
                    indent: indent,
                    width: width,
                  ),
                  ThemeHelper.hIndent2x,
                  RowWidget(
                    indent: indent,
                    maxWidth: width + indent,
                    chunk: const [120, null],
                    children: [
                      [
                        Text(
                          AppLocale.labels.currency,
                          style: textTheme.bodyLarge,
                        ),
                        CurrencySelector(
                          value: currency?.code,
                          hintText: AppLocale.labels.currencyTooltip,
                          setView: (Currency currency) => currency.code,
                          setState: (value) => setState(() => currency = value),
                        ),
                      ],
                      [
                        RequiredWidget(
                          title: AppLocale.labels.expense,
                          showError: hasErrors && bill.text.isEmpty,
                        ),
                        SimpleInput(
                          controller: bill,
                          type: const TextInputType.numberWithOptions(decimal: true),
                          tooltip: AppLocale.labels.billSetTooltip,
                          setState: (v) => setState(() => billValue = double.tryParse(v)),
                          formatter: [
                            SimpleInput.filterDouble,
                          ],
                        ),
                      ],
                    ],
                  ),
                  ThemeHelper.hIndent2x,
                  CurrencyExchangeInput(
                    width: width,
                    indent: indent,
                    target: currency,
                    state: state,
                    targetAmount: billValue,
                    source: [
                      account != null ? state.getByUuid(account!).currency : null,
                      budget != null ? state.getByUuid(budget!).currency : null,
                    ].cast<Currency?>(),
                  ),
                  Text(
                    AppLocale.labels.description,
                    style: textTheme.bodyLarge,
                  ),
                  SimpleInput(
                    controller: description,
                    tooltip: AppLocale.labels.descriptionTooltip,
                  ),
                  ThemeHelper.hIndent2x,
                  Text(
                    AppLocale.labels.expenseDateTime,
                    style: textTheme.bodyLarge,
                  ),
                  DateTimeInput(
                    width: width,
                    value: createdAt ?? DateTime.now(),
                    setState: (value) => setState(() => createdAt = value),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: buildButton(context, constraints),
        );
      });
    });
  }
}
