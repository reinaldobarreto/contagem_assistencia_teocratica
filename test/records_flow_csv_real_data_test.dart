import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:contagem_assistencia_teocratica/main.dart';

void main() {
  testWidgets('Fluxo real: salvar do Contagem e exportar CSV', (
    WidgetTester tester,
  ) async {
    // Executa o app real
    await tester.pumpWidget(const ContagemApp());
    await tester.pumpAndSettle();

    // Garante que há pelo menos um indicador via estado real da HomeShell
    final homeState = tester.state(find.byType(HomeShell)) as dynamic;
    homeState.setState(() {
      homeState.indicators.addAll(['João', 'Maria']);
    });

    // Seleciona tipo de reunião
    final dropdownFinder = find.byType(DropdownButtonFormField<String>);
    expect(dropdownFinder, findsOneWidget);
    await tester.ensureVisible(dropdownFinder);
    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text(kMeetingTypes.first).last);
    await tester.pumpAndSettle();

    // (Opcional) indicadores não são adicionados neste teste para evitar sobreposições

    // Ocupa algumas poltronas
    final seats = find.byIcon(Icons.event_seat);
    expect(seats, findsWidgets);
    final seat0 = seats.at(0);
    final seat1 = seats.at(1);
    final seat2 = seats.at(2);
    await tester.ensureVisible(seat0);
    await tester.tap(seat0);
    await tester.ensureVisible(seat1);
    await tester.tap(seat1);
    await tester.ensureVisible(seat2);
    await tester.tap(seat2);
    await tester.pump();

    // Incrementa em pé
    final incStanding = find.byIcon(Icons.add_circle_outline);
    await tester.ensureVisible(incStanding);
    await tester.tap(incStanding);
    await tester.pump();

    // Salva registro
    final salvar = find.text('Salvar');
    await tester.ensureVisible(salvar);
    await tester.tap(salvar);
    await tester.pumpAndSettle();

    // Obtém registros diretamente do estado do HomeShell
    final state = tester.state(find.byType(HomeShell)) as dynamic;
    final List<dynamic> records = state.records as List<dynamic>;
    expect(records.isNotEmpty, isTrue);

    // Monta CSV real a partir dos registros salvos
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final csv = buildCsvAllFromInternalRecords(records, df);

    // Valida cabeçalho e que contém total e reunião
    expect(csv.split('\n').first, buildCsvHeader());
    expect(csv.contains('Reunião'), isTrue);
    // Deve conter total calculado (3 ocupados + 1 em pé = 4 total)
    expect(csv.contains(',3,1,4,'), isTrue);
    // Campo de indicadores pode estar vazio neste fluxo
  });
}
