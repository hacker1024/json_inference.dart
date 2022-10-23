// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:json_inference/json_inference.dart';

void main() {
  const a = {
    'value1': 1,
    'value2': 2.0,
    'value3': '3',
    'value4': true,
  };

  const b = {
    'value1': 4,
    'value2': 5,
    'value3': 6,
  };

  final valueType = inferValueTypes([a, b]);

  print(const JsonEncoder.withIndent('  ').convert(a));
  print(const JsonEncoder.withIndent('  ').convert(b));
  print(const JsonEncoder.withIndent('  ').convert(valueType));
}
