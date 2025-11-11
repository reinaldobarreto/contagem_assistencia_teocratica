import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:contagem_assistencia_teocratica/main.dart';

void main() {
  test('CSV header is correct', () {
    expect(
      buildCsvHeader(),
      'DataHora,Reuniao,Indicadores,Ocupados,EmPe,Total,PorFileiraOcupados,PorFileiraCapacidade,Notas',
    );
  });

  test('CSV row format with values', () {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final row = buildCsvRowFromValues(
      dateTime: DateTime(2024, 10, 5, 9, 30),
      occupied: 120,
      standing: 5,
      indicators: const ['João', 'Maria'],
      meetingType: 'Reunião de Fim de Semana',
      notes: 'Tudo OK',
      perBlockOccupied: const [30, 40, 50],
      perBlockCapacity: const [40, 50, 60],
      dateFormat: df,
    );
    expect(
      row,
      '${df.format(DateTime(2024, 10, 5, 9, 30))},"Reunião de Fim de Semana","João; Maria",120,5,125,"30; 40; 50","40; 50; 60","Tudo OK"',
    );
  });
}
