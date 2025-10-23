import 'package:flutter/material.dart';
import 'package:reader_app/domain/models/library_models.dart';
import 'package:reader_app/ui/design_system/tokens.dart';

class ChapterTile extends StatelessWidget {
  const ChapterTile({super.key, required this.chapter, this.isOwned = false, this.onTap, this.trailing});

  final MangaChapter chapter;
  final bool isOwned;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return InkWell(
      borderRadius: RadiusTokens.md,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm, horizontal: SpacingTokens.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
              ),
              alignment: Alignment.center,
              child: Text('', style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Released · ',
                    style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null)
              Icon(
                isOwned ? Icons.check_circle_rounded : Icons.lock_outline,
                color: isOwned ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '--';
  }
}
