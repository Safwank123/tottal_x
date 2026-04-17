import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUsers implements UseCase<List<UserEntity>, GetUsersParams> {
  final UserRepository repository;

  GetUsers(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(GetUsersParams params) async {
    return await repository.getUsers(
      page: params.page,
      limit: params.limit,
      query: params.query,
      sortByAge: params.sortByAge,
    );
  }
}

class GetUsersParams extends Equatable {
  final int page;
  final int limit;
  final String query;
  final String sortByAge;

  const GetUsersParams({
    required this.page,
    required this.limit,
    this.query = '',
    this.sortByAge = 'All',
  });

  @override
  List<Object?> get props => [page, limit, query, sortByAge];
}
