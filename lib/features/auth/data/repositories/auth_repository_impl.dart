import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, void>> sendOtp(String phoneNumber) async {
    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));
      if (phoneNumber.isEmpty) {
        return const Left(AuthFailure("Phone number cannot be empty"));
      }
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure("Failed to send OTP"));
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtp(String phoneNumber, String otp) async {
    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));
      if (otp.length != 6) {
        return const Left(AuthFailure("OTP must be 6 digits"));
      }
      // For demo purposes, accept any 6 digits
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure("Failed to verify OTP"));
    }
  }
}
