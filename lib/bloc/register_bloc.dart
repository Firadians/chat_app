import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
  }

  Future<void> _onRegisterButtonPressed(
      RegisterButtonPressed event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());

    try {
      // Validate that the passwords match
      if (event.password != event.reEnterPassword) {
        emit(RegisterFailure(error: 'Passwords do not match'));
        return;
      }

      // Create a new user with Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Add additional user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': event.username,
        'email': event.email,
        // Add any other necessary fields here
      });

      // If the registration is successful, emit RegisterSuccess
      emit(RegisterSuccess());
    } on FirebaseAuthException catch (e) {
      emit(RegisterFailure(error: _mapFirebaseAuthError(e)));
    } catch (e) {
      emit(RegisterFailure(error: 'An unexpected error occurred.'));
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email provided is invalid.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
