import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import '../../data/services/auth_service.dart';
import '../../../users/presentation/pages/users_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'otp_page.dart';
import '../widgets/custom_numpad.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  String _phone = "";
  bool _isGoogleLoading = false;

  void _onNumber(String num) {
    if (_phone.length < 10) {
      setState(() {
        _phone += num;
      });
    }
  }

  void _onDelete() {
    if (_phone.isNotEmpty) {
      setState(() {
        _phone = _phone.substring(0, _phone.length - 1);
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UsersPage()),
        );
      } else {
        throw Exception('Google sign-in failed. Please try again.');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in Error: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 0, // hide appbar but keep safe area behavior if needed
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpSentState) {
            toastification.show(
              context: context,
              title: const Text('OTP Sent Successfully!'),
              autoCloseDuration: const Duration(seconds: 3),
              type: ToastificationType.success,
              style: ToastificationStyle.flatColored,
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OtpPage(phoneNumber: state.phoneNumber)),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          // Illustration
                          Center(
                            child: Image.asset(
                              'assets/illustration.png', 
                              height: 150,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  width: 150,
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  child: const Icon(Icons.image, size: 80, color: Colors.blue),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            "Enter Phone Number",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 55,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _phone.isEmpty
                                ? RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                      children: [
                                        const TextSpan(text: "Enter Phone Number"),
                                        TextSpan(
                                          text: " *",
                                          style: const TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  )
                                : Text(
                                    _phone,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                              children: [
                                const TextSpan(text: "By Continuing, I agree to TotalX's "),
                                TextSpan(
                                  text: "Terms and condition",
                                  style: const TextStyle(color: Colors.lightBlue),
                                  recognizer: TapGestureRecognizer()..onTap = () {},
                                ),
                                const TextSpan(text: " & "),
                                TextSpan(
                                  text: "privacy policy",
                                  style: const TextStyle(color: Colors.lightBlue),
                                  recognizer: TapGestureRecognizer()..onTap = () {},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 0,
                              ),
                              onPressed: state is AuthLoading 
                                ? null 
                                : () {
                                    if (_phone.length == 10) {
                                      context.read<AuthBloc>().add(SendOtpEvent(_phone));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a valid 10-digit number")));
                                    }
                                },
                              child: state is AuthLoading 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Get OTP", style: TextStyle(fontSize: 16, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                backgroundColor: Colors.white,
                              ),
                              onPressed: state is AuthLoading || _isGoogleLoading
                                  ? null
                                  : _signInWithGoogle,
                              child: _isGoogleLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.login, color: Colors.black),
                                        SizedBox(width: 10),
                                        Text(
                                          "Continue with Google",
                                          style: TextStyle(fontSize: 16, color: Colors.black),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                // Custom Numpad
                CustomNumPad(
                  onNumberInvoked: _onNumber,
                  onDeleteInvoked: _onDelete,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


