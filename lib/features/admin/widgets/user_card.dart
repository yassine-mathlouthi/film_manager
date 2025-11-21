import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onToggleStatus;

  const UserCard({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildAvatar(),
        title: Text(user.fullName, style: AppTheme.subtitleStyle),
        subtitle: _buildSubtitle(),
        trailing: _buildMenu(context),
      ),
    );
  }

  Widget _buildAvatar() {
    if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(user.profileImageUrl!),
        backgroundColor: user.isAdmin
            ? AppTheme.accentColor
            : AppTheme.secondaryColor,
      );
    }

    return CircleAvatar(
      backgroundColor: user.isAdmin
          ? AppTheme.accentColor
          : AppTheme.secondaryColor,
      child: Text(
        user.firstName[0].toUpperCase(),
        style: AppTheme.subtitleStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          user.email,
          style: AppTheme.bodyStyle.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: user.isAdmin
                    ? AppTheme.accentColor.withOpacity(0.1)
                    : AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: AppTheme.captionStyle.copyWith(
                  color: user.isAdmin
                      ? AppTheme.accentColor
                      : AppTheme.secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Joined ${_formatDate(user.createdAt)}',
              style: AppTheme.captionStyle.copyWith(fontSize: 11),
            ),
            if (!user.isActive) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Text(
                  'INACTIVE',
                  style: AppTheme.captionStyle.copyWith(
                    fontSize: 9,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        PhosphorIcons.dotsThreeVertical(),
        color: AppTheme.textSecondary,
      ),
      onSelected: (value) {
        switch (value) {
          case 'toggle_status':
            if (onToggleStatus != null) onToggleStatus!();
            break;
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        if (onToggleStatus != null)
          PopupMenuItem(
            value: 'toggle_status',
            child: Row(
              children: [
                Icon(
                  user.isActive
                      ? PhosphorIcons.prohibit()
                      : PhosphorIcons.checkCircle(),
                  color: user.isActive ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  user.isActive ? 'Deactivate' : 'Activate',
                  style: TextStyle(
                    color: user.isActive ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(PhosphorIcons.pencil()),
              const SizedBox(width: 8),
              const Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(PhosphorIcons.trash(), color: AppTheme.errorColor),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else {
      return 'Today';
    }
  }
}
