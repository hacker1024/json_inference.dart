# json_inference

_A Dart package providing functionality to infer JSON data types._

`json_inference` can analyze multiple JSON samples, and infer their defining formats.

## Example

### Input

#### Sample 1

```json
{
  "value1": 1,
  "value2": 2.0,
  "value3": "3",
  "value4": true
}
```

#### Sample 2

```json
{
  "value1": 4,
  "value2": 5,
  "value3": 6
}
```

### Output (in JSON form)

```json
{
  "type": "JSON object",
  "optional": false,
  "fields": {
    "value1": {
      "type": "Integer",
      "optional": false
    },
    "value2": {
      "type": "Number",
      "optional": false
    },
    "value3": {
      "type": "Object",
      "optional": false
    },
    "value4": {
      "type": "Boolean",
      "optional": true
    }
  }
}
```

## Usage

```dart
import 'package:json_inference/json_inference.dart';

void main() {
  const a = { /* ... */ };
  const b = { /* ... */ };
  
  // Generate a [ValueType] describing each sample:
  final aValueType = inferValueType(a);
  final bValueType = inferValueType(b);
  
  // Combine the [ValueType]s, to select the most specific description
  // applying to each field across all samples:
  var combinedValueType = generalizeValueTypes([aValueType, bValueType]);
  
  // Or, do all of the above at once:
  combinedValueType = inferValueTypes([a, b]);
  
  // [ValueType] inferences can always be improved when more samples become
  // available.
  const c = { /* ... */ };
  combinedValueType = generalizeValueTypes([
    combinedValueType,
    inferValueType(c),
  ]);
}
```
