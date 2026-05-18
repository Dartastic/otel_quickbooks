// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_quickbooks/otel_quickbooks.dart';
import 'package:test/test.dart';

void main() {
  group('otel_quickbooks', () {
    test('suppression toggles in zone', () async {
      expect(quickBooksInstrumentationSuppressed(), isFalse);
      await runWithoutQuickBooksInstrumentationAsync(() async {
        expect(quickBooksInstrumentationSuppressed(), isTrue);
      });
      expect(quickBooksInstrumentationSuppressed(), isFalse);
    });

    test('QuickBooksResult fields default null', () {
      const r = QuickBooksResult();
      expect(r.statusCode, isNull);
    });
  });
}
