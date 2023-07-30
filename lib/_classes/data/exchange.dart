// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:app_finance/_classes/data/currency_app_data.dart';
import 'package:app_finance/_mixins/shared_preferences_mixin.dart';
import 'package:app_finance/_classes/app_data.dart';
import 'package:currency_picker/currency_picker.dart';

class Exchange with SharedPreferencesMixin {
  AppData store;
  static Currency? defaultCurrency;

  Exchange({
    required this.store,
  });

  Future<Currency?> getDefaultCurrency() async {
    if (defaultCurrency == null) {
      final code = getPreference(prefCurrency) ?? 'EUR';
      defaultCurrency = CurrencyService().findByCode(code);
    }
    return defaultCurrency;
  }

  double reform(double? amount, Currency? origin, Currency? target) {
    amount ??= 0.0;
    if (origin?.code != target?.code) {
      CurrencyAppData? ex = store.getByUuid('${origin?.code}-${target?.code}');
      if (ex == null) {
        ex = CurrencyAppData(
          currency: target,
          currencyFrom: origin,
        );
        store.add(AppDataType.currencies, ex);
      }
      amount *= ex.details;
    }
    return amount;
  }
}
