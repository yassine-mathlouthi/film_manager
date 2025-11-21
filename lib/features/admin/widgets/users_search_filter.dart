import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';

class UsersSearchFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const UsersSearchFilter({
    super.key,
    required this.searchController,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.backgroundColor,
      child: Column(
        children: [
          // Search field
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search users by name or email...',
              prefixIcon: Icon(
                PhosphorIcons.magnifyingGlass(),
                color: AppTheme.textSecondary,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(PhosphorIcons.x()),
                      onPressed: () {
                        searchController.clear();
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // Role filter
          Row(
            children: [
              Text(
                'Filter by role:',
                style: AppTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  value: selectedRole,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('All Roles'),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Admin'),
                    ),
                    DropdownMenuItem(
                      value: 'user',
                      child: Text('User'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onRoleChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
