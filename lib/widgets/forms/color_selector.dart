// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class ColorSelector extends StatelessWidget {
  Function setState;
  MaterialColor? value;

  ColorSelector({
    super.key,
    this.value,
    required this.setState,
  });

  MaterialColor convertToMaterialColor(Color color) {
    final red = color.red;
    final green = color.green;
    final blue = color.blue;

    return MaterialColor(
      color.value,
      <int, Color>{
        50: Color.fromRGBO(red, green, blue, 0.1),
        100: Color.fromRGBO(red, green, blue, 0.2),
        200: Color.fromRGBO(red, green, blue, 0.3),
        300: Color.fromRGBO(red, green, blue, 0.4),
        400: Color.fromRGBO(red, green, blue, 0.5),
        500: Color.fromRGBO(red, green, blue, 0.6),
        600: Color.fromRGBO(red, green, blue, 0.7),
        700: Color.fromRGBO(red, green, blue, 0.8),
        800: Color.fromRGBO(red, green, blue, 0.9),
        900: Color.fromRGBO(red, green, blue, 1.0),
      },
    );
  }

  MaterialColor getRandomMaterialColor() {
    List<Color> colors = Colors.primaries;
    Random random = Random();
    Color randomColor = colors[random.nextInt(colors.length)];
    return convertToMaterialColor(randomColor);
  }

  @override
  Widget build(context) {
    return TextFormField(
      readOnly: true,
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.colorTooltip),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: value ?? getRandomMaterialColor(),
                  onColorChanged: (color) =>
                      setState(convertToMaterialColor(color)),
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            );
          },
        );
      },
      decoration: InputDecoration(
        filled: true,
        border: InputBorder.none,
        fillColor: value ??
            Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
        suffixIcon: GestureDetector(
          child: const Icon(Icons.color_lens),
        ),
      ),
    );
  }
}