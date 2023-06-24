import 'package:json_inference/src/value_type.dart';

abstract class CollectionValueType<J, D> extends ValueType<J, D> {
  const CollectionValueType({required super.optional});
}

abstract class JsonObjectValueType<D>
    extends CollectionValueType<Map<String, dynamic>, D> {
  const JsonObjectValueType({required super.optional});

  @override
  String get type => 'JSON object';
}

class TypedJsonObjectValueType<J, D>
    extends JsonObjectValueType<Map<String, D>> {
  final Map<String, ValueType<J, D>> fieldValueTypes;

  const TypedJsonObjectValueType(
    this.fieldValueTypes, {
    required super.optional,
  });

  @override
  TypedJsonObjectValueType<J, D> asOptional({bool optional = true}) =>
      TypedJsonObjectValueType(
        fieldValueTypes,
        optional: optional,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'optional': optional,
        'fields':
            fieldValueTypes.map((key, value) => MapEntry(key, value.toJson())),
      };

  static TypedJsonObjectValueType fromJson(Map<String, dynamic> json) =>
      TypedJsonObjectValueType(
        (json['fields'] as Map<String, dynamic>)
            .cast<String, Map<String, dynamic>>()
            .map((key, value) => MapEntry(key, ValueType.fromJson(value))),
        optional: json['optional'] as bool,
      );
}

class TypedJsonMapValueType<K, J, D> extends JsonObjectValueType<Map<K, D>> {
  final ValueType<String, K> keyValueType;
  final ValueType<J, D> valueValueType;

  const TypedJsonMapValueType(
    this.keyValueType,
    this.valueValueType, {
    required super.optional,
  });

  @override
  String get type => 'Map';

  @override
  List<ValueType> get typeArguments => [keyValueType, valueValueType];

  @override
  TypedJsonMapValueType<K, J, D> asOptional({bool optional = true}) =>
      TypedJsonMapValueType(
        keyValueType,
        valueValueType,
        optional: optional,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'optional': optional,
        'keyType': keyValueType.toJson(),
        'valueType': valueValueType.toJson(),
      };

  static TypedJsonMapValueType fromJson(Map<String, dynamic> json) =>
      TypedJsonMapValueType(
        ValueType.fromJson(json['keyType'] as Map<String, dynamic>)
            as ValueType<String, dynamic>,
        ValueType.fromJson(json['valueType'] as Map<String, dynamic>),
        optional: json['optional'] as bool,
      );
}

abstract class ListValueType<D> extends CollectionValueType<List<dynamic>, D> {
  const ListValueType({required super.optional});

  @override
  String get type => 'List';
}

class TypedListValueType<J, D> extends ListValueType<List<D>> {
  final ValueType elementValueType;

  const TypedListValueType(
    this.elementValueType, {
    required super.optional,
  });

  @override
  List<ValueType>? get typeArguments => [elementValueType];

  @override
  TypedListValueType<J, D> asOptional({bool optional = true}) =>
      TypedListValueType(
        elementValueType,
        optional: optional,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'optional': optional,
        'elementType': elementValueType.toJson(),
      };

  static TypedListValueType fromJson(Map<String, dynamic> json) =>
      TypedListValueType(
        ValueType.fromJson(json['elementType'] as Map<String, dynamic>),
        optional: json['optional'] as bool,
      );
}
