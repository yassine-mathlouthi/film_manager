import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_theme.dart';

/// Reusable info card with icon and message
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  const InfoCard({
    super.key,
    required this.icon,
    required this.message,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Success info card variant
  factory InfoCard.success({
    required String message,
    IconData icon = PhosphorIconsRegular.checkCircle,
  }) {
    return InfoCard(
      icon: icon,
      message: message,
      backgroundColor: AppTheme.successColor.withOpacity(0.1),
      iconColor: AppTheme.successColor,
    );
  }

  /// Error info card variant
  factory InfoCard.error({
    required String message,
    IconData icon = PhosphorIconsRegular.warningCircle,
  }) {
    return InfoCard(
      icon: icon,
      message: message,
      backgroundColor: AppTheme.errorColor.withOpacity(0.1),
      iconColor: AppTheme.errorColor,
    );
  }

  /// Warning info card variant
  factory InfoCard.warning({
    required String message,
    IconData icon = PhosphorIconsRegular.warning,
  }) {
    return InfoCard(
      icon: icon,
      message: message,
      backgroundColor: Colors.orange.withOpacity(0.1),
      iconColor: Colors.orange,
    );
  }

  /// Info card variant
  factory InfoCard.info({
    required String message,
    IconData icon = PhosphorIconsRegular.info,
  }) {
    return InfoCard(
      icon: icon,
      message: message,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      iconColor: AppTheme.primaryColor,
    );
  }
}
