import 'package:flutter_ddd_resocoder/domain/auth/value_objects.dart';
import 'package:fpdart/fpdart.dart';
import 'failures.dart';

Either<ValueFailure<String>, String> validateEmailAddress(String input) {
  const emailRegex =
      r"""^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,}$""";
  final trimmedInput = input.trim();
  if (RegExp(emailRegex).hasMatch(trimmedInput)) {
    return right(trimmedInput);
  } else {
    return left(ValueFailure.invalidEmail(failedValue: input));
  }
}

Either<ValueFailure<String>, String> validatePassword(String input) {
  if (input.length >= 6) {
    // TODO implement logic
    return right(input);
  } else {
    return left(ValueFailure.shortPassword(failedValue: input));
  }
}
