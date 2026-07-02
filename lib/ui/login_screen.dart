import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String tokenText = "";
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Login...')),
      );

      final String username = _usernameController.text;
      final String password = _passwordController.text;

      // Note: If you are using an Android Emulator, change "localhost" to "10.0.2.2"
      final String baseUrl = "http://localhost:30033";
      final url = Uri.parse('$baseUrl/api/oauth/token');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phoneNumber': username,
            'password': password,
          }),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final String token = data['accessToken'] ?? '';
          setState(() {
            tokenText = token;

          });
          print('Login success! Token: $token');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Success! Token received.')),
          );
          
          // TODO: Save the token (e.g., using shared_preferences) and navigate to the home screen
        } else {
          String errorMsg = 'Login failed';
          try {
            final data = jsonDecode(response.body);
            if (data['message'] != null) {
              errorMsg = data['message'];
            }
          } catch (_) {}
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $errorMsg')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              Text(tokenText),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onLoginPressed,
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
