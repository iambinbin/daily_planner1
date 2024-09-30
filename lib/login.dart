import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:calendar/data/databaseHelper.dart';
import 'package:calendar/home_Screens.dart';
import 'package:calendar/register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  String _errorMessage = '';
  bool _isLoading = false;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email and password cannot be empty';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic>? user = await _dbHelper.getUserByEmail(email);

      if (user != null && user['password'] == _hashPassword(password)) {
        setState(() {
          _errorMessage = '';
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(title: 'Calendar App')),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             Text(
              'Login',
              style: TextStyle(
                color: Colors.blue, // Title color
                fontSize: 32, // Title font size
                fontWeight: FontWeight.bold, // Title font weight
              ),
            ),
            Center(
              child: Image.asset(
                'assets/images/logo.png', // Path to your logo image
                height: 50, // Adjust height as needed
                width: 50,  // Adjust width as needed
              ),),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : FilledButton(
                    onPressed: _login,
                    child: Text('Login',),
                  ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text('Don\'t have an account? Sign up'),
            ),
            SizedBox(height: 20),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}            