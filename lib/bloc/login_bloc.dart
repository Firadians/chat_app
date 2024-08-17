import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:ContactMe/models/user_model.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
  }

  void _onLoginButtonPressed(
      LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      UserModel user = UserModel.fromFirebaseUser(userCredential.user!);
      emit(LoginSuccess(user: user));
    } catch (e) {
      emit(LoginFailure(error: e.toString()));
    }
  }

  void _onRegisterButtonPressed(
      RegisterButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      UserModel user = UserModel.fromFirebaseUser(userCredential.user!);
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(user.toMap());
      emit(LoginSuccess(user: user));
    } catch (e) {
      emit(LoginFailure(error: e.toString()));
    }
  }
}
