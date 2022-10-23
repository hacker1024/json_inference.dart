import 'package:json_inference/src/value_type.dart';

abstract class CollectionValueType<J, D> extends ValueType<J, D> {
  const CollectionValueType({required super.optional});
}

abstract class JsonObjectValueType<D>
    extends CollectionValueType<Map<String, dynamic>, D> {
  const JsonObjectValueType({required super.optional});

  @override
  String get name => 'JSON object';
}

class TypedJsonObjectValueType<J, D>
    extends JsonObjectValueType<Map<String, D>> {
  final Map<String, ValueType<J, D>> fieldValueTypes;

  const TypedJsonObjectValueType({
    required this.fieldValueTypes,
    required super.optional,
  });

  @override
  TypedJsonObjectValueType<J, D> asOptional({bool optional = true}) =>
      TypedJsonObjectValueType(
        fieldValueTypes: fieldValueTypes,
        optional: optional,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'fields':
            fieldValueTypes.map((key, value) => MapEntry(key, value.toJson())),
      };
}

class TypedJsonMapValueType<K, J, D> extends JsonObjectValueType<Map<K, D>> {
  final ValueType<String, K> keyValueType;
  final ValueType<J, D> valueValueType;

  const TypedJsonMapValueType({
    required this.keyValueType,
    required this.valueValueType,
    required super.optional,
  });

  @override
  String get name => 'Map<${keyValueType.name}, ${valueValueType.name}>';

  @override
  TypedJsonMapValueType<K, J, D> asOptional({bool optional = true}) =>
      TypedJsonMapValueType(
        keyValueType: keyValueType,
        valueValueType: valueValueType,
        optional: optional,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'keyType': keyValueType.toJson(),
        'valueType': valueValueType.toJson(),
      };
}

abstract class ListValueType<D> extends CollectionValueType<List<dynamic>, D> {
  const ListValueType({required super.optional});

  @override
  String get name => 'List';
}

class TypedListValueType<J, D> extends ListValueType<List<D>> {
  final ValueType elementValueType;

  const TypedListValueType(
    this.elementValueType, {
    required super.optional,
  });

  @override
  String get name => '${super.name}<${elementValueType.name}>';

  @override
  TypedListValueType<J, D> asOptional({bool optional = true}) =>
      TypedListValueType(
        elementValueType,
        optional: optional,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'elementType': elementValueType.toJson(),
      };
}
