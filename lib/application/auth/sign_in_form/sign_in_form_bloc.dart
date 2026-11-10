import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fpdart/fpdart.dart';

import 'package:flutter_ddd_resocoder/domain/auth/auth_failure.dart';
import 'package:flutter_ddd_resocoder/domain/auth/i_auth_facade.dart';
import 'package:flutter_ddd_resocoder/domain/auth/value_objects.dart';

part 'sign_in_form_event.dart';
part 'sign_in_form_state.dart';
part 'sign_in_form_bloc.freezed.dart';

class SignInFormBloc extends Bloc<SignInFormEvent, SignInFormState> {
  final IAuthFacade _authFacade;

  SignInFormBloc(this._authFacade) : super(SignInFormState.initial()) {
    // Register ONE handler for all SignInFormEvent variants.
    on<SignInFormEvent>(_onEvent);
  }

  // Exhaustive event dispatcher
  Future<void> _onEvent(
    SignInFormEvent event,
    Emitter<SignInFormState> emit,
  ) async {
    switch (event) {
      case EmailChanged():
        _onEmailChanged(event, emit);

      case PasswordChanged():
        _onPasswordChanged(event, emit);

      case SignInWithGooglePressed():
        await _onSignInWithGooglePressed(event, emit);

      case RegisterWithEmailAndPasswordPressed():
        await _onRegisterWithEmailAndPasswordPressed(event, emit);

      case SignInWithEmailAndPasswordPressed():
        await _onSignInWithEmailAndPasswordPressed(event, emit);
    }
  }

  // 1. Email changed
  void _onEmailChanged(EmailChanged event, Emitter<SignInFormState> emit) {
    final validatedEmail = EmailAddress(event.emailStr);

    emit(
      state.copyWith(
        emailAddress: validatedEmail,
        authFailureOrSuccessOption: Option.none(),
      ),
    );
  }

  // 2. Password changed
  void _onPasswordChanged(
    PasswordChanged event,
    Emitter<SignInFormState> emit,
  ) {
    final validatedPassword = Password(event.passwordStr);

    emit(
      state.copyWith(
        password: validatedPassword,
        authFailureOrSuccessOption: Option.none(),
      ),
    );
  }

  // 3. Sign in with Google
  Future<void> _onSignInWithGooglePressed(
    SignInWithGooglePressed event,
    Emitter<SignInFormState> emit,
  ) async {
    if (state.isSubmitting) return;

    emit(
      state.copyWith(
        isSubmitting: true,
        authFailureOrSuccessOption: Option.none(),
      ),
    );

    final result = await _authFacade.signInWithGoogle();

    if (emit.isDone) return;

    emit(
      state.copyWith(
        isSubmitting: false,
        authFailureOrSuccessOption: Option.of(result),
      ),
    );
  }

  // 4. Register with email and password
  Future<void> _onRegisterWithEmailAndPasswordPressed(
    RegisterWithEmailAndPasswordPressed event,
    Emitter<SignInFormState> emit,
  ) async {
    await _performEmailPasswordAction(
      emit,
      _authFacade.registerWithEmailAndPassword,
    );
  }

  // 5. Sign in with email and password
  Future<void> _onSignInWithEmailAndPasswordPressed(
    SignInWithEmailAndPasswordPressed event,
    Emitter<SignInFormState> emit,
  ) async {
    await _performEmailPasswordAction(
      emit,
      _authFacade.signInWithEmailAndPassword,
    );
  }

  // Shared authentication logic
  Future<void> _performEmailPasswordAction(
    Emitter<SignInFormState> emit,
    Future<Either<AuthFailure, Unit>> Function({
      required EmailAddress emailAddress,
      required Password password,
    })
    forwardedCall,
  ) async {
    // Prevent duplicate submissions
    if (state.isSubmitting) return;

    final email = state.emailAddress;
    final password = state.password;

    // Domain validation
    final isEmailValid = email.isValid();
    final isPasswordValid = password.isValid();

    if (!isEmailValid || !isPasswordValid) {
      emit(
        state.copyWith(
          isSubmitting: false,
          showErrorMessages: true,
          authFailureOrSuccessOption: Option.none(),
        ),
      );
      return;
    }

    // Start authentication
    emit(
      state.copyWith(
        isSubmitting: true,
        authFailureOrSuccessOption: Option.none(),
      ),
    );

    // Call the supplied facade method
    final result = await forwardedCall(emailAddress: email, password: password);

    if (emit.isDone) return;

    // Avoid associating an old result with new credentials
    if (state.emailAddress != email || state.password != password) {
      emit(
        state.copyWith(
          isSubmitting: false,
          authFailureOrSuccessOption: Option.none(),
        ),
      );
      return;
    }

    // Publish authentication result
    emit(
      state.copyWith(
        isSubmitting: false,
        showErrorMessages: true,
        authFailureOrSuccessOption: Option.of(result),
      ),
    );
  }
}
