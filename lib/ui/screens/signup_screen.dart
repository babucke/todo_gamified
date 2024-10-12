import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/authentication/authentication_bloc.dart';
import '../../blocs/authentication/authentication_event.dart';
import '../../blocs/authentication/authentication_state.dart';
import '../../utils/enums.dart';
import '../../utils/validators.dart';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';
  UserRole _role = UserRole.parent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrieren'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationAuthenticated) {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (state is AuthenticationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onSaved: (value) => _name = value!.trim(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte Namen eingeben';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _email = value!.trim(),
                  validator: Validators.validateEmail,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Passwort'),
                  obscureText: true,
                  onSaved: (value) => _password = value!.trim(),
                  validator: Validators.validatePassword,
                ),
                SizedBox(height: 10),
                Text(
                  'Passwort muss mindestens 8 Zeichen lang sein, '
                      'einen Großbuchstaben, einen Kleinbuchstaben, '
                      'eine Zahl und ein Sonderzeichen enthalten.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                DropdownButtonFormField<UserRole>(
                  decoration: InputDecoration(labelText: 'Rolle'),
                  value: _role,
                  onChanged: (UserRole? newValue) {
                    setState(() {
                      _role = newValue!;
                    });
                  },
                  items: UserRole.values.map((UserRole role) {
                    return DropdownMenuItem<UserRole>(
                      value: role,
                      child: Text(role == UserRole.parent ? 'Elternteil' : 'Kind'),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('Registrieren'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<AuthenticationBloc>().add(
        SignUpRequested(
          email: _email,
          password: _password,
          name: _name,
          role: _role,
        ),
      );
    }
  }
}
