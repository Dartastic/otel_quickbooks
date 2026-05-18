// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_quickbooks_suppression.dart';

class QuickBooksResult {
  const QuickBooksResult({
    this.realmId,
    this.entity,
    this.entityId,
    this.customerId,
    this.vendorId,
    this.invoiceId,
    this.amount,
    this.currency,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? realmId;
  final String? entity;
  final String? entityId;
  final String? customerId;
  final String? vendorId;
  final String? invoiceId;
  final double? amount;
  final String? currency;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class QuickBooksCallResult<T> {
  const QuickBooksCallResult({required this.value, this.result});
  final T value;
  final QuickBooksResult? result;
}

Future<T> tracedQuickBooks<T>({
  required String operation,
  required Future<QuickBooksCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (quickBooksInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_quickbooks');
  final span = t.startSpan('qbo $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'quickbooks');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.realmId != null) {
        span.setStringAttribute('quickbooks.realm.id', res.realmId!);
      }
      if (res.entity != null) {
        span.setStringAttribute('quickbooks.entity', res.entity!);
      }
      if (res.entityId != null) {
        span.setStringAttribute('quickbooks.entity.id', res.entityId!);
      }
      if (res.customerId != null) {
        span.setStringAttribute('quickbooks.customer.id', res.customerId!);
      }
      if (res.vendorId != null) {
        span.setStringAttribute('quickbooks.vendor.id', res.vendorId!);
      }
      if (res.invoiceId != null) {
        span.setStringAttribute('quickbooks.invoice.id', res.invoiceId!);
      }
      if (res.amount != null) {
        span.setDoubleAttribute('quickbooks.amount', res.amount!);
      }
      if (res.currency != null) {
        span.setStringAttribute('quickbooks.currency', res.currency!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('qbo.error.code', res.errorCode!);
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
            ErrorResource.errorType.key, res.errorCode ?? 'qbo.error');
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
