import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterButtonPressed extends RegisterEvent {
  final String email;
  final String username;
  final String password;
  final String reEnterPassword;

  RegisterButtonPressed({
    required this.email,
    required this.username,
    required this.password,
    required this.reEnterPassword,
  });

  @override
  List<Object> get props => [email, username, password, reEnterPassword];
}
