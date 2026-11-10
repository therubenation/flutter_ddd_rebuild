import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ddd_resocoder/domain/core/failures.dart';
import 'package:fpdart/fpdart.dart';

@immutable
abstract class ValueObject<T> extends Equatable {
  const ValueObject();

  abstract final Either<ValueFailure<String>, T> value;

  bool isValid() => value.isRight();

  @override
  List<Object?> get props => [value]; // props tells Equatable which properties determine equality.
}
