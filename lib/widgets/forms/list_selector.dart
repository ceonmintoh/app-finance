// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class ListSelectorItem {
  final String id;
  final String name;

  ListSelectorItem({required this.id, required this.name});
}

class ListSelector extends StatelessWidget {
  List<ListSelectorItem> options;
  Function setState;
  TextStyle? style;
  String? value;
  double indent;

  ListSelector({
    super.key,
    required this.options,
    required this.setState,
    this.style,
    this.value,
    this.indent = 0.0,
  });

  @override
  Widget build(context) {
    return Container(
      color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
      width: double.infinity,
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        onChanged: (value) => setState(value),
        items: options.map<DropdownMenuItem<String>>((ListSelectorItem value) {
          return DropdownMenuItem<String>(
            value: value.id,
            child: Padding(
              padding: EdgeInsets.only(left: indent),
              child: Text(value.name, style: style),
            ),
          );
        }).toList(),
      ),
    );
  }
}
