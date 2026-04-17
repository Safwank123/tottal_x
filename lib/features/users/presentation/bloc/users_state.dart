import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

enum UsersStatus { initial, loading, success, failure }

class UsersState extends Equatable {
  final UsersStatus status;
  final List<UserEntity> users;
  final bool hasReachedMax;
  final String errorMessage;
  final String searchQuery;
  final String currentSort;

  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const <UserEntity>[],
    this.hasReachedMax = false,
    this.errorMessage = '',
    this.searchQuery = '',
    this.currentSort = 'All',
  });

  UsersState copyWith({
    UsersStatus? status,
    List<UserEntity>? users,
    bool? hasReachedMax,
    String? errorMessage,
    String? searchQuery,
    String? currentSort,
  }) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      currentSort: currentSort ?? this.currentSort,
    );
  }

  @override
  List<Object> get props => [status, users, hasReachedMax, errorMessage, searchQuery, currentSort];
}
