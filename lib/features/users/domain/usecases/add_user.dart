import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class AddUser implements UseCase<void, UserEntity> {
  final UserRepository repository;

  AddUser(this.repository);

  @override
  Future<Either<Failure, void>> call(UserEntity user) async {
    return await repository.addUser(user);
  }
}
