import 'package:json_inference/src/value_type.dart';

class PrimitiveValueType<T> extends ValueType<T, T> {
  const PrimitiveValueType({required super.optional});

  @override
  String get name => 'Object';

  @override
  PrimitiveValueType<T> asOptional({bool optional = true}) =>
      PrimitiveValueType(optional: optional);
}

/// A [ValueType] representing an unknown value.
///
/// This should be used in cases where a `null` value is encountered, and the
/// type of the value cannot be determined without more sample data.
class UnknownValueType extends PrimitiveValueType<dynamic> {
  const UnknownValueType({required super.optional})
      : assert(
          optional,
          'It makes no sense to have a non-optional unknown value type!',
        );

  @override
  String get name => 'Unknown';

  @override
  UnknownValueType asOptional({bool optional = true}) =>
      UnknownValueType(optional: optional);
}

class StringValueType extends PrimitiveValueType<String> {
  const StringValueType({required super.optional});

  @override
  String get name => 'String';

  @override
  StringValueType asOptional({bool optional = true}) =>
      StringValueType(optional: optional);
}

class NumberValueType<T extends num> extends PrimitiveValueType<T> {
  const NumberValueType({required super.optional});

  @override
  String get name => 'Number';

  @override
  NumberValueType<T> asOptional({bool optional = true}) =>
      NumberValueType<T>(optional: optional);
}

class IntegerValueType extends NumberValueType<int> {
  const IntegerValueType({required super.optional});

  @override
  String get name => 'Integer';

  @override
  IntegerValueType asOptional({bool optional = true}) =>
      IntegerValueType(optional: optional);
}

class DoubleValueType extends NumberValueType<double> {
  const DoubleValueType({required super.optional});

  @override
  String get name => 'Double';

  @override
  DoubleValueType asOptional({bool optional = true}) =>
      DoubleValueType(optional: optional);
}

class BooleanValueType extends PrimitiveValueType<bool> {
  const BooleanValueType({required super.optional});

  @override
  String get name => 'Boolean';

  @override
  BooleanValueType asOptional({bool optional = true}) =>
      BooleanValueType(optional: optional);
}
