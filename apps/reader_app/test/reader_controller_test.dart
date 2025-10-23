import 'package:flutter_test/flutter_test.dart';
import 'package:reader_app/domain/models/reader_models.dart';
import 'package:reader_app/features/reader/providers/reader_providers.dart';

void main() {
  test('reader controller clamps page indices', () {
    final controller = ReaderController(initialMode: ReaderMode.single);
    controller.setPage(5, 10);
    expect(controller.state.pageIndex, 5);

    controller.setMode(ReaderMode.double, 10);
    expect(controller.state.mode, ReaderMode.double);
    expect(controller.state.pageIndex, 4);

    controller.setPage(9, 10);
    expect(controller.state.pageIndex, 8);

    controller.setPage(-3, 10);
    expect(controller.state.pageIndex, 0);

    controller.setMode(ReaderMode.vertical, 10);
    controller.toggleUi();
    expect(controller.state.showUi, isFalse);
  });
}
