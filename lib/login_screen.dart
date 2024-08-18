import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/gestures.dart';
import 'bloc/login_bloc.dart';
import 'bloc/login_event.dart';
import 'bloc/login_state.dart';
import 'chat_list_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Add the image and the "Login" text
                // Image.asset(
                //   'assets/login_image.png', // Replace with your image asset path
                //   height: 100.0, // Set an appropriate height
                // ),
                SizedBox(height: 16.0),
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Please sign in to continue.',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                    color: const Color.fromARGB(255, 37, 37, 37),
                  ),
                ),
                SizedBox(
                    height:
                        32.0), // Adjust the space between the text and email field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter email or user name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  cursorColor: Colors.purple,
                  style: TextStyle(color: Colors.purple),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  cursorColor: Colors.purple,
                  style: TextStyle(color: Colors.purple),
                  obscureText: true,
                ),
                SizedBox(height: 16.0),
                BlocConsumer<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if (state is LoginSuccess) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatListScreen()),
                      );
                    } else if (state is LoginFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is LoginLoading) {
                      return CircularProgressIndicator();
                    }
                    return Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          primary: Colors.transparent,
                          onPrimary: Colors.white,
                          shadowColor: Colors.transparent,
                          minimumSize: Size(double.infinity, 60),
                        ),
                        onPressed: () {
                          context.read<LoginBloc>().add(LoginButtonPressed(
                                email: _emailController.text,
                                password: _passwordController.text,
                              ));
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple, Colors.pink],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 60,
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {},
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Don\'t have an account? ',
                          style: TextStyle(color: Colors.purple),
                        ),
                        TextSpan(
                          text: 'Register here!',
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold, // Makes this part bold
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/register');
                            },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Image.asset('assets/facebook_icon.png'),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Image.asset('assets/apple_icon.png'),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Image.asset('assets/google_icon.png'),
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: 32.0),
                // Google and Facebook Buttons
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     // Google Button
                //     OutlinedButton.icon(
                //       onPressed: () {},
                //       style: OutlinedButton.styleFrom(
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(30.0),
                //         ),
                //         side: BorderSide(color: Colors.purple),
                //       ),
                //       icon: Image.asset(
                //         'assets/app_logo.png', // Replace with the correct path
                //         height: 24.0,
                //       ),
                //       label:
                //           Text('Google', style: TextStyle(color: Colors.black)),
                //     ),
                //     // Facebook Button
                //     OutlinedButton.icon(
                //       onPressed: () {},
                //       style: OutlinedButton.styleFrom(
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(30.0),
                //         ),
                //         side: BorderSide(color: Colors.purple),
                //       ),
                //       icon: Image.asset(
                //         'assets/app_logo.png', // Replace with the correct path
                //         height: 24.0,
                //       ),
                //       label: Text('Facebook',
                //           style: TextStyle(color: Colors.black)),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
