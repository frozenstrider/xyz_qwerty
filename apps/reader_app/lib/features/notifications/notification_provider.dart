import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationState {
  const NotificationState({required this.entries, required this.isRegistered});

  final List<String> entries;
  final bool isRegistered;

  NotificationState copyWith({List<String>? entries, bool? isRegistered}) {
    return NotificationState(
      entries: entries ?? this.entries,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }

  static NotificationState initial() => const NotificationState(entries: [], isRegistered: false);
}

class NotificationController extends StateNotifier<NotificationState> {
  NotificationController() : super(NotificationState.initial());

  void registerDevice() {
    if (state.isRegistered) return;
    state = state.copyWith(isRegistered: true);
    pushSample('Device registered for release alerts');
  }

  void pushSample(String message) {
    final updated = [...state.entries, message];
    state = state.copyWith(entries: updated.takeLast(10));
  }
}

extension on List<String> {
  List<String> takeLast(int count) {
    if (length <= count) return this;
    return sublist(length - count);
  }
}

final notificationProvider = StateNotifierProvider<NotificationController, NotificationState>((ref) {
  return NotificationController();
});
