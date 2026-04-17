import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class UsersEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchUsersEvent extends UsersEvent {}

class SearchUsersEvent extends UsersEvent {
  final String query;
  SearchUsersEvent(this.query);
  @override
  List<Object> get props => [query];
}

class SortUsersEvent extends UsersEvent {
  final String sortOption;
  SortUsersEvent(this.sortOption);
  @override
  List<Object> get props => [sortOption];
}

class AddNewUserEvent extends UsersEvent {
  final UserEntity user;
  AddNewUserEvent(this.user);
  @override
  List<Object> get props => [user];
}
