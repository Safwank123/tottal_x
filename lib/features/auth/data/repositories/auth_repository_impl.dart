import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final String _authKey = '509403AB1jaCVt69e1f08fP1';
  final String _templateId = '69e1f112b200e154f907c722';
  final String _baseUrl = 'https://control.msg91.com/api/v5';

  @override
  Future<Either<Failure, void>> sendOtp(String phoneNumber) async {
    try {
      if (phoneNumber.isEmpty) {
        return const Left(AuthFailure("Phone number cannot be empty"));
      }
      
      // Ensure the phone number includes the country code (91 for India)
      // If the user inputs just 10 digits, we append 91.
      final String mobile = phoneNumber.startsWith('91') ? phoneNumber : '91$phoneNumber';

      final uri = Uri.parse('$_baseUrl/otp?template_id=$_templateId&mobile=$mobile');
      print('--- DEBUG: MSG91 Request ---');
      print('URL: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'authkey': _authKey,
          'Content-Type': 'application/json',
        },
      );

      print('--- DEBUG: MSG91 Response ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      // MSG91 success response usually has type: 'success'
      if (response.statusCode == 200 && responseData['type'] == 'success') {
        print('OTP Successfully Dispatched via MSG91!');
        return const Right(null);
      } else {
        print('MSG91 Error: ${responseData['message']}');
        return Left(AuthFailure(responseData['message'] ?? "Failed to send OTP"));
      }
    } catch (e) {
      print('Exception in sendOtp: $e');
      return const Left(ServerFailure("Cannot connect to server. Check your internet connection."));
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtp(String phoneNumber, String otp) async {
    try {
      if (otp.length != 6) {
        return const Left(AuthFailure("OTP must be 6 digits"));
      }

      final String mobile = phoneNumber.startsWith('91') ? phoneNumber : '91$phoneNumber';

      final uri = Uri.parse('$_baseUrl/otp/verify?otp=$otp&mobile=$mobile');
      
      final response = await http.get(
        uri,
        headers: {
          'authkey': _authKey,
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      // MSG91 success verification has type: 'success'
      if (response.statusCode == 200 && responseData['type'] == 'success') {
        return const Right(null);
      } else {
        return Left(AuthFailure(responseData['message'] ?? "Invalid OTP"));
      }
    } catch (e) {
      return const Left(ServerFailure("Cannot verify OTP. Check your internet connection."));
    }
  }
}
