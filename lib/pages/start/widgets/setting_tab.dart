// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_classes/herald/app_palette.dart';
import 'package:app_finance/_classes/herald/app_theme.dart';
import 'package:app_finance/_classes/herald/app_zoom.dart';
import 'package:app_finance/_classes/structure/currency/currency_provider.dart';
import 'package:app_finance/_classes/storage/app_preferences.dart';
import 'package:app_finance/_configs/custom_color_scheme.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/_ext/build_context_ext.dart';
import 'package:app_finance/widgets/form/currency_selector.dart';
import 'package:app_finance/widgets/form/list_selector.dart';
import 'package:app_finance/pages/start/widgets/abstract_tab.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SettingTab extends AbstractTab {
  const SettingTab({
    super.key,
    required super.setState,
    super.isFirstBoot = true,
  });

  @override
  SettingTabState createState() => SettingTabState();
}

class SettingTabState<T extends SettingTab> extends AbstractTabState<T> {
  late AppTheme theme;
  late AppZoom zoom;
  late AppPalette palette;
  Currency? currency;
  bool isEncrypted = false;
  bool hasEncrypted = false;
  String brightness = '0';
  String colorMode = AppColors.colorApp;

  @override
  void initState() {
    super.initState();
    final doEncrypt = AppPreferences.get(AppPreferences.prefDoEncrypt);
    hasEncrypted = doEncrypt != null;
    isEncrypted = doEncrypt == 'true' || doEncrypt == null;
    AppPreferences.set(AppPreferences.prefDoEncrypt, isEncrypted ? 'true' : 'false');
    brightness = AppPreferences.get(AppPreferences.prefTheme) ?? brightness;
    colorMode = AppPreferences.get(AppPreferences.prefColor) ?? colorMode;
  }

  void saveEncryption(newValue) {
    if (hasEncrypted) {
      return;
    }
    setState(() => isEncrypted = newValue);
    AppPreferences.set(AppPreferences.prefDoEncrypt, isEncrypted ? 'true' : 'false');
  }

  Future<void> saveCurrency(Currency? value) async {
    await AppPreferences.set(AppPreferences.prefCurrency, value!.code);
    setState(() => currency = value);
  }

  Future<void> saveTheme(String value) async {
    await theme.setTheme(value);
    setState(() => brightness = value);
  }

  Future<void> saveColor(String value) async {
    await palette.setMode(value);
    setState(() => colorMode = value);
  }

  Future<void> initCurrencyFromLocale(String locale) async {
    final format = NumberFormat.simpleCurrency(locale: locale);
    String? code = AppPreferences.get(AppPreferences.prefCurrency);
    if (code == null && format.currencyName != null) {
      await AppPreferences.set(AppPreferences.prefCurrency, format.currencyName!);
      code = format.currencyName!;
    }
    setState(() => currency = CurrencyProvider.findByCode(code));
  }

  @override
  String getButtonTitle() => AppLocale.labels.saveSettingsTooltip;

  @override
  Widget buildContent(BuildContext context, BoxConstraints constraints) {
    String locale = Localizations.localeOf(context).toString();
    theme = Provider.of<AppTheme>(context, listen: false);
    zoom = Provider.of<AppZoom>(context, listen: false);
    palette = Provider.of<AppPalette>(context, listen: false);
    final TextTheme textTheme = context.textTheme;
    double indent = ThemeHelper.getIndent(2);
    if (currency == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => initCurrencyFromLocale(locale));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeHelper.hIndent2x,
          Text(
            AppLocale.labels.currencyDefault,
            style: textTheme.bodyLarge,
          ),
          CurrencySelector(
            value: currency?.code,
            hintText: AppLocale.labels.currencyTooltip,
            setState: saveCurrency,
          ),
          ThemeHelper.hIndent2x,
          if (kDebugMode) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  AppLocale.labels.encryptionMode,
                  style: textTheme.bodyLarge,
                ),
                Switch(
                  value: isEncrypted,
                  onChanged: saveEncryption,
                ),
                Expanded(
                  child: hasEncrypted ? Text(AppLocale.labels.hasEncrypted) : ThemeHelper.emptyBox,
                ),
              ],
            ),
            ThemeHelper.hIndent2x,
          ],
          Text(
            AppLocale.labels.brightnessTheme,
            style: textTheme.bodyLarge,
          ),
          ListSelector(
            value: brightness,
            hintText: AppLocale.labels.brightnessTheme,
            options: [
              ListSelectorItem(id: '0', name: AppLocale.labels.systemMode),
              ListSelectorItem(id: '1', name: AppLocale.labels.lightMode),
              ListSelectorItem(id: '2', name: AppLocale.labels.darkMode),
            ],
            setState: saveTheme,
            indent: indent,
          ),
          ThemeHelper.hIndent2x,
          Text(
            AppLocale.labels.colorTheme,
            style: textTheme.bodyLarge,
          ),
          ListSelector(
            value: colorMode,
            hintText: AppLocale.labels.brightnessTheme,
            options: [
              ListSelectorItem(id: AppColors.colorApp, name: AppLocale.labels.colorApp),
              ListSelectorItem(id: AppColors.colorSystem, name: AppLocale.labels.colorSystem),
              ListSelectorItem(id: AppColors.colorUser, name: AppLocale.labels.colorUser),
            ],
            setState: saveColor,
            indent: indent,
          ),
          ThemeHelper.hIndent2x,
          Text(
            AppLocale.labels.zoomState,
            style: textTheme.bodyLarge,
          ),
          Container(
            color: context.colorScheme.fieldBackground,
            child: Slider(
              value: zoom.value,
              onChanged: zoom.set,
              min: AppZoom.min,
              max: AppZoom.max,
              divisions: 15,
              label: zoom.value.toStringAsFixed(2),
            ),
          ),
          ThemeHelper.hIndent2x,
        ],
      ),
    );
  }
}