import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../bloc/users_bloc.dart';
import '../bloc/users_event.dart';
import '../bloc/users_state.dart';
import '../widgets/sort_bottom_sheet.dart';
import '../widgets/add_user_bottom_sheet.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<UsersBloc>().add(FetchUsersEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<UsersBloc>().add(FetchUsersEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (_) {
        return SortBottomSheet(
          currentSort: context.read<UsersBloc>().state.currentSort,
          onApplySort: (sortOption) {
            context.read<UsersBloc>().add(SortUsersEvent(sortOption));
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showAddUserBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (_) {
        return AddUserBottomSheet(
          onAddUser: (user) {
            // Just dispatch the event - don't pop here!
            // The bottom sheet handles its own closing
            context.read<UsersBloc>().add(AddNewUserEvent(user));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 70,
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text("Nilambur", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            // Search and Sort
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => context.read<UsersBloc>().add(SearchUsersEvent(val)),
                        decoration: InputDecoration(
                          hintText: "search by name",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: const Icon(Icons.search, color: Colors.black54),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showSortBottomSheet,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.filter_list, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Users Lists", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
            ),
            const SizedBox(height: 10),
            // List View
            Expanded(
              child: BlocBuilder<UsersBloc, UsersState>(
                builder: (context, state) {
                  if (state.status == UsersStatus.initial && state.users.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Colors.black));
                  }
                  if (state.status == UsersStatus.failure) {
                    return Center(child: Text(state.errorMessage));
                  }
                  if (state.users.isEmpty && state.status == UsersStatus.success) {
                    return const Center(child: Text("No users found."));
                  }
                  
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.hasReachedMax ? state.users.length : state.users.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= state.users.length) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(color: Colors.black),
                        ));
                      }
                      final user = state.users[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade300,
                              ),
                              child: user.imageUrl.isEmpty
                                  ? const Icon(Icons.person, size: 30)
                                  : ClipOval(
                                      child: user.imageUrl.startsWith('http')
                                          ? Image.network(
                                              user.imageUrl,
                                              fit: BoxFit.cover,
                                              cacheWidth: 120,
                                              cacheHeight: 120,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.person, size: 30),
                                            )
                                          : FutureBuilder<File>(
                                              future: Future.delayed(
                                                Duration.zero,
                                                () => File(user.imageUrl),
                                              ),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return const Icon(Icons.person, size: 30);
                                                }
                                                return Image.file(
                                                  snapshot.data!,
                                                  fit: BoxFit.cover,
                                                  cacheWidth: 120,
                                                  cacheHeight: 120,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      const Icon(Icons.person, size: 30),
                                                );
                                              },
                                            ),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text("Age: ${user.age}", style: const TextStyle(color: Colors.black54)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserBottomSheet,
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
