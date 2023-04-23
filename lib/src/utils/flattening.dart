import 'package:json_inference/src/value_type.dart';
import 'package:json_inference/src/value_types/collection.dart';

extension ValueTypeFlattening on ValueType {
  /// Recursively traverses the [ValueType] children, producing a flat list of
  /// [NestedObjectValueTypeEntry]s.
  Iterable<NestedObjectValueTypeEntry> flattenObjectTypes(
    String name, {
    NestedObjectValueTypeParentCategory parentCategory =
        NestedObjectValueTypeParentCategory.root,
  }) sync* {
    final valueType = this;
    if (valueType is TypedJsonObjectValueType) {
      yield NestedObjectValueTypeEntry(
        name: name,
        parentCategory: parentCategory,
        valueType: valueType,
      );
      for (final entry in valueType.fieldValueTypes.entries) {
        yield* entry.value.flattenObjectTypes(
          entry.key,
          parentCategory: NestedObjectValueTypeParentCategory.object,
        );
      }
    } else if (valueType is TypedListValueType) {
      yield* valueType.elementValueType.flattenObjectTypes(
        name,
        parentCategory: NestedObjectValueTypeParentCategory.list,
      );
    } else if (valueType is TypedJsonMapValueType) {
      yield* valueType.keyValueType.flattenObjectTypes(
        name,
        parentCategory: NestedObjectValueTypeParentCategory.map,
      );
      yield* valueType.valueValueType.flattenObjectTypes(
        name,
        parentCategory: NestedObjectValueTypeParentCategory.map,
      );
    }
  }
}

/// The type of the parent of a [NestedObjectValueTypeEntry].
enum NestedObjectValueTypeParentCategory {
  /// The top-level JSON structure.
  root,

  /// A JSON object.
  object,

  /// A JSON object with arbitrary keys and consistently typed values.
  map,

  /// A JSON list.
  list,
}

/// Metadata about a [TypedJsonObjectValueType] found during the flattening
/// process.
class NestedObjectValueTypeEntry<J, D> {
  /// The key that the [valueType] was found at.
  final String name;

  /// The type of the [valueType] parent.
  final NestedObjectValueTypeParentCategory parentCategory;

  /// The [TypedJsonObjectValueType] that was found.
  final TypedJsonObjectValueType<J, D> valueType;

  const NestedObjectValueTypeEntry({
    required this.name,
    required this.parentCategory,
    required this.valueType,
  });

  @override
  String toString() =>
      'NestedObjectValueTypeEntry(name: $name, parentCategory: $parentCategory, valueType: $valueType)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NestedObjectValueTypeEntry &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          parentCategory == other.parentCategory &&
          valueType == other.valueType;

  @override
  int get hashCode => Object.hash(name, parentCategory, valueType);
}
