import 'package:echo_stream/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final _firebaseAuth = FirebaseAuth.instance;
  final _userRepository = UserRepository();

  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isSubmitting = false;
  String _enteredFullName = "", _enteredEmail = "", _enteredPassword = "";

  void _submit() async {
    setState(() {
      setState(() => _isSubmitting = true);
    });

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    try {
      if (_isLogin) {
        final userCredentials = await _firebaseAuth.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        if (userCredentials.user == null) {
          _showSnackbar('Invalid credentials');
          return;
        }
      } else {
        final userCredentials = await _firebaseAuth
            .createUserWithEmailAndPassword(
              email: _enteredEmail,
              password: _enteredPassword,
            );

        await _userRepository.createUser(
          userCredentials.user!.uid,
          fullName: _enteredFullName,
          email: _enteredEmail,
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnackbar(e.message ?? 'Something went wrong');
      // print('auth error -> ${e.code}');
      setState(() {
        setState(() => _isSubmitting = false);
      });
    }
  }

  void _signInWithGoogle() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredentials = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredentials.user!;
      final userExistsSnapshot = await _userRepository.getUserDocByID(user.uid);

      if (userExistsSnapshot.data() == null) {
        await _userRepository.createUser(
          user.uid,
          fullName: user.displayName!,
          email: user.email!,
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnackbar(e.message ?? 'Something went wrong');
      // print('error code -> ${e.code}');
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackbar(final String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.electric_bolt_sharp,
                size: 100.0,
                color: theme.colorScheme.onPrimary,
              ),
              Text(
                'EchoStream',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              Card(
                margin: const EdgeInsets.all(20.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 12.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_isLogin)
                          TextFormField(
                            key: Key('fullNameField'),
                            decoration: const InputDecoration(
                              label: Text("Full name"),
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter your full name";
                              }
                              return null;
                            },
                            onSaved: (value) => _enteredFullName = value!,
                          ),
                        const SizedBox(height: 6.0),
                        TextFormField(
                          key: Key('emailField'),
                          decoration: const InputDecoration(
                            label: Text("Email"),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter valid email address";
                            }
                            return null;
                          },
                          onSaved: (value) => _enteredEmail = value!,
                        ),
                        const SizedBox(height: 6.0),
                        TextFormField(
                          key: Key('passwordField'),
                          decoration: InputDecoration(label: Text('Password')),
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return "Password must have minimum length of 6 characters";
                            }

                            return null;
                          },
                          obscureText: true,
                          onSaved: (value) => _enteredPassword = value!,
                        ),
                        const SizedBox(height: 10.0),
                        FilledButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: Text(_isLogin ? 'Login' : 'Signup'),
                        ),
                        const SizedBox(height: 6.0),
                        TextButton(
                          onPressed:
                              _isSubmitting
                                  ? null
                                  : () {
                                    setState(() => _isLogin = !_isLogin);
                                  },
                          child: Text(
                            _isLogin
                                ? 'Create new account'
                                : 'Already have an account',
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        const Text('or'),
                        const SizedBox(height: 20.0),
                        OutlinedButton.icon(
                          icon: Image.asset(
                            'images/google-logo.png',
                            height: 24.0,
                          ),
                          onPressed: _isSubmitting ? null : _signInWithGoogle,
                          label: Text('Continue with google'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
