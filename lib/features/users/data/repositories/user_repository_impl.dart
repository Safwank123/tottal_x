import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  // In-memory list to act as mock database
  final List<UserEntity> _mockDatabase = _generateMockUsers();

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers({
    required int page,
    required int limit,
    String query = '',
    String sortByAge = 'All',
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network latency
      
      List<UserEntity> filtered = List.from(_mockDatabase);

      // Search filter
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        filtered = filtered.where((user) {
          return user.name.toLowerCase().contains(q) || user.phone.contains(q);
        }).toList();
      }

      // Age filter ('Above 60' or 'Older', 'Below 60' or 'Younger')
      if (sortByAge != 'All') {
        if (sortByAge.contains('Elder') || sortByAge.contains('Older') || sortByAge.contains('Above 60')) {
          filtered = filtered.where((user) => user.age >= 60).toList();
        } else if (sortByAge.contains('Younger') || sortByAge.contains('Below 60')) {
          filtered = filtered.where((user) => user.age < 60).toList();
        }
      }

      // Pagination
      final int startIndex = (page - 1) * limit;
      if (startIndex >= filtered.length) {
        return const Right([]);
      }
      
      final int endIndex = (startIndex + limit > filtered.length) 
          ? filtered.length 
          : startIndex + limit;

      return Right(filtered.sublist(startIndex, endIndex));
    } catch (e) {
      return const Left(ServerFailure('Failed to fetch users'));
    }
  }

  @override
  Future<Either<Failure, void>> addUser(UserEntity user) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _mockDatabase.insert(0, user); // Add to top
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to add user'));
    }
  }

  static List<UserEntity> _generateMockUsers() {
    return [
      const UserEntity(id: '1', name: 'Martin Dokidis', phone: '9876543210', age: 34, imageUrl: 'https://i.pravatar.cc/150?u=1'),
      const UserEntity(id: '2', name: 'Marilyn Rosser', phone: '9876543211', age: 65, imageUrl: 'https://i.pravatar.cc/150?u=2'),
      const UserEntity(id: '3', name: 'Cristofer Lipshutz', phone: '9876543212', age: 24, imageUrl: 'https://i.pravatar.cc/150?u=3'),
      const UserEntity(id: '4', name: 'Wilson Botosh', phone: '9876543213', age: 70, imageUrl: 'https://i.pravatar.cc/150?u=4'),
      const UserEntity(id: '5', name: 'Anika Saris', phone: '9876543214', age: 29, imageUrl: 'https://i.pravatar.cc/150?u=5'),
      const UserEntity(id: '6', name: 'Phillip Gouse', phone: '9876543215', age: 61, imageUrl: 'https://i.pravatar.cc/150?u=6'),
      const UserEntity(id: '7', name: 'Wilson Bergson', phone: '9876543216', age: 34, imageUrl: 'https://i.pravatar.cc/150?u=7'),
      const UserEntity(id: '8', name: 'James Halpert', phone: '9876543217', age: 40, imageUrl: 'https://i.pravatar.cc/150?u=8'),
      const UserEntity(id: '9', name: 'Pam Beesly', phone: '9876543218', age: 38, imageUrl: 'https://i.pravatar.cc/150?u=9'),
      const UserEntity(id: '10', name: 'Dwight Schrute', phone: '9876543219', age: 45, imageUrl: 'https://i.pravatar.cc/150?u=10'),
      const UserEntity(id: '11', name: 'Michael Scott', phone: '9876543220', age: 62, imageUrl: 'https://i.pravatar.cc/150?u=11'),
      const UserEntity(id: '12', name: 'Stanley Hudson', phone: '9876543221', age: 64, imageUrl: 'https://i.pravatar.cc/150?u=12'),
      const UserEntity(id: '13', name: 'Ryan Howard', phone: '9876543222', age: 28, imageUrl: 'https://i.pravatar.cc/150?u=13'),
      const UserEntity(id: '14', name: 'Kelly Kapoor', phone: '9876543223', age: 32, imageUrl: 'https://i.pravatar.cc/150?u=14'),
      const UserEntity(id: '15', name: 'Toby Flenderson', phone: '9876543224', age: 50, imageUrl: 'https://i.pravatar.cc/150?u=15'),
    ];
  }
}
