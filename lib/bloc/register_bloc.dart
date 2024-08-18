import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial());

  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is RegisterButtonPressed) {
      yield* _mapRegisterButtonPressedToState(event);
    }
  }

  Stream<RegisterState> _mapRegisterButtonPressedToState(
      RegisterButtonPressed event) async* {
    yield RegisterLoading();

    try {
      // Validate that the passwords match
      if (event.password != event.reEnterPassword) {
        yield RegisterFailure(error: 'Passwords do not match');
        return;
      }

      // Simulate a call to a user registration service
      await Future.delayed(Duration(seconds: 2)); // Simulate a network call

      // If the registration is successful, yield RegisterSuccess
      yield RegisterSuccess();

      // Handle any errors during the registration process
    } catch (error) {
      yield RegisterFailure(error: error.toString());
    }
  }
}
