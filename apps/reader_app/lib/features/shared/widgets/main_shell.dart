import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reader_app/ui/design_system/tokens.dart';
import 'package:reader_app/ui/design_system/widgets/glass_card.dart';
import 'package:reader_app/ui/design_system/widgets/glass_navbar.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.state, required this.child});

  final GoRouterState state;
  final Widget child;

  static final _tabs = [
    _NavItem(location: '/', nav: const GlassNavItem(label: 'Home', icon: Icons.house_outlined, selectedIcon: Icons.house_rounded)),
    _NavItem(location: '/search', nav: const GlassNavItem(label: 'Search', icon: Icons.search_outlined, selectedIcon: Icons.search_rounded)),
    _NavItem(location: '/library', nav: const GlassNavItem(label: 'Library', icon: Icons.collections_bookmark_outlined, selectedIcon: Icons.collections_bookmark)),
    _NavItem(location: '/settings', nav: const GlassNavItem(label: 'Settings', icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded)),
  ];

  int _locationToIndex(Uri uri) {
    final location = uri.toString();
    final matchIndex = _tabs.indexWhere((tab) {
      if (tab.location == '/') {
        return location == '/';
      }
      return location == tab.location || location.startsWith('${tab.location}/');
    });
    return matchIndex == -1 ? 0 : matchIndex;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _locationToIndex(state.uri);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1100;

    if (isDesktop) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            center: Alignment.topLeft,
            colors: [
              Color(0xFFEEF2FF),
              Color(0xFFF7ECFF),
              Color(0xFFF9F6FD),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DesktopSidebar(
                  currentIndex: currentIndex,
                  tabs: _tabs,
                  onSelect: (index) {
                    final tab = _tabs[index];
                    if (state.matchedLocation != tab.location) {
                      context.go(tab.location);
                    }
                  },
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0x33FFFFFF),
                            Color(0x11FFFFFF),
                          ],
                        ),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: SafeArea(top: false, bottom: false, child: child),
      bottomNavigationBar: GlassNavBar(
        items: [for (final tab in _tabs) tab.nav],
        currentIndex: currentIndex,
        onItemSelected: (index) {
          final tab = _tabs[index];
          if (state.matchedLocation != tab.location) {
            context.go(tab.location);
          }
        },
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({required this.currentIndex, required this.onSelect, required this.tabs});

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final List<_NavItem> tabs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            borderRadius: BorderRadius.circular(32),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      width: 38,
                      height: 38,
                      child: const Icon(Icons.auto_awesome, color: Colors.white),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Text(
                      'MangaGlass',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.xl),
                for (var i = 0; i < tabs.length; i++) ...[
                  _SidebarButton(
                    label: tabs[i].nav.label,
                    icon: tabs[i].nav.icon,
                    selectedIcon: tabs[i].nav.selectedIcon,
                    selected: currentIndex == i,
                    onTap: () => onSelect(i),
                  ),
                  if (i != tabs.length - 1) const SizedBox(height: SpacingTokens.sm),
                ],
              ],
            ),
          ),
          const Spacer(),
          GlassCard(
            borderRadius: BorderRadius.circular(28),
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Need help?', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  'Access settings or reach out to support anytime.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: SpacingTokens.sm),
                TextButton(
                  onPressed: () => onSelect(tabs.length - 1),
                  child: const Text('Open settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.7);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: RadiusTokens.lg,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: RadiusTokens.lg,
            gradient: selected
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.38),
                      theme.colorScheme.primary.withOpacity(0.16),
                    ],
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(selected ? selectedIcon : icon, color: color),
              const SizedBox(width: SpacingTokens.sm),
              Text(label, style: theme.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.location, required this.nav});

  final String location;
  final GlassNavItem nav;
}
