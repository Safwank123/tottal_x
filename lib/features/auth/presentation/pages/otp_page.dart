import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_numpad.dart';
import '../../../users/presentation/pages/users_page.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  const OtpPage({super.key, required this.phoneNumber});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _otp = "";
  int _timerSeconds = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onNumber(String num) {
    if (_otp.length < 6) {
      setState(() {
        _otp += num;
      });
    }
  }

  void _onDelete() {
    if (_otp.isNotEmpty) {
      setState(() {
        _otp = _otp.substring(0, _otp.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UsersPage()));
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Placeholder for illustration
                      Center(
                        child: Container(
                          height: 150,
                          width: 150,
                          color: Colors.blue.withOpacity(0.1),
                          child: const Icon(Icons.shopping_cart, size: 80, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "OTP Verification",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          children: [
                            const TextSpan(text: "Enter the verification code we just sent to your number +91 *******"),
                            TextSpan(text: widget.phoneNumber.length >= 2 ? widget.phoneNumber.substring(widget.phoneNumber.length - 2) : "21", style: const TextStyle(color: Colors.black)),
                            const TextSpan(text: "."),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // OTP Inputs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 45,
                            height: 55,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: _otp.length > index ? Colors.black : Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _otp.length > index ? _otp[index] : "",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _otp.length > index ? Colors.red : Colors.black, // From screenshot typed text is red
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          "$_timerSeconds Sec",
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black, fontSize: 14),
                            children: [
                              const TextSpan(text: "Don't Get OTP? "),
                              TextSpan(
                                text: "Resend",
                                style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                // Handle tap with recognizer in real app
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () {
                            if (_otp.length == 6) {
                              context.read<AuthBloc>().add(VerifyOtpEvent(widget.phoneNumber, _otp));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter 6 digits")));
                            }
                          },
                          child: const Text("Verify", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            CustomNumPad(
              onNumberInvoked: _onNumber,
              onDeleteInvoked: _onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
