import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'failures.freezed.dart';

// ValueFailure<T> groups different validation failures into a union
// Instead of manually implementing individual failure classes,
//  we declare their constructors and concrete types in one union definition and let Freezed generate the classes.

@freezed // metadata that tells Freezed's code generator to process this class. It effectively says: Generate the supporting implementation for the model and its declared variants.
abstract class ValueFailure<T> with _$ValueFailure<T> {
  const factory ValueFailure.invalidEmail({required T failedValue}) =
      InvalidEmail<T>;
  const factory ValueFailure.shortPassword({required T failedValue}) =
      ShortPassword<T>;
}
