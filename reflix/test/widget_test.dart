import 'package:app_filmes/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Abre na tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const AppFilmes());

    expect(find.text('REFLIX'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
