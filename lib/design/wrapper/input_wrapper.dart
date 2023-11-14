// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_classes/storage/app_data.dart';
import 'package:app_finance/_classes/structure/def/list_selector_item.dart';
import 'package:app_finance/_configs/screen_helper.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/_ext/build_context_ext.dart';
import 'package:app_finance/design/form/color_selector.dart';
import 'package:app_finance/design/form/currency_selector.dart';
import 'package:app_finance/design/form/icon_selector.dart';
import 'package:app_finance/design/form/list_account_selector.dart';
import 'package:app_finance/design/form/list_budget_selector.dart';
import 'package:app_finance/design/form/list_selector.dart';
import 'package:app_finance/design/form/month_year_input.dart';
import 'package:app_finance/design/form/simple_input.dart';
import 'package:app_finance/design/wrapper/required_widget.dart';
import 'package:app_finance/design/wrapper/text_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NamedInputType {
  accountSelector,
  budgetSelector,
  colorSelector,
  currencySelector,
  currencyShort,
  iconSelector,
  listSelector,
  textInput,
  ymSelector,
}

class InputWrapper extends StatelessWidget {
  final NamedInputType type;
  final bool isRequired;
  final bool showError;
  final String title;
  final List<dynamic>? options;
  final Function? onChange;
  final String? tooltip;
  final TextEditingController? controller;
  final dynamic value;
  final List<TextInputFormatter>? formatter;
  final AppData? state;
  final double? width;
  final TextInputType? inputType;

  @override
  Key? get key => ValueKey(title);

  const InputWrapper({
    super.key,
    required this.type,
    required this.title,
    this.tooltip,
    this.controller,
    this.onChange,
    this.options,
    this.value,
    this.formatter,
    this.isRequired = false,
    this.showError = false,
    this.state,
    this.width,
    this.inputType,
  });

  const InputWrapper.text({
    super.key,
    this.type = NamedInputType.textInput,
    required this.title,
    required this.controller,
    this.tooltip,
    this.isRequired = false,
    this.showError = false,
    this.onChange,
    this.options,
    this.value,
    this.formatter,
    this.state,
    this.width,
    this.inputType,
  });

  const InputWrapper.select({
    super.key,
    this.type = NamedInputType.listSelector,
    required this.title,
    required this.options,
    required this.onChange,
    required this.value,
    this.tooltip,
    this.isRequired = false,
    this.showError = false,
    this.controller,
    this.formatter,
    this.state,
    this.width,
    this.inputType,
  });

  const InputWrapper.icon({
    super.key,
    this.type = NamedInputType.iconSelector,
    required this.title,
    required this.onChange,
    this.controller,
    this.tooltip,
    this.isRequired = false,
    this.showError = false,
    this.options,
    this.value,
    this.formatter,
    this.state,
    this.width,
    this.inputType,
  });

  const InputWrapper.color({
    super.key,
    this.type = NamedInputType.colorSelector,
    required this.title,
    required this.onChange,
    this.controller,
    this.tooltip,
    this.isRequired = false,
    this.showError = false,
    this.options,
    this.value,
    this.formatter,
    this.state,
    this.width,
    this.inputType,
  });

  const InputWrapper.currency({
    super.key,
    this.type = NamedInputType.currencySelector,
    required this.value,
    required this.title,
    required this.onChange,
    this.controller,
    this.tooltip,
    this.isRequired = false,
    this.showError = false,
    this.options,
    this.formatter,
    this.state,
    this.width,
    this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    final min = ScreenHelper.state().isRight;
    String? hint = min ? title : tooltip;
    Color? hintColor;
    if (isRequired && min) {
      if (showError) {
        hint = '$hint [!] ${AppLocale.labels.isRequired}';
        hintColor = context.colorScheme.primary;
      } else {
        hint = '$hint*';
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!min)
          isRequired
              ? RequiredWidget(title: title, showError: showError)
              : TextWrapper(title, style: context.textTheme.bodyLarge),
        switch (type) {
          NamedInputType.textInput => SimpleInput(
              controller: controller!,
              tooltip: hint,
              withLabel: min,
              hintColor: hintColor,
              formatter: formatter,
              type: inputType ?? TextInputType.text,
            ),
          NamedInputType.listSelector => ListSelector(
              value: value,
              tooltip: tooltip,
              hintText: hint,
              hintColor: hintColor,
              options: options as List<ListSelectorItem>,
              setState: onChange!,
              withLabel: min,
            ),
          NamedInputType.iconSelector => IconSelector(
              value: value,
              setState: onChange!,
              hintText: hint,
              withLabel: min,
            ),
          NamedInputType.colorSelector => ColorSelector(
              value: value,
              setState: onChange!,
              withLabel: min,
            ),
          NamedInputType.currencySelector => BaseCurrencySelector(
              value: value,
              textTheme: context.textTheme,
              colorScheme: context.colorScheme,
              update: onChange!,
              withLabel: min,
              labelText: title,
            ),
          NamedInputType.currencyShort => CodeCurrencySelector(
              value: value,
              textTheme: context.textTheme,
              colorScheme: context.colorScheme,
              update: onChange!,
              withLabel: min,
              labelText: title,
            ),
          NamedInputType.ymSelector => MonthYearInput(
              value: value,
              setState: onChange!,
              withLabel: min,
              labelText: title,
            ),
          NamedInputType.accountSelector => ListAccountSelector(
              value: value,
              hintText: hint,
              tooltip: tooltip,
              state: state!,
              setState: onChange!,
              width: width!,
              withLabel: min,
              options: options?.cast() ?? [],
            ),
          NamedInputType.budgetSelector => ListBudgetSelector(
              value: value,
              hintText: hint,
              tooltip: tooltip,
              state: state!,
              setState: onChange!,
              width: width!,
              withLabel: min,
            ),
        },
        ThemeHelper.hIndent2x,
      ],
    );
  }
}