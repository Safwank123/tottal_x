import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers({
    required int page,
    required int limit,
    String query = '',
    String sortByAge = 'All', // 'All', 'Above 60', 'Below 60'
  });

  Future<Either<Failure, void>> addUser(UserEntity user);
}
