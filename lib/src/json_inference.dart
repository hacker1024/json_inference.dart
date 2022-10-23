import 'package:json_inference/src/value_type.dart';
import 'package:json_inference/src/value_types/collection.dart';
import 'package:json_inference/src/value_types/primitive.dart';

ValueType inferValueType(Object? value) =>
    _estimateJsonFieldValueType(null, value);

ValueType inferValueTypes(Iterable<dynamic> values) =>
    generalizeValueTypes(values.map(inferValueType).toList(growable: false));

ValueType _estimateJsonFieldValueType(
  String? key,
  Object? value,
) {
  if (value == null) {
    return const UnknownValueType(optional: true);
  } else if (value is String) {
    return const StringValueType(optional: false);
  } else if (value is num) {
    if (value is int) {
      return const IntegerValueType(optional: false);
    } else if (value is double) {
      return const DoubleValueType(optional: false);
    }
    return const NumberValueType(optional: false);
  } else if (value is bool) {
    return const BooleanValueType(optional: false);
  } else if (value is List) {
    return TypedListValueType(
      inferValueTypes(value),
      optional: false,
    );
  } else if (value is Map<String, dynamic>) {
    if (value.isEmpty) {
      // If the map is empty, it's more likely to be an empty JSON map than a
      // JSON object with no fields, so treat it as such.
      return const TypedJsonMapValueType(
        keyValueType: StringValueType(optional: false),
        valueValueType: UnknownValueType(optional: true),
        optional: false,
      );
    }

    // Determine whether the non-empty map is a (specialised) JSON map or not.
    final keyValueType =
        inferValueTypes(value.keys) as ValueType<String, dynamic>;
    if (keyValueType != const StringValueType(optional: false)) {
      // If the JSON object key types aren't standard strings (i.e. they're
      // strings of a specific format with a unique [ValueType]), treat the
      // object like a map.
      final valueValueType = inferValueTypes(value.values);
      return TypedJsonMapValueType(
        keyValueType: keyValueType,
        valueValueType: valueValueType,
        optional: false,
      );
    }

    return TypedJsonObjectValueType(
      fieldValueTypes: value.map(
        (key, value) => MapEntry(key, _estimateJsonFieldValueType(key, value)),
      ),
      optional: false,
    );
  }

  throw UnsupportedError('Unsupported JSON value type: ${value.runtimeType}');
}

ValueType generalizeValueTypes(List<ValueType> valueTypes) {
  // If any of the value types are optional, the final result must also be.
  final bool optional = valueTypes.any((valueType) => valueType.optional);

  // Ignore [UnknownValueType]s, as they're just placeholder values and should
  // not be considered in generalization. Their only relevance is that their
  // presence means that the generalized value type is optional, which has been
  // accounted for.
  final relevantValueTypes = valueTypes
      .where((element) => element is! UnknownValueType)
      .toList(growable: false);

  // If, after removing [UnknownValueType]s, there are no value types remaining,
  // then the value type remains unknown.
  if (relevantValueTypes.isEmpty) {
    return const UnknownValueType(optional: true);
  }

  // If there's only one value type to generalize, use it.
  if (relevantValueTypes.length == 1) {
    return relevantValueTypes.first.asOptional(optional: optional);
  }

  /// Generalize the given value types by matching them with common base types.
  ///
  /// This must be done in a careful order, as specific types must not be
  /// shadowed by prior matches against their base type.
  ///
  /// A set of [IntegerValueType]s, for example, should not be generalized as
  /// a [NumberValueType], which would happen if a check against
  /// [NumberValueType] was done first.
  ///
  /// To prevent these problems from occurring, the generalization process is
  /// structured as follows:
  ///
  /// - Subtype checks are generally grouped by if statements checking for their
  ///   base type. If their base type is concrete, it should be used if the
  ///   [valueTypes] do not all match just one.
  /// - If subtype checks are not in their base type group, they must be
  ///   performed before the base type group check.
  bool allAre<T>() => relevantValueTypes.every((valueType) => valueType is T);

  // Generalize primitive types.
  if (allAre<PrimitiveValueType>()) {
    if (allAre<StringValueType>()) {
      return StringValueType(optional: optional);
    } else if (allAre<NumberValueType>()) {
      if (allAre<IntegerValueType>()) {
        return IntegerValueType(optional: optional);
      } else if (allAre<DoubleValueType>()) {
        return DoubleValueType(optional: optional);
      }
      return NumberValueType(optional: optional);
    } else if (allAre<BooleanValueType>()) {
      return BooleanValueType(optional: optional);
    }
    return PrimitiveValueType(optional: optional);
  }

  // Generalize collection types.
  if (allAre<CollectionValueType>()) {
    // Generalize JSON object types.
    if (allAre<JsonObjectValueType>()) {
      // Generalize typed JSON map types.
      if (allAre<TypedJsonMapValueType>()) {
        return TypedJsonMapValueType(
          keyValueType: generalizeValueTypes(
            relevantValueTypes
                .cast<TypedJsonMapValueType>()
                .map((valueType) => valueType.keyValueType)
                .toList(growable: false),
          ) as ValueType<String, dynamic>,
          valueValueType: generalizeValueTypes(
            relevantValueTypes
                .cast<TypedJsonMapValueType>()
                .map((valueType) => valueType.valueValueType)
                .toList(growable: false),
          ),
          optional: optional,
        );
      }

      // Generalize typed JSON object types.
      // If other object types with unknown fields are present, ignore them.
      final typedJsonObjectValueTypes = relevantValueTypes
          .whereType<TypedJsonObjectValueType>()
          .toList(growable: false);
      return TypedJsonObjectValueType(
        fieldValueTypes: typedJsonObjectValueTypes
            .cast<TypedJsonObjectValueType>()
            .expand((valueType) => valueType.fieldValueTypes.entries)
            .fold<Map<String, List<ValueType>>>(
          {},
          (valueTypeMap, valueDefinition) => valueTypeMap
            ..update(
              valueDefinition.key,
              (valueTypes) => valueTypes..add(valueDefinition.value),
              ifAbsent: () => [valueDefinition.value],
            ),
        ).map((key, propertyValueTypes) {
          var valueType = generalizeValueTypes(propertyValueTypes);
          if (propertyValueTypes.length < relevantValueTypes.length) {
            // If the amount of the property's value types is less than the
            // amount of object value types, some objects must not have the
            // property.
            valueType = valueType.asOptional();
          }
          return MapEntry(key, valueType);
        }),
        optional: optional,
      );
    }

    // Generalize list types.
    if (allAre<ListValueType>()) {
      // Generalize typed JSON list types.
      if (allAre<TypedListValueType>()) {
        return TypedListValueType(
          generalizeValueTypes(
            relevantValueTypes
                .cast<TypedListValueType>()
                .map((valueType) => valueType.elementValueType)
                .toList(growable: false),
          ),
          optional: optional,
        );
      }
    }
  }

  // If no generalizations could be made, fall back on a [NativeValueType] to
  // treat the value as its native JSON/Dart type such as a string or map during
  // parsing.
  //
  // Note that [UnknownValueType] is not appropriate here - the generalized
  // type is not missing due to a lack of information, it's non-existent.
  // If [UnknownValueType] were to be used here, the fact that a generalized
  // type could not be determined would be lost during the next generalization
  // pass, as the [UnknownValueType] will be ignored among any other value types
  // in the list of value types to generalize.
  return PrimitiveValueType<Object>(optional: optional);
}
