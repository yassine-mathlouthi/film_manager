import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/users_provider.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../widgets/users_search_filter.dart';
import '../widgets/user_card.dart';
import '../widgets/empty_users_view.dart';
import '../widgets/error_view.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'all';
  List<User> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsersProvider>(context, listen: false).fetchUsers();
    });
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    List<User> users = usersProvider.users;

    // Filter by role
    if (_selectedRole != 'all') {
      users = users.where((user) => user.role == _selectedRole).toList();
    }

    // Filter by search query
    final query = _searchController.text;
    if (query.isNotEmpty) {
      users = users.where((user) {
        final fullName = user.fullName.toLowerCase();
        final email = user.email.toLowerCase();
        final searchQuery = query.toLowerCase();

        return fullName.contains(searchQuery) || email.contains(searchQuery);
      }).toList();
    }

    setState(() {
      _filteredUsers = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.userPlus()),
            onPressed: () => _showAddUserDialog(),
          ),
        ],
      ),
      body: Consumer<UsersProvider>(
        builder: (context, usersProvider, child) {
          if (usersProvider.isLoading && usersProvider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (usersProvider.error != null) {
            return ErrorView(
              errorMessage: usersProvider.error,
              onRetry: () => usersProvider.fetchUsers(),
            );
          }

          // Initialize filtered users if needed
          if (_filteredUsers.isEmpty && usersProvider.users.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _filterUsers();
            });
          }

          // Update filtered users when filter changes
          final displayUsers = _filteredUsers.isEmpty && _searchController.text.isEmpty && _selectedRole == 'all'
              ? usersProvider.users
              : _filteredUsers;

          return Column(
            children: [
              // Search and filter section
              UsersSearchFilter(
                searchController: _searchController,
                selectedRole: _selectedRole,
                onRoleChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                  _filterUsers();
                },
              ),

              // Users count
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: AppTheme.textLight.withOpacity(0.1),
                child: Text(
                  'Total: ${displayUsers.length} users',
                  style: AppTheme.captionStyle,
                ),
              ),

              // Users list
              Expanded(
                child: displayUsers.isEmpty
                    ? const EmptyUsersView()
                    : RefreshIndicator(
                        onRefresh: () => usersProvider.fetchUsers(),
                        child: ListView.builder(
                          itemCount: displayUsers.length,
                          itemBuilder: (context, index) {
                            final user = displayUsers[index];
                            return UserCard(
                              user: user,
                              onEdit: () => _showEditUserDialog(user),
                              onDelete: () => _showDeleteUserDialog(
                                user,
                                usersProvider,
                              ),
                              onToggleStatus: () => _toggleUserStatus(
                                user,
                                usersProvider,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: const Text(
          'This feature will be implemented in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: const Text(
          'This feature will be implemented in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(User user, UsersProvider usersProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final success = await usersProvider.deleteUser(user.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user.fullName} has been deleted'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
                _filterUsers(); // Refresh the filtered list
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      usersProvider.error ?? 'Failed to delete user',
                    ),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(User user, UsersProvider usersProvider) async {
    final action = user.isActive ? 'deactivate' : 'activate';

    final confirm = await ConfirmationDialog.show(
      context: context,
      title: '${action == 'activate' ? 'Activate' : 'Deactivate'} User',
      message: 'Are you sure you want to $action ${user.fullName}?',
      confirmText: action == 'activate' ? 'Activate' : 'Deactivate',
      confirmColor: action == 'activate' ? Colors.green : Colors.orange,
      icon: user.isActive ? PhosphorIcons.prohibit() : PhosphorIcons.checkCircle(),
    );

    if (confirm == true && mounted) {
      final success = await usersProvider.toggleUserStatus(
        user.id,
        !user.isActive,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${user.fullName} has been ${action}d',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _filterUsers(); // Refresh the filtered list
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              usersProvider.error ?? 'Failed to $action user',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
