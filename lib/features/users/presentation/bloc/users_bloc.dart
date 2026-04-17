import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_user.dart';
import '../../domain/usecases/get_users.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsers getUsersUseCase;
  final AddUser addUserUseCase;
  
  static const int _limit = 10;
  int _currentPage = 1;

  UsersBloc({required this.getUsersUseCase, required this.addUserUseCase}) : super(const UsersState()) {
    on<FetchUsersEvent>(_onFetchUsers);
    on<SearchUsersEvent>(_onSearchUsers);
    on<SortUsersEvent>(_onSortUsers);
    on<AddNewUserEvent>(_onAddNewUser);
  }

  Future<void> _onFetchUsers(FetchUsersEvent event, Emitter<UsersState> emit) async {
    if (state.hasReachedMax && state.status == UsersStatus.success) return;

    if (state.status == UsersStatus.initial) {
      emit(state.copyWith(status: UsersStatus.loading));
    }

    final result = await getUsersUseCase(GetUsersParams(
      page: _currentPage,
      limit: _limit,
      query: state.searchQuery,
      sortByAge: state.currentSort,
    ));

    result.fold(
      (failure) => emit(state.copyWith(status: UsersStatus.failure, errorMessage: failure.message)),
      (users) {
        if (users.isEmpty) {
          emit(state.copyWith(hasReachedMax: true, status: UsersStatus.success));
        } else {
          _currentPage++;
          emit(state.copyWith(
            status: UsersStatus.success,
            users: List.of(state.users)..addAll(users),
            hasReachedMax: false,
          ));
        }
      },
    );
  }

  Future<void> _onSearchUsers(SearchUsersEvent event, Emitter<UsersState> emit) async {
    // Reset pagination logic
    _currentPage = 1;
    emit(state.copyWith(searchQuery: event.query, users: [], hasReachedMax: false, status: UsersStatus.loading));
    add(FetchUsersEvent());
  }

  Future<void> _onSortUsers(SortUsersEvent event, Emitter<UsersState> emit) async {
    _currentPage = 1;
    emit(state.copyWith(currentSort: event.sortOption, users: [], hasReachedMax: false, status: UsersStatus.loading));
    add(FetchUsersEvent());
  }

  Future<void> _onAddNewUser(AddNewUserEvent event, Emitter<UsersState> emit) async {
    // Optimistic or waiting? Let's just wait to respond safely to DB then refresh
    final result = await addUserUseCase(event.user);
    // After adding, we just re-fetch from page 1 to see new user at top of list
    result.fold(
      (f) => emit(state.copyWith(status: UsersStatus.failure, errorMessage: "Failed to add user")),
      (_) {
        _currentPage = 1;
        emit(state.copyWith(users: [], hasReachedMax: false, status: UsersStatus.loading));
        add(FetchUsersEvent());
      }
    );
  }
}
