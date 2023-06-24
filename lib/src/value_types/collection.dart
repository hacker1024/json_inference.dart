part of '../value_type.dart';

abstract base class CollectionValueType<J, D> extends ValueType<J, D> {
  const CollectionValueType({required super.optional});
}

sealed class JsonObjectValueType<D>
    extends CollectionValueType<Map<String, dynamic>, D> {
  const JsonObjectValueType({required super.optional});

  @override
  String get type => 'JSON object';
}

final class TypedJsonObjectValueType<J, D>
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

  static TypedJsonObjectValueType fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'fields': final Map<String, dynamic> fields,
          'optional': final bool optional,
        }) {
      return TypedJsonObjectValueType(
        fields.map(
          (key, value) {
            if (value is! Map<String, dynamic>) {
              throw FormatException('Invalid field value type data.', value);
            }
            return MapEntry(key, ValueType.fromJson(value));
          },
        ),
        optional: optional,
      );
    } else {
      throw FormatException('Invalid JSON object value type data.', json);
    }
  }
}

final class TypedJsonMapValueType<K, J, D>
    extends JsonObjectValueType<Map<K, D>> {
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

  static TypedJsonMapValueType fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'keyType': final Map<String, dynamic> keyTypeJson,
          'valueType': final Map<String, dynamic> valueTypeJson,
          'optional': final bool optional,
        }) {
      return TypedJsonMapValueType(
        switch (ValueType.fromJson(keyTypeJson)) {
          final ValueType<String, dynamic> keyType => keyType,
          _ => throw FormatException('Invalid map key value type data.', json),
        },
        ValueType.fromJson(valueTypeJson),
        optional: optional,
      );
    } else {
      throw FormatException('Invalid map value type data.', json);
    }
  }
}

sealed class ListValueType<D> extends CollectionValueType<List<dynamic>, D> {
  const ListValueType({required super.optional});

  @override
  String get type => 'List';
}

final class TypedListValueType<J, D> extends ListValueType<List<D>> {
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

  static TypedListValueType fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'elementType': final Map<String, dynamic> elementTypeJson,
          'optional': final bool optional,
        }) {
      return TypedListValueType(
        ValueType.fromJson(elementTypeJson),
        optional: optional,
      );
    } else {
      throw FormatException('Invalid list value type data.', json);
    }
  }
}
