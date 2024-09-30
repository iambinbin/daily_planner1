import 'package:calendar/data/databaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart'; // Thư viện để mã hóa mật khẩu
import 'dart:convert'; // Thư viện để mã hóa thành chuỗi

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  String _errorMessage = '';
  bool _isLoading = false;

  // Mã hóa mật khẩu
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Kiểm tra tính hợp lệ của email
  bool _isValidEmail(String email) {
    String pattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  // Kiểm tra độ mạnh của mật khẩu
  bool _isPasswordStrong(String password) {
    return password.length >= 8 && password.contains(RegExp(r'[0-9]')) && password.contains(RegExp(r'[A-Za-z]'));
  }

  // Hàm đăng ký người dùng mới
  Future<void> _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Kiểm tra thông tin nhập
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập đầy đủ thông tin';
      });
      return;
    }

    // Kiểm tra email hợp lệ
    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Email không hợp lệ';
      });
      return;
    }

    // Kiểm tra độ mạnh của mật khẩu
    if (!_isPasswordStrong(password)) {
      setState(() {
        _errorMessage = 'Mật khẩu phải có ít nhất 8 ký tự và bao gồm cả chữ cái và số';
      });
      return;
    }

    // Kiểm tra mật khẩu khớp nhau
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Mật khẩu không khớp';
      });
      return;
    }

    setState(() {
      _isLoading = true; // Hiển thị biểu tượng tải
    });

    try {
      // Kiểm tra nếu email đã tồn tại
      Map<String, dynamic>? existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        setState(() {
          _errorMessage = 'Email đã được sử dụng';
        });
        return;
      }

      // Mã hóa mật khẩu trước khi lưu
      String hashedPassword = _hashPassword(password);

      // Lưu người dùng vào database
      await _dbHelper.insertUser(email, hashedPassword);

      setState(() {
        _errorMessage = 'Đăng ký thành công!';
      });

      // Điều hướng về trang đăng nhập hoặc trang chủ
      Navigator.pop(context); // Quay lại trang đăng nhập
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // Tắt biểu tượng tải
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
            // Title at the top
            Text(
              'Đăng Ký',
              style: TextStyle(
                color: Colors.blue, // Title color
                fontSize: 32, // Title font size
                fontWeight: FontWeight.bold, // Title font weight
              ),
            ),
            SizedBox(height: 20), // Space between title and logo
            Center(
              child: Image.asset(
                'assets/images/logo.png', // Path to your logo image
                height: 50, // Adjust height as needed
                width: 50,  // Adjust width as needed
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true, // Ẩn mật khẩu
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Xác nhận mật khẩu'),
              obscureText: true, // Ẩn mật khẩu
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // Hiển thị khi đang xử lý đăng ký
                : FilledButton(
                    onPressed: _register,
                    child: Text('Đăng Ký'),
                  ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Quay lại trang đăng nhập
              },
              child: Text('Đã có tài khoản? Đăng nhập'),
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
