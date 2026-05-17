# otel_quickbooks

Dartastic OpenTelemetry bridge for QuickBooks Online (SMB accounting).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_quickbooks/otel_quickbooks.dart';

await tracedQuickBooks<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return QuickBooksCallResult(value: r, result: QuickBooksResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutQuickBooksInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
