import 'package:json_inference/src/value_type.dart';

class PrimitiveValueType<T> extends ValueType<T, T>
    with SimpleValueTypeSerialization {
  const PrimitiveValueType({required super.optional});

  @override
  String get type => 'Object';

  @override
  PrimitiveValueType<T> asOptional({bool optional = true}) =>
      PrimitiveValueType(optional: optional);

  static PrimitiveValueType fromJson(Map<String, dynamic> json) =>
      SimpleValueTypeSerialization.fromJson(json, PrimitiveValueType.new);
}

/// A [ValueType] representing an unknown value.
///
/// This should be used in cases where a `null` value is encountered, and the
/// type of the value cannot be determined without more sample data.
class UnknownValueType extends PrimitiveValueType<dynamic>
    with SimpleValueTypeSerialization {
  const UnknownValueType({required super.optional})
      : assert(
          optional,
          'It makes no sense to have a non-optional unknown value type!',
        );

  @override
  String get type => 'Unknown';

  @override
  UnknownValueType asOptional({bool optional = true}) =>
      UnknownValueType(optional: optional);

  static UnknownValueType fromJson(Map<String, dynamic> json) =>
      SimpleValueTypeSerialization.fromJson(json, UnknownValueType.new);
}

class StringValueType extends PrimitiveValueType<String>
    with SimpleValueTypeSerialization {
  const StringValueType({required super.optional});

  @override
  String get type => 'String';

  @override
  StringValueType asOptional({bool optional = true}) =>
      StringValueType(optional: optional);

  static StringValueType fromJson(Map<String, dynamic> json) =>
      SimpleValueTypeSerialization.fromJson(json, StringValueType.new);
}

class NumberValueType<T extends num> extends PrimitiveValueType<T>
    with SimpleValueTypeSerialization {
  const NumberValueType({required super.optional});

  @override
  String get type => 'Number';

  @override
  NumberValueType<T> asOptional({bool optional = true}) =>
      NumberValueType<T>(optional: optional);

  static NumberValueType fromJson(Map<String, dynamic> json) =>
      SimpleValueTypeSerialization.fromJson(json, NumberValueType.new);
}

class IntegerValueType extends NumberValueType<int>
    with SimpleValueTypeSerialization {
  const IntegerValueType({required super.optional});

  @override
  String get type => 'Integer';

  @override
  IntegerValueType asOptional({bool optional = true}) =>
      IntegerValueType(optional: optional);

  static IntegerValueType fromJson(Map<String, dynamic> json) =>
      SimpleValueTypeSerialization.fromJson(json, IntegerValueType.new);
}

class DoubleValueType extends NumberValueType<double>
    with SimpleValueTypeSerialization {
  const DoubleValueType({required super.optional});

  @override
  String get type => 'Double';

  @override
  DoubleValueType asOptional({bool optional = true}) =>
      DoubleValueType(optional: optional);

  static DoubleValueType fromJson(Map<String, dynamic> json) =>
      SimpleValueTypeSerialization.fromJson(json, DoubleValueType.new);
}

class BooleanValueType extends PrimitiveValueType<bool>
    with SimpleValueTypeSerialization {
  const BooleanValueType({required super.optional});

  @override
  String get type => 'Boolean';

  @override
  BooleanValueType asOptional({bool optional = true}) =>
      BooleanValueType(optional: optional);

  static BooleanValueType fromJson(Map<String, dynamic> json) =>
      SimpleValueTypeSerialization.fromJson(json, BooleanValueType.new);
}
