abstract class ValueType<J, D> {
  final bool optional;

  const ValueType({required this.optional});

  String get name;

  ValueType<J, D> asOptional({bool optional = true});

  Map<String, dynamic> toJson() => {'type': name, 'optional': optional};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueType<J, D> &&
          runtimeType == other.runtimeType &&
          optional == other.optional;

  @override
  int get hashCode => optional.hashCode;
}
