part of 'sign_in_form_bloc.dart';

@freezed
sealed class SignInFormState with _$SignInFormState {
  const factory SignInFormState({
    required EmailAddress emailAddress,
    required Password password,
    required bool isSubmitting,
    required bool showErrorMessages,
    required Option<Either<AuthFailure, Unit>> authFailureOrSuccessOption,
  }) =
      _SignInFormState; // _SignInFormState tells Dart to redirect construction to the concrete implementation

  factory SignInFormState.initial() => SignInFormState(
    emailAddress: EmailAddress(''),
    password: Password(''),
    isSubmitting: false,
    showErrorMessages: false,
    authFailureOrSuccessOption: Option.none(),
  );
}
