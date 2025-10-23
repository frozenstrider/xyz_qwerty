import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reader_app/features/library/providers/library_providers.dart';
import 'package:reader_app/ui/design_system/tokens.dart';
import 'package:reader_app/ui/design_system/widgets/glass_card.dart';

class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchases = ref.watch(purchasesProvider).history;
    final library = ref.watch(libraryStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Purchases')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.lg,
            SpacingTokens.lg, SpacingTokens.xl),
        children: [
          if (purchases.isEmpty)
            Column(
              children: [
                Icon(Icons.receipt_long_rounded,
                    size: 48, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: SpacingTokens.md),
                Text('No purchases yet',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                    'Unlock premium chapters or volumes to see them listed here.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            )
          else
            ...purchases.reversed.map((record) {
              final chapter = ref
                  .read(libraryRepositoryProvider)
                  .allSeries
                  .expand((series) => series.chapters)
                  .firstWhere((chapter) => chapter.id == record.itemId);
              final series = library.ownedSeries.firstWhere(
                  (s) => s.id == chapter.seriesId,
                  orElse: () => ref
                      .read(libraryRepositoryProvider)
                      .allSeries
                      .firstWhere((s) => s.id == chapter.seriesId));
              return Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                child: GlassCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.15),
                        child: Icon(Icons.bookmark_added_rounded,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: SpacingTokens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(chapter.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(series.title,
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${record.price.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text(DateFormat.yMMMd().format(record.purchasedAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: SpacingTokens.xl),
          ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Restore purchases will connect to store in production.')),
            ),
            icon: const Icon(Icons.sync_rounded),
            label: const Text('Restore purchases'),
          ),
        ],
      ),
    );
  }
}
