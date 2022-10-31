import 'package:json_inference/src/value_types/collection.dart';
import 'package:json_inference/src/value_types/primitive.dart';

abstract class ValueType<J, D> {
  final bool optional;

  const ValueType({required this.optional});

  String get type;

  List<ValueType>? get typeArguments => null;

  String get fullType => typeArguments == null
      ? type
      : '$type<${typeArguments!.map((typeArgument) => typeArgument.type).join(', ')}>';

  ValueType<J, D> asOptional({bool optional = true});

  Map<String, dynamic> toJson();

  static ValueType fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type is! String) {
      throw FormatException(
        'No valid type value is in the provided JSON.',
        json,
      );
    }
    return _deserializationRegistry[type]?.call(json) ??
        (throw FormatException('Unknown type: $type', json));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueType<J, D> &&
          runtimeType == other.runtimeType &&
          optional == other.optional;

  @override
  int get hashCode => optional.hashCode;

  static final _deserializationRegistry =
      <String, ValueType Function(Map<String, dynamic> fromJson)>{
    const PrimitiveValueType(optional: false).type: PrimitiveValueType.fromJson,
    const UnknownValueType(optional: true).type: UnknownValueType.fromJson,
    const StringValueType(optional: false).type: StringValueType.fromJson,
    const NumberValueType(optional: false).type: NumberValueType.fromJson,
    const IntegerValueType(optional: false).type: IntegerValueType.fromJson,
    const DoubleValueType(optional: false).type: DoubleValueType.fromJson,
    const BooleanValueType(optional: false).type: BooleanValueType.fromJson,
    const TypedJsonObjectValueType(
      {},
      optional: false,
    ).type: TypedJsonObjectValueType.fromJson,
    const TypedJsonMapValueType(
      StringValueType(optional: false),
      UnknownValueType(optional: true),
      optional: false,
    ).type: TypedJsonMapValueType.fromJson,
    const TypedListValueType(
      UnknownValueType(optional: true),
      optional: false,
    ).type: TypedListValueType.fromJson,
  };
}

mixin SimpleValueTypeSerialization<J, D> on ValueType<J, D> {
  @override
  Map<String, dynamic> toJson() => {'type': type, 'optional': optional};

  static T fromJson<T extends ValueType>(
    Map<String, dynamic> json,
    T Function({required bool optional}) factory,
  ) =>
      factory(optional: json['optional'] as bool);
}
