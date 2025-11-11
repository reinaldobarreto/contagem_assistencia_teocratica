import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:async' as dart_async;
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:quick_actions/quick_actions.dart';

// Alerta para agrupamentos muito grandes (continua permitindo, apenas avisa)
const int kRowGroupingAlertThreshold = 1000;

// Tipos de reunião disponíveis
const List<String> kMeetingTypes = [
  'Reunião de Vida e Ministério',
  'Reunião de Fim de Semana',
  'Assembleia de Circuito',
  'Congressos Regionais',
];

void main() {
  runApp(const ContagemApp());
}

class ContagemApp extends StatefulWidget {
  const ContagemApp({super.key});

  @override
  State<ContagemApp> createState() => _ContagemAppState();
}

class _ContagemAppState extends State<ContagemApp> {
  ThemeMode _mode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contagem de Assistência',
      themeMode: _mode,
      theme: _buildPurpleLightTheme(),
      darkTheme: _buildPurpleDarkTheme(),
      debugShowCheckedModeBanner: false,
      home: HomeShell(
        onToggleTheme: () {
          setState(() {
            _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
          });
        },
      ),
    );
  }
}

ThemeData _buildPurpleLightTheme() {
  // Light theme inspirado na imagem: app bar e FAB roxos
  const seed = Color(0xFF9C27B0); // Purple 500
  final base = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );
  // Ajustes de contraste e containers suaves (inspirados na imagem)
  final scheme = base.copyWith(
    primary: const Color(
      0xFF6F3CC5,
    ), // um pouco mais claro, ainda com bom contraste
    onPrimary: Colors.white,
    primaryContainer: const Color(
      0xFFE3D7F7,
    ), // lilás mais claro para badges/cards
    onPrimaryContainer: const Color(0xFF1D102E),
    secondaryContainer: const Color(0xFFF0EAFC), // container suave e claro
    onSecondaryContainer: const Color(0xFF2B1C49),
    surfaceContainer: const Color(0xFFF8F5FF),
    surfaceContainerHighest: const Color(0xFFF0ECFF),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    iconTheme: IconThemeData(color: scheme.onSurface),
    shadowColor: Colors.black.withOpacity(0.25),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 6,
      scrolledUnderElevation: 12,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      elevation: 16,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size(40, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: scheme.primary),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: ChipThemeData(
      selectedColor: scheme.primary,
      disabledColor: scheme.surfaceContainer,
      backgroundColor: scheme.secondaryContainer,
      labelStyle: TextStyle(color: scheme.onSecondaryContainer),
      secondaryLabelStyle: TextStyle(color: scheme.onPrimary),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : scheme.onSurfaceVariant,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.onPrimary
            : scheme.onSurface,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : scheme.outlineVariant,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant, width: 1.6),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      color: scheme.surface,
      elevation: 4,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.all(8),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: scheme.surface,
    ),
    popupMenuTheme: PopupMenuThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: scheme.surface,
      elevation: 6,
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primary.withOpacity(0.12),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(color: scheme.onSurface),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      backgroundColor: scheme.surface,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}

ThemeData _buildPurpleDarkTheme() {
  // Dark theme inspirado na imagem: fundo escuro com realces roxos
  const seed = Color(0xFF9C27B0); // Purple 500
  final base = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
  );
  // Ajustes para contraste AA/AAA em fundo escuro e containers roxos
  final scheme = base.copyWith(
    primary: const Color(0xFFC4A8FF), // ligeiramente mais claro
    onPrimary: Colors.black, // mantém contraste alto
    primaryContainer: const Color(0xFF443668),
    onPrimaryContainer: Colors.white,
    secondaryContainer: const Color(0xFF372C50),
    onSecondaryContainer: Colors.white,
    surfaceContainer: const Color(0xFF221D33),
    surfaceContainerHighest: const Color(0xFF2C2740),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    iconTheme: IconThemeData(color: scheme.onSurface),
    shadowColor: Colors.black.withOpacity(0.35),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 6,
      scrolledUnderElevation: 12,
      shadowColor: Colors.black.withOpacity(0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      elevation: 16,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size(40, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: scheme.primary),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: ChipThemeData(
      selectedColor: scheme.primary,
      disabledColor: scheme.surfaceContainer,
      backgroundColor: scheme.secondaryContainer,
      labelStyle: TextStyle(color: scheme.onSecondaryContainer),
      secondaryLabelStyle: TextStyle(color: scheme.onPrimary),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : scheme.onSurfaceVariant,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.onPrimary
            : scheme.onSurface,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : scheme.outlineVariant,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant, width: 1.6),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      color: scheme.surface,
      elevation: 4,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.all(8),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: scheme.surface,
    ),
    popupMenuTheme: PopupMenuThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: scheme.surface,
      elevation: 6,
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primary.withOpacity(0.12),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(color: scheme.onSurface),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      backgroundColor: scheme.surface,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.onToggleTheme});
  final VoidCallback? onToggleTheme;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final QuickActions _quickActions = const QuickActions();

  int rows = 1;
  // Padrão simples: 1 fileira com 1 cadeira (início mínimo)
  // Cada valor representa o TOTAL de cadeiras daquela fileira (coluna).
  List<int> blockSizes = [1];
  // Totais preenchidos por coluna (topo -> baixo). Ex.: [3,4,3]
  List<int> fillTotals = [0];
  int get blocksPerRow => blockSizes.length;
  int standing = 0;
  final List<String> indicators = [];
  String? meetingType;
  late List<List<bool?>> grid; // true=ocupado, false=livre, null=corredor
  final List<_Record> records = [];
  // Grupos de colunas: um único grupo com 3 colunas (sem corredor vertical interno)
  List<int> columnGroups = [1];
  // Organizador por fileira (coluna): N em N para inserir corredor após cada N colunas nesta fileira
  List<int> rowGroupSteps = [1];
  // Preferências
  int alertThreshold = kRowGroupingAlertThreshold;
  bool useTertiaryTotalBadge = false; // false=primary, true=tertiary
  // Layouts salvos removidos
  // Índice da fileira atual (carrossel) exposto pela tela Contagem
  final ValueNotifier<int> _currentBlockVN = ValueNotifier<int>(0);
  // Ao salvar na tela de Contagem, sinaliza para a tela de Registros resetar filtros/busca
  bool _resetRecordsOnShow = false;

  @override
  void initState() {
    super.initState();
    grid = _buildGrid(rows: rows, blockSizes: blockSizes, steps: rowGroupSteps);
    meetingType = kMeetingTypes.first; // tipo padrão
    _loadPrefs();
    _loadRecords();

    // Atalhos do app (launcher quick actions)
    if (!kIsWeb) {
      _quickActions.initialize((type) async {
        if (type == 'send_card') {
          await _sendLatestAttendanceCard();
        } else if (type == 'save_record') {
          setState(() => _index = 0);
          await saveRecord();
        }
      });
      _quickActions.setShortcutItems(const <ShortcutItem>[
        ShortcutItem(
          type: 'send_card',
          localizedTitle: 'Enviar cartão',
          icon: 'shortcut_icon_v2',
        ),
        ShortcutItem(
          type: 'save_record',
          localizedTitle: 'Salvar registro',
          icon: 'shortcut_icon_v2',
        ),
      ]);
    }
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockJson = prefs.getString('layout.blockSizes');
      final stepsJson = prefs.getString('layout.rowGroupSteps');
      final fillsJson = prefs.getString('layout.fillTotals');
      final alertPref = prefs.getInt('prefs.alertThreshold');
      final badgePref = prefs.getBool('prefs.useTertiaryTotalBadge');

      List<int>? savedBlocks;
      List<int>? savedSteps;
      List<int>? savedFills;

      if (blockJson != null) {
        try {
          final list = jsonDecode(blockJson) as List;
          savedBlocks = list
              .map((e) => int.tryParse(e.toString()) ?? 0)
              .toList();
        } catch (_) {}
      }
      if (stepsJson != null) {
        try {
          final list = jsonDecode(stepsJson) as List;
          savedSteps = list
              .map((e) => int.tryParse(e.toString()) ?? 1)
              .toList();
        } catch (_) {}
      }
      if (fillsJson != null) {
        try {
          final list = jsonDecode(fillsJson) as List;
          savedFills = list
              .map((e) => int.tryParse(e.toString()) ?? 0)
              .toList();
        } catch (_) {}
      }

      setState(() {
        if (savedBlocks != null && savedBlocks.isNotEmpty) {
          blockSizes = savedBlocks;
        }
        if (savedSteps != null && savedSteps.isNotEmpty) {
          rowGroupSteps = savedSteps.map((v) => v <= 0 ? 1 : v).toList();
        }
        if (savedFills != null && savedFills.isNotEmpty) {
          fillTotals = savedFills;
        }
        if (alertPref != null && alertPref > 0) {
          alertThreshold = alertPref;
        }
        if (badgePref != null) {
          useTertiaryTotalBadge = badgePref;
        }
        // Reconstroi grade conforme prefs
        final ns = List<int>.generate(
          blockSizes.length,
          (i) => i < rowGroupSteps.length
              ? (rowGroupSteps[i] <= 0 ? 1 : rowGroupSteps[i])
              : 1,
        );
        final rs = List<int>.generate(blockSizes.length, (i) {
          final f = blockSizes[i];
          final n = ns[i];
          return (f + n - 1) ~/ n;
        });
        rows = rs.isEmpty ? 0 : rs.reduce((a, b) => a > b ? a : b);
        grid = _buildGrid(
          rows: rows,
          blockSizes: blockSizes,
          steps: rowGroupSteps,
        );
      });
    } catch (_) {
      // Ignora falhas de leitura
    }
  }

  Future<void> _persistLayoutPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('layout.blockSizes', jsonEncode(blockSizes));
      await prefs.setString('layout.rowGroupSteps', jsonEncode(rowGroupSteps));
      await prefs.setString('layout.fillTotals', jsonEncode(fillTotals));
      await prefs.setInt('prefs.alertThreshold', alertThreshold);
      await prefs.setBool('prefs.useTertiaryTotalBadge', useTertiaryTotalBadge);
    } catch (_) {
      // Ignora falhas de escrita
    }
  }

  Future<void> _persistRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = records.map((r) => r.toJson()).toList();
      await prefs.setString('records.list', jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('records.list');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final list = jsonDecode(jsonStr) as List;
        final parsed = list
            .map((e) => _Record.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
        setState(() {
          records
            ..clear()
            ..addAll(parsed);
        });
      }
    } catch (_) {}
  }

  // Funções de layouts salvos removidas

  List<List<bool?>> _buildGrid({
    required int rows,
    required List<int> blockSizes,
    required List<int> steps,
  }) {
    // Novo modelo por blocos lado a lado: cada fileira i tem F_i poltronas e passo N_i.
    // Para cada fileira i, criamos um bloco com N_i colunas e R_i = ceil(F_i / N_i) linhas.
    // A grade final tem rows = max(R_i) e columns = soma(N_i) (sem corredor físico; usaremos gap visual).
    final fileiras = blockSizes.length;
    final ns = List<int>.generate(
      fileiras,
      (i) => i < steps.length ? (steps[i] <= 0 ? 1 : steps[i]) : 1,
    );
    final rs = List<int>.generate(fileiras, (i) {
      final f = blockSizes[i];
      final n = ns[i];
      return (f + n - 1) ~/ n; // ceil division -> linhas do bloco i
    });
    final rowsFinal = rs.isEmpty ? 0 : rs.reduce((a, b) => a > b ? a : b);
    // columnsFinal agora inclui colunas de corredor explícitas entre fileiras
    final columnsFinal = (ns.isEmpty
        ? 0
        : ns.reduce((a, b) => a + b) + (fileiras > 1 ? (fileiras - 1) : 0));

    return List.generate(rowsFinal, (r) {
      final row = <bool?>[];
      for (int i = 0; i < fileiras; i++) {
        final n = ns[i];
        final f = blockSizes[i];
        final ri = rs[i];
        for (int c = 0; c < n; c++) {
          final seatIndex = r * n + c;
          final hasSeat = (r < ri) && (seatIndex < f);
          row.add(hasSeat ? false : null);
        }
        // Inserir coluna de corredor explícita entre fileiras
        if (i < fileiras - 1) {
          row.add(null);
        }
      }
      // Garante largura pretendida (columnsFinal) com nulos caso necessário
      while (row.length < columnsFinal) {
        row.add(null);
      }
      return row;
    });
  }

  int get occupiedCount =>
      grid.expand((row) => row).where((cell) => cell == true).length;
  int get total => occupiedCount + standing;

  List<int> _occupiedByBlockTotals() {
    final columns = grid.isNotEmpty ? grid.first.length : 0;
    final steps = rowGroupSteps.isNotEmpty
        ? rowGroupSteps.map((v) => v <= 0 ? 1 : v).toList()
        : <int>[];
    if (columns == 0 || grid.isEmpty || steps.isEmpty) return [];

    final totals = <int>[];
    int acc = 0;
    for (int i = 0; i < steps.length; i++) {
      final start = acc;
      final width = steps[i];
      int t = 0;
      for (int r = 0; r < grid.length; r++) {
        for (int c = start; c < start + width && c < columns; c++) {
          final cell = grid[r][c];
          if (cell == true) t++;
        }
      }
      totals.add(t);
      acc += width;
      if (i < steps.length - 1) acc += 1; // corredor
    }
    return totals;
  }

  void toggleSeat(int r, int c) {
    final cell = grid[r][c];
    if (cell == null) return;
    grid[r][c] = !cell;
    setState(() {});
  }

  void fillAllSeatsOccupied() {
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < (grid.isNotEmpty ? grid.first.length : 0); c++) {
        final cell = grid[r][c];
        if (cell != null) {
          grid[r][c] = true;
        }
      }
    }
    setState(() {});
  }

  // Removido: preenchimento por fileira (ação duplicada)

  // Preencher apenas a fileira (bloco) atual
  void fillBlockOccupied(int blockIndex) {
    final columns = grid.isNotEmpty ? grid.first.length : 0;
    final steps = rowGroupSteps.isNotEmpty
        ? rowGroupSteps.map((v) => v <= 0 ? 1 : v).toList()
        : <int>[];
    if (columns == 0 || grid.isEmpty || steps.isEmpty) return;
    int acc = 0;
    for (int i = 0; i < steps.length; i++) {
      final start = acc;
      final width = steps[i];
      if (i == blockIndex) {
        for (int r = 0; r < grid.length; r++) {
          for (int c = start; c < start + width && c < columns; c++) {
            final cell = grid[r][c];
            if (cell != null) {
              grid[r][c] = true;
            }
          }
        }
        setState(() {});
        return;
      }
      acc += width;
      if (i < steps.length - 1) acc += 1; // corredor
    }
  }

  // Despreencher apenas a fileira (bloco) atual
  void clearBlockSeats(int blockIndex) {
    final columns = grid.isNotEmpty ? grid.first.length : 0;
    final steps = rowGroupSteps.isNotEmpty
        ? rowGroupSteps.map((v) => v <= 0 ? 1 : v).toList()
        : <int>[];
    if (columns == 0 || grid.isEmpty || steps.isEmpty) return;
    int acc = 0;
    for (int i = 0; i < steps.length; i++) {
      final start = acc;
      final width = steps[i];
      if (i == blockIndex) {
        for (int r = 0; r < grid.length; r++) {
          for (int c = start; c < start + width && c < columns; c++) {
            final cell = grid[r][c];
            if (cell != null) {
              grid[r][c] = false;
            }
          }
        }
        setState(() {});
        return;
      }
      acc += width;
      if (i < steps.length - 1) acc += 1; // corredor
    }
  }

  void clearAllSeats() {
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < (grid.isNotEmpty ? grid.first.length : 0); c++) {
        final cell = grid[r][c];
        if (cell != null) {
          grid[r][c] = false;
        }
      }
    }
    setState(() {});
  }

  Future<void> _sendLatestAttendanceCard() async {
    final messenger = ScaffoldMessenger.of(context);
    if (records.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Nenhum registro para enviar')),
      );
      setState(() => _index = 0);
      return;
    }
    final r = records.first;
    final png = await _buildAttendanceCardPng(r);
    final name = 'cartao_${DateFormat('yyyyMMdd_HHmm').format(r.dateTime)}.png';
    final file = await saveBytes(png, name);
    await Share.shareXFiles([XFile(file.path)], text: 'Cartão de Assistência');
  }

  // Removido: limpeza por fileira (ação duplicada)

  Future<void> saveRecord({String? notes}) async {
    // Valida requisitos antes de iniciar o fluxo
    if (indicators.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um indicador')),
      );
      return;
    }
    if (meetingType == null || meetingType!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o tipo da reunião')),
      );
      return;
    }

    bool dialogShown = false;
    debugPrint(
      'saveRecord: begin occupied=$occupiedCount standing=$standing indicators=${indicators.length} mt=$meetingType',
    );
    try {
      // Mostra indicador de progresso e dá um pequeno atraso para UX
      material.showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const material.Center(
          child: material.CircularProgressIndicator(),
        ),
      );
      dialogShown = true;
      await dart_async.Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) {
        if (dialogShown) {
          // Fecha o diálogo se o widget foi desmontado
          try {
            Navigator.of(context).pop();
          } catch (_) {}
        }
        return;
      }

      final perBlock = _occupiedByBlockTotals();
      records.insert(
        0,
        _Record(
          dateTime: DateTime.now(),
          occupied: occupiedCount,
          standing: standing,
          indicators: List.from(indicators),
          meetingType: meetingType!,
          perBlockOccupied: List.from(perBlock),
          perBlockCapacity: List.from(blockSizes),
          notes: notes,
        ),
      );

      // Fecha diálogo de progresso com segurança
      if (dialogShown) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
        dialogShown = false;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro salvo. Você pode editar em Registros.'),
        ),
      );
      setState(() {
        // Após salvar, navega para a aba Registros para o usuário ver o item listado.
        _index = 2;
        _resetRecordsOnShow = true;
      });

      // Persiste lista de registros e aguarda conclusão
      await _persistRecords();
      debugPrint('saveRecord: success, total records=${records.length}');
    } catch (e, st) {
      // Fecha o diálogo se ainda estiver aberto
      if (dialogShown) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
        dialogShown = false;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar registro: $e')),
        );
      }
      debugPrint('Erro ao salvar registro: $e\n$st');
    }
  }

  void applyAuditorium({
    List<int>? newBlockSizes,
    List<int>? newRowGroupSteps,
    List<int>? newFillTotals,
    bool goToCount = true,
  }) {
    // Atualiza capacidade (se fornecida)
    if (newBlockSizes != null && newBlockSizes.isNotEmpty) {
      blockSizes = List.from(newBlockSizes);
    }
    // Altura da grade passa a ser o máximo de linhas entre blocos (ceil(F/N) por fileira)
    // Ajusta organizador por fileira (se fornecido). Caso contrário, normaliza com 1 por fileira.
    if (newRowGroupSteps != null && newRowGroupSteps.isNotEmpty) {
      rowGroupSteps = List.from(newRowGroupSteps.map((v) => v <= 0 ? 1 : v));
    } else {
      rowGroupSteps = List<int>.filled(blockSizes.length, 1);
    }
    // Constrói grade com capacidade e passos por fileira
    final normSteps = List<int>.generate(
      blockSizes.length,
      (i) => i < rowGroupSteps.length
          ? (rowGroupSteps[i] <= 0 ? 1 : rowGroupSteps[i])
          : 1,
    );
    final rowsPerBlock = List<int>.generate(blockSizes.length, (i) {
      final f = blockSizes[i];
      final n = normSteps[i];
      return (f + n - 1) ~/ n;
    });
    rows = rowsPerBlock.isEmpty
        ? 0
        : rowsPerBlock.reduce((a, b) => a > b ? a : b);
    grid = _buildGrid(rows: rows, blockSizes: blockSizes, steps: rowGroupSteps);
    // Atualiza preenchidos (se fornecido) e aplica ocupação do topo para baixo
    if (newFillTotals != null && newFillTotals.isNotEmpty) {
      fillTotals = List.from(newFillTotals);
    }
    // Aplica ocupação inicial conforme fillTotals
    // Preenchimento inicial desabilitado neste modo (mantém tudo livre)
    standing = 0;
    setState(() {
      // Opcionalmente navega para a aba Contagem para visualizar a nova grade.
      if (goToCount) {
        _index = 0;
      }
    });
    // Persiste layout e preferências após aplicar
    _persistLayoutPrefs();
  }

  // _addRecord removido por não ser utilizado (limpeza)
  // A criação de registros é feita pelos modais existentes na tela de Registros.
  // Caso necessário no futuro, este recurso pode ser reintroduzido com validações.

  @override
  Widget build(BuildContext context) {
    // Larguras dos botões do rodapé calculadas dinamicamente para caber lado a lado
    // Removido cálculo de larguras do rodapé não utilizado
    // Renderiza apenas a página ativa para evitar múltiplos GlobalKeys simultâneos.
    late final Widget bodyChild;
    switch (_index) {
      case 0:
        bodyChild = _CountScreen(
          key: const ValueKey('page_count'),
          grid: grid,
          standing: standing,
          onSeatTap: toggleSeat,
          onIncStanding: () => setState(() => standing++),
          onDecStanding: () =>
              setState(() => standing = standing > 0 ? standing - 1 : 0),
          onSave: saveRecord,
          onFillAllSeats: fillAllSeatsOccupied,
          onClearAllSeats: clearAllSeats,
          onFillCurrentBlock: (i) => fillBlockOccupied(i),
          onClearCurrentBlock: (i) => clearBlockSeats(i),
          onCurrentBlockChanged: (i) => _currentBlockVN.value = i,
          occupied: occupiedCount,
          total: total,
          indicators: indicators,
          meetingType: meetingType,
          rowGroupSteps: rowGroupSteps,
          blockSizes: blockSizes,
          fillTotals: fillTotals,
          onAddIndicator: (name) {
            final t = name.trim();
            if (t.isEmpty) return;
            final cap = t[0].toUpperCase() +
                (t.length > 1 ? t.substring(1) : '');
            setState(() => indicators.add(cap));
          },
          onRemoveIndicator: (index) {
            if (index < 0 || index >= indicators.length) return;
            setState(() => indicators.removeAt(index));
          },
          onMeetingChanged: (t) => setState(() => meetingType = t),
          useTertiaryTotalBadge: useTertiaryTotalBadge,
        );
        break;
      case 1:
        bodyChild = _AuditoriumsScreen(
          key: const ValueKey('page_auditoriums'),
          blockSizes: blockSizes,
          rowGroupSteps: rowGroupSteps,
          fillTotals: fillTotals,
          onApply: applyAuditorium,
          onSaveOrganization:
              ({
                List<int>? newBlockSizes,
                List<int>? newRowGroupSteps,
                List<int>? newFillTotals,
              }) {
                setState(() {
                  if (newBlockSizes != null && newBlockSizes.isNotEmpty) {
                    blockSizes = List.from(newBlockSizes);
                  }
                  if (newRowGroupSteps != null &&
                      newRowGroupSteps.isNotEmpty) {
                    rowGroupSteps = List.from(
                      newRowGroupSteps.map((v) => v <= 0 ? 1 : v),
                    );
                  } else {
                    rowGroupSteps = List<int>.filled(blockSizes.length, 1);
                  }
                  if (newFillTotals != null && newFillTotals.isNotEmpty) {
                    fillTotals = List.from(newFillTotals);
                  } else {
                    fillTotals = List<int>.filled(blockSizes.length, 0);
                  }
                });
                _persistLayoutPrefs();
                // Aplica imediatamente para refletir na tela de Contagem e reconstruir a grade
                applyAuditorium(
                  newBlockSizes: blockSizes,
                  newRowGroupSteps: rowGroupSteps,
                  newFillTotals: fillTotals,
                  goToCount: true,
                );
              },
          onToggleTheme: widget.onToggleTheme,
          alertThreshold: alertThreshold,
          useTertiaryTotalBadge: useTertiaryTotalBadge,
          onUpdatePrefs:
              ({int? newAlertThreshold, bool? newUseTertiaryTotalBadge}) {
                setState(() {
                  if (newAlertThreshold != null && newAlertThreshold > 0) {
                    alertThreshold = newAlertThreshold;
                  }
                  if (newUseTertiaryTotalBadge != null) {
                    useTertiaryTotalBadge = newUseTertiaryTotalBadge;
                  }
                });
                _persistLayoutPrefs();
              },
        );
        break;
      default:
        bodyChild = _RecordsScreen(
          key: const ValueKey('page_records'),
          records: records,
          resetOnShow: _resetRecordsOnShow,
          onResetConsumed: () => setState(() => _resetRecordsOnShow = false),
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.reduce_capacity_outlined),
            SizedBox(width: 8),
            Text('Contagem de Assistência'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Alternar tema',
            onPressed: widget.onToggleTheme,
            icon: const Icon(Icons.brightness_6),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: bodyChild,
          ),
        ),
      ),
      // Removido o botão de adicionar na aba Registros conforme solicitação
      floatingActionButton: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // Rodapé fixo desativado — botões dinâmicos dentro da tela de Contagem
      persistentFooterButtons: null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.reduce_capacity_outlined),
            label: 'Contagem',
          ),
          NavigationDestination(
            icon: Icon(Icons.theaters),
            label: 'Auditórios',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Registros',
          ),
        ],
      ),
    );
  }
}

class _CountScreen extends StatefulWidget {
  const _CountScreen({
    super.key,
    required this.grid,
    required this.standing,
    required this.onSeatTap,
    required this.onIncStanding,
    required this.onDecStanding,
    required this.onSave,
    required this.onFillAllSeats,
    required this.onClearAllSeats,
    required this.onFillCurrentBlock,
    required this.onClearCurrentBlock,
    required this.onCurrentBlockChanged,
    required this.occupied,
    required this.total,
    required this.indicators,
    this.meetingType,
    required this.rowGroupSteps,
    required this.blockSizes,
    required this.fillTotals,
    required this.onAddIndicator,
    required this.onRemoveIndicator,
    required this.onMeetingChanged,
    required this.useTertiaryTotalBadge,
  });

  final List<List<bool?>> grid;
  final int standing;
  final void Function(int r, int c) onSeatTap;
  final VoidCallback onIncStanding;
  final VoidCallback onDecStanding;
  final void Function({String? notes}) onSave;
  final VoidCallback onFillAllSeats;
  final VoidCallback onClearAllSeats;
  final void Function(int blockIndex) onFillCurrentBlock;
  final void Function(int blockIndex) onClearCurrentBlock;
  final ValueChanged<int> onCurrentBlockChanged;
  final int occupied;
  final int total;
  final List<String> indicators;
  final String? meetingType;
  final List<int> rowGroupSteps;
  final List<int> blockSizes;
  final List<int> fillTotals;
  final ValueChanged<String> onAddIndicator;
  final void Function(int index) onRemoveIndicator;
  final ValueChanged<String?> onMeetingChanged;
  final bool useTertiaryTotalBadge;

  @override
  State<_CountScreen> createState() => _CountScreenState();
}

class _CountScreenState extends State<_CountScreen> {
  // Calcula ocupados por fileira (bloco) considerando a grade e os passos
  List<int> _occupiedByBlock() {
    final columns = widget.grid.isNotEmpty ? widget.grid.first.length : 0;
    final steps = widget.rowGroupSteps.isNotEmpty
        ? widget.rowGroupSteps.map((v) => v <= 0 ? 1 : v).toList()
        : <int>[];
    if (columns == 0 || widget.grid.isEmpty || steps.isEmpty) return [];

    final totals = <int>[];
    int acc = 0;
    for (int i = 0; i < steps.length; i++) {
      final start = acc;
      final width = steps[i];
      int t = 0;
      for (int r = 0; r < widget.grid.length; r++) {
        for (int c = start; c < start + width && c < columns; c++) {
          final cell = widget.grid[r][c];
          if (cell == true) t++;
        }
      }
      totals.add(t);
      acc += width;
      if (i < steps.length - 1) acc += 1; // coluna de corredor entre fileiras
    }
    return totals;
  }

  final ScrollController _hCtrl = ScrollController();
  // Controlador da rolagem vertical para mostrar botão "Voltar ao início" ao descer
  final ScrollController _vCtrl = ScrollController();
  bool _showBackToTop = false;
  int _currentBlock = 0;
  // Modo filtrado: exibe somente a fileira/bloco selecionado pelo carrossel
  final bool _filteredMode = true;
  final Set<int> _pressed = <int>{};
  bool _showGridOverlay = false;

  void _snapToNearest(double viewportWidth) {
    // Alinha suavemente a rolagem ao múltiplo exato da largura de uma célula
    const double seatCellWidth = 96.0; // manter em sincronia com build()
    const double crossSpacing = 6.0; // manter em sincronia com build()
    final double step = seatCellWidth + crossSpacing;
    double target = (_hCtrl.offset / step).round() * step;
    // Limita dentro do conteúdo
    final double maxExtent = _hCtrl.position.maxScrollExtent;
    if (target > maxExtent) target = maxExtent;
    if (target < 0) target = 0;
    if ((target - _hCtrl.offset).abs() > 0.5) {
      _hCtrl.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToCenterForContent({
    required double viewportWidth,
    required double contentWidth,
  }) {
    final double extra = (contentWidth - viewportWidth);
    double target = extra <= 0 ? 0.0 : extra / 2.0;
    final double maxExtent = _hCtrl.position.maxScrollExtent;
    if (target > maxExtent) target = maxExtent;
    if (target < 0) target = 0;
    _hCtrl
        .animateTo(
          target,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        )
        .then((_) => _snapToNearest(viewportWidth));
  }

  @override
  void initState() {
    super.initState();
    _hCtrl.addListener(_onScroll);
    _vCtrl.addListener(_onVScroll);
  }

  @override
  void dispose() {
    _hCtrl.removeListener(_onScroll);
    _hCtrl.dispose();
    _vCtrl.removeListener(_onVScroll);
    _vCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_filteredMode) return; // não altera fileira atual quando modo filtrado
    const double seatCellWidth = 96.0;
    const double crossSpacing = 6.0;
    final steps = widget.rowGroupSteps.isNotEmpty
        ? widget.rowGroupSteps.map((v) => v <= 0 ? 1 : v).toList()
        : <int>[];
    double acc = 0.0;
    int b = 0;
    for (int i = 0; i < steps.length; i++) {
      final blockW = steps[i] * seatCellWidth + crossSpacing * (steps[i] - 1);
      final corridorW = (i < steps.length - 1)
          ? (seatCellWidth + crossSpacing)
          : 0.0;
      final start = acc;
      final end = acc + blockW;
      final x = _hCtrl.offset;
      if (x >= start && x < end) {
        b = i;
        break;
      }
      acc += blockW + corridorW;
      b = i;
    }
    if (b != _currentBlock) {
      setState(() => _currentBlock = b);
      widget.onCurrentBlockChanged(_currentBlock);
    }
  }

  void _onVScroll() {
    final bool shouldShow = _vCtrl.hasClients && _vCtrl.offset > 80.0;
    if (shouldShow != _showBackToTop) {
      setState(() => _showBackToTop = shouldShow);
    }
  }

  void _scrollToBlock(int index) {
    const double seatCellWidth = 96.0;
    const double crossSpacing = 6.0;
    final steps = widget.rowGroupSteps.isNotEmpty
        ? widget.rowGroupSteps.map((v) => v <= 0 ? 1 : v).toList()
        : <int>[];
    double offset = 0.0;
    for (int i = 0; i < index && i < steps.length; i++) {
      final blockW = steps[i] * seatCellWidth + crossSpacing * (steps[i] - 1);
      final corridorW = (i < steps.length - 1)
          ? (seatCellWidth + crossSpacing)
          : 0.0;
      offset += blockW + corridorW;
    }
    _hCtrl.animateTo(
      offset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // Rola um "passo" de viewport para cada toque na seta,
  // mantendo o tamanho das poltronas fixo e alinhando ao grid.
  void _scrollByViewport({
    required bool toRight,
    required double viewportWidth,
  }) {
    const double seatCellWidth = 96.0;
    const double crossSpacing = 6.0;
    final double perColW = seatCellWidth + crossSpacing;
    final int viewportCols = (viewportWidth / perColW).floor().clamp(1, 1000);
    final double delta = viewportCols * perColW;
    double target = toRight ? (_hCtrl.offset + delta) : (_hCtrl.offset - delta);
    final double maxExtent = _hCtrl.position.maxScrollExtent;
    if (target < 0) target = 0;
    if (target > maxExtent) target = maxExtent;
    _hCtrl
        .animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        )
        .then((_) => _snapToNearest(viewportWidth));
  }

  void _scrollToTop() {
    if (_vCtrl.hasClients) {
      _vCtrl.animateTo(
        0.0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void didUpdateWidget(covariant _CountScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Quando muda organização/grade, garantir primeira coluna visível
    if (!_filteredMode) {
      // Em modo não filtrado, rola para início do bloco atual
      _scrollToBlock(_currentBlock);
    } else {
      // Em modo filtrado, zera rolagem para mostrar coluna inicial
      if (_hCtrl.hasClients) {
        _hCtrl.jumpTo(0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = widget.grid.isNotEmpty ? widget.grid.first.length : 0;
    final rows = widget.grid.length;
    final steps = widget.rowGroupSteps.isNotEmpty
        ? widget.rowGroupSteps.map((v) => v <= 0 ? 1 : v).toList()
        : <int>[];
    final occupiedByBlock = _occupiedByBlock();
    int blockStart = 0;
    int visibleBlockWidth = columns;
    if (_filteredMode && steps.isNotEmpty) {
      // calcula início da fileira selecionada considerando corredores (1 coluna entre blocos)
      int acc = 0;
      for (int i = 0; i < steps.length; i++) {
        if (i == _currentBlock) {
          blockStart = acc;
          visibleBlockWidth = steps[i];
          break;
        }
        acc += steps[i];
        if (i < steps.length - 1) acc += 1; // corredor
      }
    }

    return SafeArea(
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SingleChildScrollView(
              controller: _vCtrl,
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                // Reserva espaço para a barra flutuante
                MediaQuery.of(context).padding.bottom + 92,
              ),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ocupados: ${widget.occupied}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Em pé: ${widget.standing}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      final Color badgeBase = widget.useTertiaryTotalBadge
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.primary;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBase.withValues(
                            alpha: theme.brightness == Brightness.dark
                                ? 0.25
                                : 0.18,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: badgeBase.withValues(alpha: 0.55),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          'Total: ${widget.total}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: badgeBase,
                            shadows: [
                              Shadow(
                                color: badgeBase.withValues(alpha: 0.8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Fileira anterior',
                    onPressed: () {
                      if (_currentBlock > 0) {
                        setState(() => _currentBlock--);
                        widget.onCurrentBlockChanged(_currentBlock);
                      }
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    'Fileira ${_currentBlock + 1}/${widget.rowGroupSteps.length}',
                  ),
                  IconButton(
                    tooltip: 'Próxima fileira',
                    onPressed: () {
                      final totalBlocks = widget.rowGroupSteps.length;
                      if (_currentBlock < totalBlocks - 1) {
                        setState(() => _currentBlock++);
                        widget.onCurrentBlockChanged(_currentBlock);
                      }
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _IndicatorInput(
                onAdd: widget.onAddIndicator,
                indicators: widget.indicators,
                onRemove: widget.onRemoveIndicator,
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: widget.meetingType,
                decoration: const InputDecoration(
                  labelText: 'Tipo da reunião',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                items: [
                  for (final t in kMeetingTypes)
                    DropdownMenuItem(value: t, child: Text(t)),
                ],
                onChanged: widget.onMeetingChanged,
              ),
              const SizedBox(height: 2),
              if (widget.rowGroupSteps.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (
                            int i = 0;
                            i < widget.rowGroupSteps.length;
                            i++
                          ) ...[
                            GestureDetector(
                              onTap: () {
                                setState(() => _currentBlock = i);
                                if (!_filteredMode) {
                                  _scrollToBlock(i);
                                }
                                widget.onCurrentBlockChanged(_currentBlock);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: (i == _currentBlock)
                                      ? Theme.of(context).colorScheme.primary
                                      : (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFF3A3A3A)
                                            : Colors.black12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Fileira ${i + 1}',
                                  style: TextStyle(
                                    color: (i == _currentBlock)
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                        : null,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            if (i < widget.rowGroupSteps.length - 1)
                              const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              // Depuração: mostra a configuração atual aplicada
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  // 3D panel look: subtle gradient + shadow + fine border
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .shadowColor
                          .withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Poltronas por fileira: '),
                          TextSpan(
                            text: widget.blockSizes.isNotEmpty
                                ? widget.blockSizes.join(',')
                                : '-',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Organizador por fileira: '),
                          TextSpan(
                            text: widget.rowGroupSteps.isNotEmpty
                                ? widget.rowGroupSteps.join(',')
                                : '-',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'Preenchidos na fileira ${_currentBlock + 1}: ',
                          ),
                          TextSpan(
                            text: (occupiedByBlock.isNotEmpty &&
                                    _currentBlock >= 0 &&
                                    _currentBlock < occupiedByBlock.length)
                                ? occupiedByBlock[_currentBlock].toString()
                                : '-',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              LayoutBuilder(
                builder: (context, constraints) {
                  // No Web, limitamos a largura do grid para evitar células exageradamente grandes.
                  // Largura alvo por célula (coluna) mais espaçamento entre colunas.
                  // Espaçamentos maiores para ficar semelhante ao desenho (arejado).
                  // Espaçamento lateral um pouco menor para as linhas dos corredores ficarem mais contínuas visualmente.
                  // Aproximar colunas, mas com espaçamento suficiente para toque confortável
                  const crossSpacing = 6.0;
                  // Define colunas visíveis (fileira filtrada ou todas)
                  final int contentColumns = _filteredMode
                      ? visibleBlockWidth
                      : columns;

                  // Mantém largura fixa da célula para não diminuir ao aumentar colunas.
                  const double seatCellWidth = 96.0;
                  final double targetCellHeight =
                      seatCellWidth; // ícone centralizado
                  final double childAspectRatio =
                      seatCellWidth / targetCellHeight;

                  // Tamanho do ícone proporcional à célula
                  final double seatIconSize = (seatCellWidth * 0.52).clamp(
                    24.0,
                    52.0,
                  );

                  // Largura total do conteúdo do grid para permitir rolagem horizontal
                  final double contentWidth = contentColumns == 0
                      ? seatCellWidth
                      : (contentColumns * seatCellWidth +
                            crossSpacing * (contentColumns - 1));

                  // Calcula linhas efetivas com algum assento visível no bloco atual
                  final List<int> visibleRowIndices =
                      List<int>.generate(rows, (i) => i).where((i) {
                        for (
                          int localC = 0;
                          localC < contentColumns;
                          localC++
                        ) {
                          final c = _filteredMode
                              ? (blockStart + localC)
                              : localC;
                          final cell = widget.grid[i][c];
                          if (cell != null) return true;
                        }
                        return false;
                      }).toList();
                  final int effectiveRows = visibleRowIndices.length;

                  final grid = GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: contentColumns,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: crossSpacing,
                      childAspectRatio: childAspectRatio,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: effectiveRows * contentColumns,
                    itemBuilder: (context, index) {
                      final r = visibleRowIndices[index ~/ contentColumns];
                      final localC = index % contentColumns;
                      final c = _filteredMode ? (blockStart + localC) : localC;
                      final cell = widget.grid[r][c];
                      if (cell == null) {
                        // Células nulas representam ausência de cadeira (vazio) ou corredor.
                        // Em modo filtrado, corredores externos não são exibidos; apenas vazio.
                        return const SizedBox.shrink();
                      }
                      final occupied = cell;
                      final int seatKey = index;
                      return InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTapDown: (_) => setState(() {
                          _pressed.add(seatKey);
                        }),
                        onTapCancel: () => setState(() {
                          _pressed.remove(seatKey);
                        }),
                        onTap: () {
                          widget.onSeatTap(r, c);
                          setState(() {
                            _pressed.remove(seatKey);
                          });
                        },
                        child: Center(
                          child: Transform.scale(
                            scale: _pressed.contains(seatKey) ? 0.92 : 1.0,
                            child: FractionallySizedBox(
                              widthFactor: 0.95,
                              heightFactor: 0.95,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: occupied
                                        ? [
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.85),
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ]
                                        : [
                                            Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondaryContainer,
                                          ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? 0.35
                                            : 0.15,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant
                                        .withValues(alpha: 0.30),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    occupied ? Icons.person : Icons.event_seat,
                                    size: seatIconSize,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );

                  // Cálculo de overflow e quantidades ocultas à esquerda/direita
                  final double perColW = seatCellWidth + crossSpacing;
                  final int viewportCols = (constraints.maxWidth / perColW)
                      .floor()
                      .clamp(0, contentColumns);
                  final double offset = _hCtrl.hasClients ? _hCtrl.offset : 0.0;
                  final int leftHidden = (offset / perColW).floor().clamp(
                    0,
                    contentColumns,
                  );
                  final int rightHidden =
                      (contentColumns - leftHidden - viewportCols).clamp(
                        0,
                        contentColumns,
                      );
                  final bool showLeft = leftHidden > 0;
                  final bool showRight = rightHidden > 0;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (n) {
                            if (n is ScrollEndNotification) {
                              _snapToNearest(constraints.maxWidth);
                            }
                            setState(() {});
                            return false;
                          },
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              ScrollConfiguration(
                                behavior: _NoGlowBehavior(),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: _hCtrl,
                                  physics: const ClampingScrollPhysics(),
                                  dragStartBehavior: DragStartBehavior.down,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 44.0,
                                      ),
                                      child: Center(
                                        child: SizedBox(
                                          width: contentWidth,
                                          child: Material(
                                            elevation: 12,
                                            shadowColor:
                                                Theme.of(context).shadowColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: grid,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_showGridOverlay)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: GridPaper(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant
                                          .withValues(alpha: 0.18),
                                      interval: seatCellWidth + crossSpacing,
                                      divisions: 1,
                                      subdivisions: 4,
                                    ),
                                  ),
                                ),
                              Positioned(
                                left: 4,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: showLeft
                                        ? () {
                                            _scrollByViewport(
                                              toRight: false,
                                              viewportWidth:
                                                  constraints.maxWidth,
                                            );
                                          }
                                        : null,
                                    child: _OverflowHint(
                                      visible: showLeft,
                                      direction: AxisDirection.left,
                                      count: leftHidden,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: showRight
                                        ? () {
                                            _scrollByViewport(
                                              toRight: true,
                                              viewportWidth:
                                                  constraints.maxWidth,
                                            );
                                          }
                                        : null,
                                    child: _OverflowHint(
                                      visible: showRight,
                                      direction: AxisDirection.right,
                                      count: rightHidden,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              _scrollToCenterForContent(
                                viewportWidth: constraints.maxWidth,
                                contentWidth: contentWidth,
                              );
                            },
                            icon: const Icon(Icons.center_focus_strong),
                            label: const Text('Centralizar'),
                          ),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showGridOverlay = !_showGridOverlay;
                              });
                            },
                            icon: Icon(
                              _showGridOverlay
                                  ? Icons.grid_off
                                  : Icons.grid_on,
                            ),
                            label: Text(
                              _showGridOverlay ? 'Ocultar grade' : 'Mostrar grade',
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Em pé:'),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: widget.onDecStanding,
                      icon: const Icon(Icons.person_remove_alt_1),
                    ),
                    Text('${widget.standing}'),
                    IconButton(
                      onPressed: widget.onIncStanding,
                      icon: const Icon(Icons.person_add_alt_1),
                    ),
                    const SizedBox(width: 8),
                    if (_showBackToTop)
                      TextButton.icon(
                        onPressed: _scrollToTop,
                        icon: const Icon(Icons.arrow_upward),
                        label: const Text('Início'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              // Botões dinâmicos da Contagem (Salvar acima; Preencher/Despreencher abaixo)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => widget.onSave(),
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              widget.onFillCurrentBlock(_currentBlock),
                          icon: const Icon(Icons.playlist_add_check),
                          label: const Text('Preencher fileira atual'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              widget.onClearCurrentBlock(_currentBlock),
                          icon: const Icon(Icons.playlist_remove),
                          label: const Text('Despreencher fileira atual'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        ), // fecha GestureDetector antes dos próximos filhos do Stack
          // Barra flutuante fixa na viewport com navegação horizontal
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: _hCtrl.hasClients
                            ? () => _scrollByViewport(
                                  toRight: false,
                                  viewportWidth:
                                      MediaQuery.of(context).size.width,
                                )
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        label: const Text('Esquerda'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _hCtrl.hasClients
                            ? () => _scrollToBlock(_currentBlock)
                            : null,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Centro'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _hCtrl.hasClients
                            ? () => _scrollByViewport(
                                  toRight: true,
                                  viewportWidth:
                                      MediaQuery.of(context).size.width,
                                )
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        label: const Text('Direita'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // remove glow/borracha nas bordas
  }
}
// Ícones simplificados: sem desenho customizado de poltrona.

// ===== CSV helpers =====
String buildCsvHeader() =>
    'DataHora,Reuniao,Indicadores,Ocupados,EmPe,Total,PorFileiraOcupados,PorFileiraCapacidade,Notas';

String _csvEscape(String s) => '"${s.replaceAll('"', '\\"')}"';

String _buildCsvRow(_Record r, DateFormat df) {
  return [
    df.format(r.dateTime),
    _csvEscape(r.meetingType),
    _csvEscape(r.indicators.join('; ')),
    r.occupied.toString(),
    r.standing.toString(),
    r.total.toString(),
    _csvEscape(r.perBlockOccupied.join('; ')),
    _csvEscape(r.perBlockCapacity.join('; ')),
    _csvEscape((r.notes ?? '')),
  ].join(',');
}

// Public helper for tests: build CSV row from raw values
String buildCsvRowFromValues({
  required DateTime dateTime,
  required String meetingType,
  required List<String> indicators,
  required int occupied,
  required int standing,
  required List<int> perBlockOccupied,
  required List<int> perBlockCapacity,
  String? notes,
  DateFormat? dateFormat,
}) {
  final df = dateFormat ?? DateFormat('dd/MM/yyyy HH:mm');
  final total = occupied + standing;
  return [
    df.format(dateTime),
    _csvEscape(meetingType),
    _csvEscape(indicators.join('; ')),
    '$occupied',
    '$standing',
    '$total',
    _csvEscape(perBlockOccupied.join('; ')),
    _csvEscape(perBlockCapacity.join('; ')),
    _csvEscape((notes ?? '')),
  ].join(',');
}

String _buildCsvAll(List<_Record> list, DateFormat df) {
  final rows = list.map((r) => _buildCsvRow(r, df)).join('\n');
  return '${buildCsvHeader()}\n$rows';
}

// Public wrapper to montar CSV a partir de lista interna de registros
// sem expor o tipo privado _Record.
String buildCsvAllFromInternalRecords(List records, DateFormat df) {
  final rows = records.map((r) => _buildCsvRow(r as _Record, df)).join('\n');
  return '${buildCsvHeader()}\n$rows';
}

Future<Directory> _preferredSaveDir() async {
  try {
    if (Platform.isAndroid) {
      final dirs = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      if (dirs != null && dirs.isNotEmpty) {
        return dirs.first;
      }
      final fallback = await getExternalStorageDirectory();
      if (fallback != null) return fallback;
    }
  } catch (_) {}
  return await getApplicationDocumentsDirectory();
}

Future<File> saveCsvToFile(String csv, String baseName) async {
  final dir = await _preferredSaveDir();
  final file = File('${dir.path}/$baseName');
  await file.writeAsString(csv);
  return file;
}

// ===== Attendance card image (PNG/JPG) =====
Future<Uint8List> _buildAttendanceCardPng(_Record r) async {
  const double width = 1200;
  const double height = 800;
  const double pad = 48;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
  // Background
  final bg = Paint()..color = const ui.Color(0xFF121212);
  canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bg);

  // Helper to draw text
  void drawText(
    String text,
    double x,
    double y, {
    double size = 36,
    ui.Color color = const ui.Color(0xFFFFFFFF),
    ui.FontWeight fontWeight = ui.FontWeight.w400,
  }) {
    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(fontSize: size, fontWeight: fontWeight),
    );
    pb.pushStyle(ui.TextStyle(color: color));
    pb.addText(text);
    final paragraph = pb.build();
    paragraph.layout(const ui.ParagraphConstraints(width: width - pad * 2));
    canvas.drawParagraph(paragraph, Offset(x, y));
  }

  // Header and info
  drawText(
    'Cartão de Assistência',
    pad,
    pad,
    size: 42,
    fontWeight: ui.FontWeight.w600,
  );
  drawText('Reunião: ${r.meetingType}', pad, pad + 70);
  final df = DateFormat('dd/MM/yyyy HH:mm');
  drawText('Data/Hora: ${df.format(r.dateTime)}', pad, pad + 120);

  // Total highlighted
  drawText(
    'TOTAL DE ASSISTÊNCIA',
    pad,
    pad + 210,
    size: 40,
    fontWeight: ui.FontWeight.w700,
  );
  drawText(
    r.total.toString(),
    pad,
    pad + 270,
    size: 120,
    fontWeight: ui.FontWeight.w800,
    color: const ui.Color(0xFFBB86FC),
  );

  // Details
  drawText('Sentados: ${r.occupied}', pad, pad + 420, size: 32);
  drawText('Em pé: ${r.standing}', pad, pad + 465, size: 32);

  final pairs = (r.perBlockOccupied.isNotEmpty)
      ? List.generate(r.perBlockOccupied.length, (i) {
          final cap = (i < r.perBlockCapacity.length)
              ? r.perBlockCapacity[i]
              : 0;
          return '${r.perBlockOccupied[i]}/$cap';
        }).join(', ')
      : '—';
  drawText(
    'Por fileira (ocupados/capacidade): $pairs',
    pad,
    pad + 520,
    size: 28,
    color: const ui.Color(0xFFB0B0B0),
  );

  if ((r.notes ?? '').trim().isNotEmpty) {
    drawText(
      'Notas: ${r.notes}',
      pad,
      pad + 570,
      size: 26,
      color: const ui.Color(0xFFB0B0B0),
    );
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(width.toInt(), height.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<Uint8List> pngToJpg(Uint8List pngBytes, {int quality = 90}) async {
  final src = img.decodePng(pngBytes);
  if (src == null) return pngBytes;
  final jpg = img.encodeJpg(src, quality: quality);
  return Uint8List.fromList(jpg);
}

Future<File> saveBytes(Uint8List bytes, String baseName) async {
  final dir = await _preferredSaveDir();
  final file = File('${dir.path}/$baseName');
  await file.writeAsBytes(bytes);
  return file;
}

class _AuditoriumsScreen extends StatefulWidget {
  const _AuditoriumsScreen({
    super.key,
    required this.blockSizes,
    required this.rowGroupSteps,
    required this.fillTotals,
    required this.onApply,
    required this.onSaveOrganization,
    this.onToggleTheme,
    required this.alertThreshold,
    required this.useTertiaryTotalBadge,
    required this.onUpdatePrefs,
  });
  final List<int> blockSizes;
  final List<int> rowGroupSteps;
  final List<int> fillTotals;
  final void Function({
    List<int>? newBlockSizes,
    List<int>? newRowGroupSteps,
    List<int>? newFillTotals,
    bool goToCount,
  })
  onApply;
  final void Function({
    List<int>? newBlockSizes,
    List<int>? newRowGroupSteps,
    List<int>? newFillTotals,
  })
  onSaveOrganization;
  final VoidCallback? onToggleTheme;
  final int alertThreshold;
  final bool useTertiaryTotalBadge;
  final void Function({int? newAlertThreshold, bool? newUseTertiaryTotalBadge})
  onUpdatePrefs;

  @override
  State<_AuditoriumsScreen> createState() => _AuditoriumsScreenState();
}

class _AuditoriumsScreenState extends State<_AuditoriumsScreen> {
  late final List<TextEditingController> _blockCtrls;
  late List<int> _rowGroupSteps; // N em N por fileira
  late TextEditingController _thresholdCtrl;
  late bool _prefUseTertiary;
  bool _isBusy = false;
  double _progress = 0.0;
  String _busyLabel = '';
  IconData _busyIcon = Icons.sync;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _blockCtrls = widget.blockSizes
        .map((e) => TextEditingController(text: e.toString()))
        .toList();
    // Inicializa passos por fileira a partir do estado do shell, preservando defaults
    _rowGroupSteps = List<int>.generate(
      widget.blockSizes.length,
      (i) => i < widget.rowGroupSteps.length
          ? (widget.rowGroupSteps[i] <= 0 ? 1 : widget.rowGroupSteps[i])
          : 1,
    );
    _thresholdCtrl = TextEditingController(
      text: widget.alertThreshold.toString(),
    );
    _prefUseTertiary = widget.useTertiaryTotalBadge;
  }

  @override
  void didUpdateWidget(covariant _AuditoriumsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sincroniza controles quando o estado vindo do shell mudar
    final currentSizes = _blockCtrls
        .map((c) => int.tryParse(c.text) ?? 0)
        .toList();
    final newSizes = widget.blockSizes;
    bool sizesChanged = currentSizes.length != newSizes.length;
    if (!sizesChanged) {
      for (int i = 0; i < newSizes.length; i++) {
        if (currentSizes[i] != newSizes[i]) {
          sizesChanged = true;
          break;
        }
      }
    }
    if (sizesChanged) {
      for (final c in _blockCtrls) {
        c.dispose();
      }
      _blockCtrls = newSizes
          .map((e) => TextEditingController(text: e.toString()))
          .toList();
      setState(() {});
    }

    // Atualiza passos por fileira
    final desiredSteps = List<int>.generate(
      widget.blockSizes.length,
      (i) => i < widget.rowGroupSteps.length
          ? (widget.rowGroupSteps[i] <= 0 ? 1 : widget.rowGroupSteps[i])
          : 1,
    );
    bool stepsChanged = _rowGroupSteps.length != desiredSteps.length;
    if (!stepsChanged) {
      for (int i = 0; i < desiredSteps.length; i++) {
        if (_rowGroupSteps[i] != desiredSteps[i]) {
          stepsChanged = true;
          break;
        }
      }
    }
    if (stepsChanged) {
      setState(() {
        _rowGroupSteps = desiredSteps;
      });
    }

    // Atualiza preferências e limite de alerta
    if (_thresholdCtrl.text != widget.alertThreshold.toString()) {
      _thresholdCtrl.text = widget.alertThreshold.toString();
    }
    if (_prefUseTertiary != widget.useTertiaryTotalBadge) {
      setState(() {
        _prefUseTertiary = widget.useTertiaryTotalBadge;
      });
    }
  }

  @override
  void dispose() {
    for (final c in _blockCtrls) {
      c.dispose();
    }
    _thresholdCtrl.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startOverlay({required String label, IconData icon = Icons.sync}) {
    _progressTimer?.cancel();
    setState(() {
      _isBusy = true;
      _progress = 0;
      _busyLabel = label;
      _busyIcon = icon;
    });
    _progressTimer = Timer.periodic(const Duration(milliseconds: 120), (t) {
      setState(() {
        // Avança lentamente até 92% para parecer responsivo
        _progress = (_progress + 6).clamp(0, 92);
      });
    });
  }

  Future<void> _finishOverlay() async {
    _progressTimer?.cancel();
    setState(() {
      _progress = 100;
    });
    await dart_async.Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() {
      _isBusy = false;
      _progress = 0;
      _busyLabel = '';
    });
  }

  Future<void> _runWithOverlay(
    String label,
    FutureOr<void> Function() action, {
    IconData icon = Icons.sync,
  }) async {
    _startOverlay(label: label, icon: icon);
    try {
      await Future.value(action());
    } finally {
      await _finishOverlay();
    }
  }

  Widget _buildBusyOverlay(BuildContext context) {
    final double? value = (_progress > 0 && _progress < 100)
        ? _progress / 100.0
        : null;
    return Stack(
      children: [
        const ModalBarrier(dismissible: false, color: Color(0x88000000)),
        Center(
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _busyIcon,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  _busyLabel.isEmpty ? 'Processando…' : _busyLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                CircularProgressIndicator(value: value),
                const SizedBox(height: 12),
                SizedBox(
                  width: 220,
                  child: LinearProgressIndicator(value: value),
                ),
                const SizedBox(height: 8),
                Text('${_progress.toInt()}%'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Form(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Configuração do Auditório',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // (Removido) Lista de layouts salvos — substituído por ação única de salvar organização
                    const SizedBox(height: 12),
                    // Preferências movidas para o final da tela
                    const SizedBox(height: 0),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.onToggleTheme != null)
                          IconButton(
                            onPressed: widget.onToggleTheme,
                            icon: const Icon(Icons.brightness_6),
                          ),
                        const SizedBox(width: 12),
                        // Controles para adicionar/remover fileiras (valores)
                        IconButton(
                          tooltip: 'Adicionar fileira',
                          onPressed: () async {
                            await _runWithOverlay('Alterando fileiras', () {
                              setState(() {
                                _blockCtrls.add(
                                  TextEditingController(text: '1'),
                                );
                                _rowGroupSteps.add(1);
                                final newSizes = _blockCtrls
                                    .map((c) => int.tryParse(c.text) ?? 0)
                                    .map((v) => v < 0 ? 0 : v)
                                    .toList();
                                final newRowSteps = List<int>.generate(
                                  newSizes.length,
                                  (i) => i < _rowGroupSteps.length
                                      ? (_rowGroupSteps[i] <= 0
                                            ? 1
                                            : _rowGroupSteps[i])
                                      : 1,
                                );
                                final newFills = List<int>.filled(
                                  newSizes.length,
                                  0,
                                );
                                widget.onApply(
                                  newBlockSizes: newSizes,
                                  newRowGroupSteps: newRowSteps,
                                  newFillTotals: newFills,
                                  goToCount: false,
                                );
                              });
                            }, icon: Icons.view_column);
                          },
                          icon: const Icon(Icons.add),
                        ),
                        IconButton(
                          tooltip: 'Remover última fileira',
                          onPressed: _blockCtrls.length > 1
                              ? () async {
                                  await _runWithOverlay(
                                    'Alterando fileiras',
                                    () {
                                      setState(() {
                                        _blockCtrls.removeLast().dispose();
                                        if (_rowGroupSteps.isNotEmpty) {
                                          _rowGroupSteps.removeLast();
                                        }
                                        final newSizes = _blockCtrls
                                            .map(
                                              (c) => int.tryParse(c.text) ?? 0,
                                            )
                                            .map((v) => v < 0 ? 0 : v)
                                            .toList();
                                        final newRowSteps = List<int>.generate(
                                          newSizes.length,
                                          (i) => i < _rowGroupSteps.length
                                              ? (_rowGroupSteps[i] <= 0
                                                    ? 1
                                                    : _rowGroupSteps[i])
                                              : 1,
                                        );
                                        final newFills = List<int>.filled(
                                          newSizes.length,
                                          0,
                                        );
                                        widget.onApply(
                                          newBlockSizes: newSizes,
                                          newRowGroupSteps: newRowSteps,
                                          newFillTotals: newFills,
                                          goToCount: false,
                                        );
                                      });
                                    },
                                    icon: Icons.view_column,
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        IconButton(
                          tooltip: 'Uniformizar poltronas',
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final ctrl = TextEditingController(text: '100');
                            final ok = await material.showDialog<int?>(
                              context: context,
                              builder: (ctx) => material.AlertDialog(
                                title: const material.Text(
                                  'Uniformizar poltronas por fileira',
                                ),
                                content: material.TextField(
                                  controller: ctrl,
                                  keyboardType: material.TextInputType.number,
                                  decoration: const material.InputDecoration(
                                    labelText: 'Poltronas por fileira',
                                    border: material.OutlineInputBorder(
                                      borderRadius: material.BorderRadius.all(Radius.circular(12)),
                                    ),
                                  ),
                                ),
                                actions: [
                                  material.TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(null),
                                    child: const material.Text('Cancelar'),
                                  ),
                                  material.TextButton(
                                    onPressed: () => Navigator.of(
                                      ctx,
                                    ).pop(int.tryParse(ctrl.text) ?? 0),
                                    child: const material.Text('Aplicar'),
                                  ),
                                ],
                              ),
                            );
                            if (ok != null && ok > 0) {
                              setState(() {
                                for (final c in _blockCtrls) {
                                  c.text = ok.toString();
                                }
                              });
                              messenger.showSnackBar(
                                const material.SnackBar(
                                  content: material.Text('Valores uniformes aplicados'),
                                ),
                              );
                            }
                          },
  icon: const Icon(Icons.view_column),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final i in List<int>.generate(_blockCtrls.length, (k) => k)) ...[
                          SizedBox(
                            width: math.min(360, MediaQuery.of(context).size.width - 48),
                            child: _numberField(
                              'Poltronas na fileira ${i + 1}',
                              _blockCtrls[i],
                              helper:
                                  'Total de poltronas nesta coluna (preenche de cima para baixo).',
                            ),
                          ),
                          SizedBox(
                            width: math.min(360, MediaQuery.of(context).size.width - 48),
                            child: DropdownButtonFormField<int>(
                              initialValue: i < _rowGroupSteps.length
                                  ? _rowGroupSteps[i]
                                  : 1,
                              items: () {
                                final current = i < _rowGroupSteps.length
                                    ? _rowGroupSteps[i]
                                    : 1;
                                final base = List<int>.generate(
                                  10,
                                  (k) => k + 1,
                                );
                                final opts = <DropdownMenuItem<int>>[
                                  for (final v in base)
                                    DropdownMenuItem(
                                      value: v,
                                      child: Text('Agrupar em $v'),
                                    ),
                                ];
                                if (current > 10) {
                                  opts.add(
                                    DropdownMenuItem(
                                      value: current,
                                      child: Text('Agrupar em $current'),
                                    ),
                                  );
                                }
                                opts.add(
                                  const DropdownMenuItem(
                                    value: -1,
                                    child: Text('Personalizado…'),
                                  ),
                                );
                                return opts;
                              }(),
                              onChanged: (v) async {
                                final messenger = ScaffoldMessenger.of(context);
                                if (v == null) return;
                                if (v == -1) {
                                  // Solicita valor personalizado
                                  final ctrl = TextEditingController(
                                    text:
                                        (i < _rowGroupSteps.length
                                                ? _rowGroupSteps[i]
                                                : 1)
                                            .toString(),
                                  );
                                  final custom = await material.showDialog<int?>(
                                    context: context,
                                    builder: (ctx) => material.AlertDialog(
                                      title: material.Text(
                                        'Agrupar na fileira ${i + 1}',
                                      ),
                                      content: material.TextField(
                                        controller: ctrl,
                                        keyboardType: material.TextInputType.number,
                                        decoration: const material.InputDecoration(
                                          labelText: 'N em N por fileira',
                                          border: material.OutlineInputBorder(
                                            borderRadius: material.BorderRadius.all(Radius.circular(12)),
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                      ),
                                      actions: [
                                        material.TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(null),
                                          child: const material.Text('Cancelar'),
                                        ),
                                        material.TextButton(
                                          onPressed: () => Navigator.of(
                                            ctx,
                                          ).pop(int.tryParse(ctrl.text) ?? 0),
                                          child: const material.Text('Aplicar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  if (custom != null && custom > 0) {
                                    setState(() {
                                      _rowGroupSteps[i] = custom;
                                    });
                                  } else if (custom != null && custom <= 0) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        icon: const Icon(Icons.error_outline),
                                        title: const Text('Valor inválido'),
                                        content: const Text(
                                          'O agrupamento deve ser maior que 0.',
                                        ),
                                        actions: [
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                            child: const Text('Entendi'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                } else {
                                  setState(() {
                                    _rowGroupSteps[i] = v;
                                  });
                                }
                                // Autoaplicar alteração de organização para refletir na Contagem
                                final newSizes = _blockCtrls
                                    .map((c) => int.tryParse(c.text) ?? 0)
                                    .map((v2) => v2 < 0 ? 0 : v2)
                                    .toList();
                                final newRowSteps = List<int>.generate(
                                  newSizes.length,
                                  (j) => j < _rowGroupSteps.length
                                      ? (_rowGroupSteps[j] <= 0
                                            ? 1
                                            : _rowGroupSteps[j])
                                      : 1,
                                );
                                final newFills = List<int>.filled(
                                  newSizes.length,
                                  0,
                                );
                                await _runWithOverlay(
                                  'Aplicando organização',
                                  () {
                                    widget.onApply(
                                      newBlockSizes: newSizes,
                                      newRowGroupSteps: newRowSteps,
                                      newFillTotals: newFills,
                                      goToCount: false,
                                    );
                                  },
                                  icon: Icons.tune,
                                );
                                final applied = i < _rowGroupSteps.length
                                    ? _rowGroupSteps[i]
                                    : 1;
                                if (applied > widget.alertThreshold) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Aviso: agrupamento alto ($applied). Verifique se atende o layout.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Organização na fileira ${i + 1}',
                                helperText:
                                    'Selecione 1–10 ou “Personalizado…”',
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                                suffixIcon: IconButton(
                                  tooltip: 'Editar agrupamento',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final ctrl = TextEditingController(
                                      text: (i < _rowGroupSteps.length
                                              ? _rowGroupSteps[i]
                                              : 1)
                                          .toString(),
                                    );
                                    final custom = await material.showDialog<int?>(
                                      context: context,
                                      builder: (ctx) => material.AlertDialog(
                                        title: material.Text(
                                            'Agrupar na fileira ${i + 1}'),
                                        content: material.TextField(
                                          controller: ctrl,
                                          keyboardType: material.TextInputType.number,
                                          decoration: const material.InputDecoration(
                                            labelText: 'N em N por fileira',
                                            border: material.OutlineInputBorder(
                                              borderRadius: material.BorderRadius.all(Radius.circular(12)),
                                            ),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(null),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              ctx,
                                            ).pop(int.tryParse(ctrl.text) ?? 0),
                                            child: const Text('Aplicar'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (custom != null && custom > 0) {
                                      setState(() {
                                        _rowGroupSteps[i] = custom;
                                      });
                                      final newSizes = _blockCtrls
                                          .map((c) => int.tryParse(c.text) ?? 0)
                                          .map((v2) => v2 < 0 ? 0 : v2)
                                          .toList();
                                      final newRowSteps = List<int>.generate(
                                        newSizes.length,
                                        (j) => j < _rowGroupSteps.length
                                            ? (_rowGroupSteps[j] <= 0
                                                  ? 1
                                                  : _rowGroupSteps[j])
                                            : 1,
                                      );
                                      final newFills = List<int>.filled(
                                        newSizes.length,
                                        0,
                                      );
                                      await _runWithOverlay(
                                        'Aplicando organização',
                                        () {
                                          widget.onApply(
                                            newBlockSizes: newSizes,
                                            newRowGroupSteps: newRowSteps,
                                            newFillTotals: newFills,
                                            goToCount: false,
                                          );
                                        },
                                        icon: Icons.tune,
                                      );
                                      if (!context.mounted) return;
                                      if (custom > widget.alertThreshold) {
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Aviso: agrupamento alto ($custom). Verifique se atende o layout.',
                                            ),
                                          ),
                                        );
                                      }
                                    } else if (custom != null && custom <= 0) {
                                      if (!context.mounted) return;
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          icon: const Icon(Icons.error_outline),
                                          title: const Text('Valor inválido'),
                                          content: const Text(
                                            'O agrupamento deve ser maior que 0.',
                                          ),
                                          actions: [
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(),
                                              child: const Text('Entendi'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Botão único centralizado: Salvar organização
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final sizes = _blockCtrls
                              .map((c) => int.tryParse(c.text) ?? 0)
                              .map((v) => v < 0 ? 0 : v)
                              .toList();
                          if (sizes.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Informe ao menos uma fileira',
                                ),
                              ),
                            );
                            return;
                          }
                          final steps = List<int>.generate(
                            sizes.length,
                            (i) => i < _rowGroupSteps.length
                                ? (_rowGroupSteps[i] <= 0
                                      ? 1
                                      : _rowGroupSteps[i])
                                : 1,
                          );
                          final fills = List<int>.filled(sizes.length, 0);
                          await _runWithOverlay('Salvando organização', () {
                            widget.onSaveOrganization(
                              newBlockSizes: sizes,
                              newRowGroupSteps: steps,
                              newFillTotals: fills,
                            );
                          }, icon: Icons.save_outlined);
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Organização salva'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Salvar organização'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 12),
                    const Text('Entendendo a configuração:'),
                    const SizedBox(height: 2),
                    const Text(
                      '- Poltronas na fileira: capacidade de cada fileira (coluna).',
                    ),
                    const Text(
                      '- Corredor vertical: é inserido conforme “N em N” definido em cada fileira.',
                    ),
                    const SizedBox(height: 12),
                    // Preferências de UI e validações (agora no final)
                    Card(
                      elevation: 0,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(
                            alpha:
                                Theme.of(context).brightness == Brightness.dark
                                ? 0.35
                                : 0.22,
                          ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Preferências',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _thresholdCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Teto de alerta do agrupamento',
                                helperText:
                                    'Aviso quando N por fileira excede este valor',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                final t = v?.trim() ?? '';
                                if (t.isEmpty) return 'Informe um número';
                                final n = int.tryParse(t);
                                if (n == null) return 'Apenas dígitos';
                                if (n <= 0) return 'Deve ser maior que 0';
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<bool>(
                              initialValue: _prefUseTertiary,
                              decoration: const InputDecoration(
                                labelText: 'Cor do badge do Total',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: false,
                                  child: Text('Primária'),
                                ),
                                DropdownMenuItem(
                                  value: true,
                                  child: Text('Terciária'),
                                ),
                              ],
                              onChanged: (v) => setState(() {
                                if (v != null) _prefUseTertiary = v;
                              }),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text('Salvar Preferências'),
                                onPressed: () async {
                                  final form = Form.of(context);
                                  if (form.validate()) {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    final th = int.tryParse(
                                      _thresholdCtrl.text.trim(),
                                    );
                                    await _runWithOverlay(
                                      'Salvando preferências',
                                      () {
                                        widget.onUpdatePrefs(
                                          newAlertThreshold: th,
                                          newUseTertiaryTotalBadge:
                                              _prefUseTertiary,
                                        );
                                      },
                                      icon: Icons.save,
                                    );
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Preferências salvas'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ),
          ),
        ),
        _isBusy ? _buildBusyOverlay(context) : const SizedBox.shrink(),
      ],
    );
  }

  // Removido: cálculo de grupos globais. Agora usamos N por fileira.

  Widget _numberField(
    String label,
    TextEditingController ctrl, {
    String? helper,
  }) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.next,
      validator: (v) {
        final t = v?.trim() ?? '';
        if (t.isEmpty) return 'Informe um número';
        final n = int.tryParse(t);
        if (n == null) return 'Apenas dígitos';
        if (n <= 0) return 'Deve ser maior que 0';
        return null;
      },
    );
  }
}

class _RecordsFilter {
  final String query;
  final String? meetingType;
  final DateTime? start;
  final DateTime? end;
  final List<String> indicators;
  const _RecordsFilter({
    this.query = '',
    this.meetingType,
    this.start,
    this.end,
    this.indicators = const [],
  });
  _RecordsFilter copyWith({
    String? query,
    String? meetingType,
    DateTime? start,
    DateTime? end,
    List<String>? indicators,
  }) {
    return _RecordsFilter(
      query: query ?? this.query,
      meetingType: meetingType ?? this.meetingType,
      start: start ?? this.start,
      end: end ?? this.end,
      indicators: indicators ?? this.indicators,
    );
  }
}

enum SortColumn { dateTime, meetingType, indicators, occupied, standing, total }

class _SortConfig {
  final SortColumn column;
  final bool ascending;
  const _SortConfig({
    this.column = SortColumn.dateTime,
    this.ascending = false,
  });
}

class _RecordsScreen extends StatefulWidget {
  const _RecordsScreen({
    super.key,
    required this.records,
    this.resetOnShow = false,
    this.onResetConsumed,
  });
  final List<_Record> records;
  final bool resetOnShow;
  final VoidCallback? onResetConsumed;

  @override
  State<_RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<_RecordsScreen> {
  final listBoundaryKey = GlobalKey(debugLabel: 'records_list_boundary');
  final filter = ValueNotifier<_RecordsFilter>(const _RecordsFilter());
  final sort = ValueNotifier<_SortConfig>(const _SortConfig());
  final page = ValueNotifier<int>(0);
  final pageSize = ValueNotifier<int>(5);
  final ScrollController _recordsHCtrl = ScrollController();
  final ScrollController _recordsVCtrl = ScrollController();
  // Debounce e índice de busca em cache (lowercase)
  Timer? _qDebounce;
  List<String> _searchIndexLower = const [];

  @override
  void initState() {
    super.initState();
    _rebuildSearchIndex();
    _loadUIPrefs();
    if (widget.resetOnShow) {
      filter.value = const _RecordsFilter();
      page.value = 0;
      pageSize.value = 5;
      _saveUIPrefs();
      // Evita chamar setState no pai durante o build: agenda pós-frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onResetConsumed?.call();
      });
    }
  }

  @override
  void dispose() {
    filter.dispose();
    sort.dispose();
    page.dispose();
    pageSize.dispose();
    _recordsHCtrl.dispose();
    _recordsVCtrl.dispose();
    _qDebounce?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _RecordsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.records, widget.records) ||
        oldWidget.records.length != widget.records.length) {
      _rebuildSearchIndex();
    }
    if (!oldWidget.resetOnShow && widget.resetOnShow) {
      filter.value = const _RecordsFilter();
      page.value = 0;
      pageSize.value = 5;
      _saveUIPrefs();
      // Agenda consumo do reset após o frame para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onResetConsumed?.call();
      });
    }
  }

  void _rebuildSearchIndex() {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    _searchIndexLower = widget.records.map((r) {
      final base = [
        r.meetingType,
        r.indicators.join(', '),
        r.notes ?? '',
        df.format(r.dateTime),
        r.perBlockOccupied.isNotEmpty ? r.perBlockOccupied.join(',') : '',
      ].join(' ').toLowerCase();
      return base;
    }).toList(growable: false);
  }

  Future<void> _loadUIPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final q = prefs.getString('records.ui.query');
      final mt = prefs.getString('records.ui.meetingType');
      final start = prefs.getString('records.ui.start');
      final end = prefs.getString('records.ui.end');
      final col = prefs.getString('records.ui.sortCol');
      final asc = prefs.getBool('records.ui.sortAsc');
      final pz = prefs.getInt('records.ui.pageSize');
      final pg = prefs.getInt('records.ui.page');
      filter.value = _RecordsFilter(
        query: q ?? '',
        meetingType: (mt == null || mt.isEmpty) ? null : mt,
        start: start != null ? DateTime.tryParse(start) : null,
        end: end != null ? DateTime.tryParse(end) : null,
        indicators: const [],
      );
      sort.value = _SortConfig(
        column: _parseSortColumn(col),
        ascending: asc ?? false,
      );
      pageSize.value = (pz == null || pz <= 0) ? 5 : pz;
      page.value = (pg == null || pg < 0) ? 0 : pg;
    } catch (_) {}
  }

  SortColumn _parseSortColumn(String? name) {
    switch (name) {
      case 'meetingType':
        return SortColumn.meetingType;
      case 'indicators':
        return SortColumn.indicators;
      case 'occupied':
        return SortColumn.occupied;
      case 'standing':
        return SortColumn.standing;
      case 'total':
        return SortColumn.total;
      case 'dateTime':
      default:
        return SortColumn.dateTime;
    }
  }

  Future<void> _saveUIPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final f = filter.value;
      await prefs.setString('records.ui.query', f.query);
      await prefs.setString('records.ui.meetingType', f.meetingType ?? '');
      await prefs.setString(
        'records.ui.start',
        f.start?.toIso8601String() ?? '',
      );
      await prefs.setString('records.ui.end', f.end?.toIso8601String() ?? '');
      await prefs.setString('records.ui.sortCol', sort.value.column.name);
      await prefs.setBool('records.ui.sortAsc', sort.value.ascending);
      await prefs.setInt('records.ui.pageSize', pageSize.value);
      await prefs.setInt('records.ui.page', page.value);
    } catch (_) {}
  }

  Future<void> _persistRecordsFromScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = widget.records.map((r) => r.toJson()).toList();
      await prefs.setString('records.list', jsonEncode(list));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) {
      return const Center(child: Text('Nenhum registro encontrado'));
    }
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final records = widget.records;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder<_RecordsFilter>(
          valueListenable: filter,
          builder: (context, f, _) {
            final q = f.query.trim().toLowerCase();
            // Garante índice atualizado
            if (_searchIndexLower.length != records.length) {
              _rebuildSearchIndex();
            }
            final filtered = <_Record>[];
            for (var i = 0; i < records.length; i++) {
              final r = records[i];
              if (q.isNotEmpty && !_searchIndexLower[i].contains(q)) {
                continue;
              }
              if (f.meetingType != null && f.meetingType!.isNotEmpty) {
                final mts = f.meetingType!
                    .split(',')
                    .map((s) => s.trim().toLowerCase())
                    .where((s) => s.isNotEmpty)
                    .toSet();
                if (mts.isNotEmpty && !mts.contains(r.meetingType.toLowerCase())) {
                  continue;
                }
              }
              if (f.start != null && r.dateTime.isBefore(f.start!)) {
                continue;
              }
              if (f.end != null && r.dateTime.isAfter(f.end!)) {
                continue;
              }
              // Removido: filtro específico por indicadores. A busca geral já
              // considera nomes de indicadores no índice.
              filtered.add(r);
            }
            // Removido: derivação e UI de indicadores como filtros.
            return ValueListenableBuilder<_SortConfig>(
              valueListenable: sort,
              builder: (context, s, _) {
                // Ordenação
                filtered.sort((a, b) {
                  int cmp;
                  switch (s.column) {
                    case SortColumn.dateTime:
                      cmp = a.dateTime.compareTo(b.dateTime);
                      break;
                    case SortColumn.meetingType:
                      cmp = a.meetingType.toLowerCase().compareTo(
                        b.meetingType.toLowerCase(),
                      );
                      break;
                    case SortColumn.indicators:
                      // Mantida ordenação por indicadores (alfabética) sem afetar filtros.
                      cmp = a.indicators
                          .join(', ')
                          .toLowerCase()
                          .compareTo(b.indicators.join(', ').toLowerCase());
                      break;
                    case SortColumn.occupied:
                      cmp = a.occupied.compareTo(b.occupied);
                      break;
                    case SortColumn.standing:
                      cmp = a.standing.compareTo(b.standing);
                      break;
                    case SortColumn.total:
                      cmp = (a.occupied + a.standing).compareTo(
                        b.occupied + b.standing,
                      );
                      break;
                  }
                  return s.ascending ? cmp : -cmp;
                });
                return ValueListenableBuilder<int>(
                  valueListenable: page,
                  builder: (context, pg, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: pageSize,
                      builder: (context, pz, _) {
                        final totalPages = math.max(
                          1,
                          (filtered.length / pz).ceil(),
                        );
                        final safePage = pg.clamp(0, totalPages - 1);
                        if (safePage != pg) page.value = safePage;
                        final start = safePage * pz;
                        final end = math.min(start + pz, filtered.length);
                        final paged = (start < end)
                            ? filtered.sublist(start, end)
                            : <_Record>[];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Cabeçalho rolável (busca, avançado, resumo, ordenação)
                            Flexible(
                              fit: FlexFit.loose,
                              child: SingleChildScrollView(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: math.min(420, MediaQuery.of(context).size.width - 48),
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            labelText: 'Filtrar registros',
                                            hintText: 'Reunião, indicador, data, notas…',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(12)),
                                            ),
                                            prefixIcon: Icon(Icons.search),
                                          ),
                                    onChanged: (v) {
                                      final text = v.trim();
                                      // Ao apagar o nome/termo, aplica imediatamente e volta todos registros
                                      if (text.isEmpty) {
                                        _qDebounce?.cancel();
                                        filter.value = filter.value.copyWith(query: '');
                                        page.value = 0;
                                        _saveUIPrefs();
                                        return;
                                      }
                                      _qDebounce?.cancel();
                                      _qDebounce = Timer(const Duration(milliseconds: 250), () {
                                        filter.value = filter.value.copyWith(query: v);
                                        page.value = 0;
                                        _saveUIPrefs();
                                      });
                                    },
                                    onSubmitted: (v) {
                                      _qDebounce?.cancel();
                                      filter.value = filter.value.copyWith(query: v);
                                      page.value = 0;
                                      _saveUIPrefs();
                                    },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ExpansionTile(
                                      title: const Center(child: Text('Filtros avançados')),
                                      childrenPadding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                      children: [
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          alignment: WrapAlignment.center,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                    SizedBox(
                                      width: math.min(360, MediaQuery.of(context).size.width - 48),
                                      child: FilledButton.tonalIcon(
                                        icon: const Icon(Icons.groups_2),
                                        label: Text(() {
                                          final mt = filter.value.meetingType?.trim() ?? '';
                                          if (mt.isEmpty) return 'Reuniões: Todas';
                                          final sel = mt
                                              .split(',')
                                              .map((s) => s.trim())
                                              .where((s) => s.isNotEmpty)
                                              .toList();
                                          return sel.length == 1
                                              ? 'Reunião: ${sel.first}'
                                              : 'Reuniões: ${sel.length} selecionadas';
                                        }()),
                                        onPressed: () async {
                                          final mt = filter.value.meetingType?.trim() ?? '';
                                          final initial = mt
                                              .split(',')
                                              .map((s) => s.trim())
                                              .where((s) => s.isNotEmpty)
                                              .toSet();
                                          final result = await showDialog<List<String>>(
                                            context: context,
                                            builder: (ctx) {
                                              final selected = initial.toSet();
                                              return StatefulBuilder(
                                                builder: (ctx, setState) {
                                                  return AlertDialog(
                                                    title: const Text('Selecionar reuniões'),
                                                    content: SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          CheckboxListTile(
                                                            value: selected.isEmpty,
                                                            onChanged: (v) {
                                                              setState(() {
                                                                if (v == true) {
                                                                  selected.clear();
                                                                }
                                                              });
                                                            },
                                                            title: const Text('Todas'),
                                                          ),
                                                          const Divider(height: 8),
                                                          for (final t in kMeetingTypes)
                                                            CheckboxListTile(
                                                              value: selected.contains(t),
                                                              onChanged: (v) {
                                                                setState(() {
                                                                  if (v == true) {
                                                                    selected.add(t);
                                                                  } else {
                                                                    selected.remove(t);
                                                                  }
                                                                });
                                                              },
                                                              title: Text(t),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(ctx, null),
                                                        child: const Text('Cancelar'),
                                                      ),
                                                      FilledButton(
                                                        onPressed: () => Navigator.pop(ctx, selected.toList()),
                                                        child: const Text('Aplicar'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                          if (result != null) {
                                            final next = result.where((s) => s.trim().isNotEmpty).toList();
                                            filter.value = filter.value.copyWith(
                                              meetingType: next.isEmpty ? null : next.join(','),
                                            );
                                            page.value = 0;
                                            _saveUIPrefs();
                                          }
                                        },
                                      ),
                                    ),
                                    FilledButton.tonalIcon(
                                      icon: const Icon(Icons.date_range),
                                      label: Text(
                                        filter.value.start == null &&
                                                filter.value.end == null
                                            ? 'Período'
                                            : '${DateFormat('dd/MM/yy').format(filter.value.start!)} — ${DateFormat('dd/MM/yy').format(filter.value.end!)}',
                                      ),
                                      onPressed: () async {
                                        final picked = await showDateRangePicker(
                                          context: context,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2100),
                                        );
                                        if (picked != null) {
                                          final start = DateTime(picked.start.year, picked.start.month, picked.start.day);
                                          final end = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59, 999);
                                          filter.value = filter.value.copyWith(
                                            start: start,
                                            end: end,
                                          );
                                          page.value = 0;
                                          _saveUIPrefs();
                                        }
                                      },
                                    ),
                                    FilledButton.tonalIcon(
                                      icon: const Icon(Icons.event),
                                      label: const Text('Dia'),
                                      onPressed: () async {
                                        final d = await showDatePicker(
                                          context: context,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2100),
                                          initialDate: filter.value.start ?? DateTime.now(),
                                        );
                                        if (d != null) {
                                          final start = DateTime(d.year, d.month, d.day);
                                          final end = DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
                                          filter.value = filter.value.copyWith(start: start, end: end);
                                          page.value = 0;
                                          _saveUIPrefs();
                                        }
                                      },
                                    ),
                                    FilledButton.tonalIcon(
                                      icon: const Icon(Icons.calendar_view_month),
                                      label: const Text('Mês'),
                                      onPressed: () async {
                                        final now = DateTime.now();
                                        final y = now.year;
                                        final m = now.month;
                                        final start = DateTime(y, m, 1);
                                        final end = DateTime(y, m + 1, 1).subtract(const Duration(milliseconds: 1));
                                        filter.value = filter.value.copyWith(start: start, end: end);
                                        page.value = 0;
                                        _saveUIPrefs();
                                      },
                                    ),
                                    FilledButton.tonalIcon(
                                      icon: const Icon(Icons.event_available),
                                      label: const Text('Ano'),
                                      onPressed: () async {
                                        final now = DateTime.now();
                                        final y = now.year;
                                        final start = DateTime(y, 1, 1);
                                        final end = DateTime(y + 1, 1, 1).subtract(const Duration(milliseconds: 1));
                                        filter.value = filter.value.copyWith(start: start, end: end);
                                        page.value = 0;
                                        _saveUIPrefs();
                                      },
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Não atualiza diretamente o campo de texto; apenas o filtro.
                                        filter.value = const _RecordsFilter();
                                        page.value = 0;
                                        _saveUIPrefs();
                                      },
                                      child: const Text('Limpar filtros'),
                                    ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    // Resumo: quantidade de resultados e indicadores ativos
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Chip(
                                          label: Text('Resultados: ${filtered.length}')
                                        ),
                                        if ((filter.value.meetingType?.isNotEmpty ?? false))
                                          Chip(
                                            label: Text(() {
                                              final mt = filter.value.meetingType!.split(',')
                                                  .map((s) => s.trim())
                                                  .where((s) => s.isNotEmpty)
                                                  .toList();
                                              return mt.length == 1
                                                  ? 'Reunião: ${mt.first}'
                                                  : 'Reuniões: ${mt.length}';
                                            }()),
                                          ),
                                      ],
                                    ),
                                    // Ordenação e paginação
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                SizedBox(
                                  width: math.min(360, MediaQuery.of(context).size.width - 48),
                                  child: DropdownButtonFormField<int>(
                                    initialValue: pageSize.value,
                                    items: const [5, 10, 20, 50]
                                        .map(
                                          (n) => DropdownMenuItem(
                                            value: n,
                                            child: Text('$n'),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      pageSize.value = v ?? 5;
                                      page.value = 0;
                                      _saveUIPrefs();
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Itens por página',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: math.min(360, MediaQuery.of(context).size.width - 48),
                                  child: DropdownButtonFormField<SortColumn>(
                                    initialValue: sort.value.column,
                                    items: const [
                                      DropdownMenuItem(
                                        value: SortColumn.dateTime,
                                        child: Text('Data/Hora'),
                                      ),
                                      DropdownMenuItem(
                                        value: SortColumn.meetingType,
                                        child: Text('Reunião'),
                                      ),
                                      DropdownMenuItem(
                                        value: SortColumn.indicators,
                                        child: Text('Indicadores'),
                                      ),
                                      DropdownMenuItem(
                                        value: SortColumn.occupied,
                                        child: Text('Ocupados'),
                                      ),
                                      DropdownMenuItem(
                                        value: SortColumn.standing,
                                        child: Text('Em pé'),
                                      ),
                                      DropdownMenuItem(
                                        value: SortColumn.total,
                                        child: Text('Total'),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      sort.value = _SortConfig(
                                        column: v ?? SortColumn.dateTime,
                                        ascending: sort.value.ascending,
                                      );
                                      page.value = 0;
                                      _saveUIPrefs();
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Ordenar por',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: sort.value.ascending
                                      ? 'Ordem crescente'
                                      : 'Ordem decrescente',
                                  onPressed: () {
                                    sort.value = _SortConfig(
                                      column: sort.value.column,
                                      ascending: !sort.value.ascending,
                                    );
                                    _saveUIPrefs();
                                  },
                                  icon: Icon(
                                    sort.value.ascending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      tooltip: 'Página anterior',
                                      onPressed: safePage > 0
                                          ? () {
                                              page.value = safePage - 1;
                                              _saveUIPrefs();
                                            }
                                          : null,
                                      icon: const Icon(Icons.chevron_left),
                                    ),
                                    Text(
                                      'Página ${safePage + 1} de $totalPages',
                                    ),
                                    IconButton(
                                      tooltip: 'Próxima página',
                                      onPressed: (safePage + 1 < totalPages)
                                          ? () {
                                              page.value = safePage + 1;
                                              _saveUIPrefs();
                                            }
                                          : null,
                                      icon: const Icon(Icons.chevron_right),
                                    ),
                                  ],
                                ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.center,
                              child: PopupMenuButton<int>(
                                tooltip: 'Exportar',
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.file_download),
                                      SizedBox(width: 8),
                                      Text('Exportar'),
                                    ],
                                  ),
                                ),
                                onSelected: (value) async {
                                  if (value == 1) {
                                    final csv = _buildCsvAll(filtered, df);
                                    await Share.share(csv);
                                  } else if (value == 3) {
                                    final boundary =
                                        listBoundaryKey.currentContext
                                                ?.findRenderObject()
                                            as RenderRepaintBoundary?;
                                    if (boundary == null) {
                                      return;
                                    }
                                    final ratio = MediaQuery.of(
                                      context,
                                    ).devicePixelRatio;
                                    final image = await boundary.toImage(
                                      pixelRatio: ratio,
                                    );
                                    final data = await image.toByteData(
                                      format: ui.ImageByteFormat.png,
                                    );
                                    final bytes = data!.buffer.asUint8List();
                                    final name =
                                        'registros_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.png';
                                    final file = await saveBytes(bytes, name);
                                    await Share.shareXFiles([
                                      XFile(file.path, mimeType: 'image/png'),
                                    ], text: 'Registros filtrados');
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem<int>(
                                    value: 1,
                                    child: Row(
                                      children: [
                                        Icon(Icons.table_view),
                                        SizedBox(width: 8),
                                        Text('Exportar CSV (filtrados)'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<int>(
                                    value: 3,
                                    child: Row(
                                      children: [
                                        Icon(Icons.image_outlined),
                                        SizedBox(width: 8),
                                        Text('Exportar PNG (filtrados)'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: RepaintBoundary(
                                key: listBoundaryKey,
                                child: LayoutBuilder(
                                  builder: (ctx, constraints) {
                                    final df = DateFormat('dd/MM/yyyy HH:mm');
                                    if (constraints.maxWidth < 540) {
                                      return Scrollbar(
                                        controller: _recordsVCtrl,
                                        thumbVisibility: true,
                                        child: ListView.separated(
                                          controller: _recordsVCtrl,
                                          itemCount: paged.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 8),
                                          itemBuilder: (_, i) {
                                            final r = paged[i];
                                            final total =
                                                r.occupied + r.standing;
                                            return Card(
                                              elevation: 0,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest
                                                  .withValues(
                                                    alpha:
                                                        Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark
                                                        ? 0.35
                                                        : 0.22,
                                                  ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          df.format(r.dateTime),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Tooltip(
                                                              message:
                                                                  'Editar total',
                                                              child: InkWell(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      20,
                                                                    ),
                                                                onTap: () async {
                                                                  final totalCtrl =
                                                                      TextEditingController(
                                                                        text:
                                                                            '$total',
                                                                      );
                                                                  final ok = await material.showDialog<bool>(
                                                                    context:
                                                                        context,
                                                                    barrierDismissible:
                                                                        true,
                                                                    builder: (ctx) => material.AlertDialog(
                                                                      title: const material.Text(
                                                                        'Editar total',
                                                                      ),
                                                                      content: Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          TextField(
                                                                            controller:
                                                                                totalCtrl,
                                                                            keyboardType:
                                                                                TextInputType.number,
                                                                            decoration: const InputDecoration(
                                                                              labelText: 'Total',
                                                                              border: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () => Navigator.of(ctx).pop(
                                                                            false,
                                                                          ),
                                                                          child: const Text(
                                                                            'Cancelar',
                                                                          ),
                                                                        ),
                                                                        FilledButton.icon(
                                                                          onPressed: () => Navigator.of(ctx).pop(
                                                                            true,
                                                                          ),
                                                                          icon: const Icon(
                                                                            Icons.check,
                                                                          ),
                                                                          label: const Text(
                                                                            'Salvar',
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                  if (!context.mounted) return;
                                                                  if (ok ==
                                                                      true) {
                                                                    final parsed = int.tryParse(
                                                                      totalCtrl
                                                                          .text
                                                                          .trim(),
                                                                    );
                                                                    final newTotal =
                                                                        parsed ==
                                                                                null ||
                                                                            parsed <
                                                                                0
                                                                        ? total
                                                                        : parsed;
                                                                    final globalIndex = widget
                                                                        .records
                                                                        .indexOf(
                                                                          paged[i],
                                                                        );
                                                                    if (globalIndex >=
                                                                        0) {
                                                                      final current =
                                                                          widget
                                                                              .records[globalIndex];
                                                                      final adjustedStanding = current
                                                                          .standing
                                                                          .clamp(
                                                                            0,
                                                                            newTotal,
                                                                          );
                                                                      final adjustedOccupied =
                                                                          newTotal -
                                                                          adjustedStanding;
                                                                      widget
                                                                          .records[globalIndex] = _Record(
                                                                        dateTime:
                                                                            current.dateTime,
                                                                        occupied:
                                                                            adjustedOccupied,
                                                                        standing:
                                                                            adjustedStanding,
                                                                        indicators:
                                                                            current.indicators,
                                                                        meetingType:
                                                                            current.meetingType,
                                                                        notes: current
                                                                            .notes,
                                                                      );

                                                                      final started = DateTime.now();
                                                                      showDialog(
                                                                        context: context,
                                                                        barrierDismissible: false,
                                                                        barrierColor: Colors.black45,
                                                                        builder: (_) => AlertDialog(
                                                                          content: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              LinearProgressIndicator(minHeight: 6.0),
                                                                              SizedBox(height: 12),
                                                                              Text('Salvando alterações...'),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                      await _persistRecordsFromScreen();
                                                                      final elapsed = DateTime.now().difference(started).inMilliseconds;
                                                                      final wait = 800 - elapsed;
                                                                      if (wait > 0) {
            await dart_async.Future.delayed(Duration(milliseconds: wait));
                                                                      }
                                                                      if (context.mounted) {
                                                                        Navigator.of(context, rootNavigator: true).pop();
                                                                      }
                                                                      if (!context
                                                                          .mounted) {
                                                                        return;
                                                                      }
                                                                      final messenger =
                                                                          ScaffoldMessenger.of(
                                                                            context,
                                                                          );
                                                                      final navigator =
                                                                          Navigator.of(
                                                                            context,
                                                                          );
                                                                      messenger.showSnackBar(
                                                                        const SnackBar(
                                                                          content: Text(
                                                                            'Total atualizado',
                                                                          ),
                                                                        ),
                                                                      );
                                                                      dart_async.Future.microtask(() {
                                                                        navigator.popUntil((route) => route.isFirst);
                                                                      });
                                                                    }
                                                                  }
                                                                },
                                                                child: Chip(
                                                                  label: Text(
                                                                    'Total: $total',
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            PopupMenuButton<
                                                              int
                                                            >(
                                                              tooltip:
                                                                  'Mais ações',
                                                              icon: const Icon(
                                                                Icons.more_vert,
                                                              ),
                                                              onSelected: (value) async {
                                                                if (value ==
                                                                    1) {
                                                                  // Editar
                                                                  final meetingCtrl =
                                                                      TextEditingController(
                                                                        text: r
                                                                            .meetingType,
                                                                      );
                                                                  final indicatorsCtrl =
                                                                      TextEditingController(
                                                                        text: r
                                                                            .indicators
                                                                            .join(
                                                                              ', ',
                                                                            ),
                                                                      );
                                                                  final notesCtrl =
                                                                      TextEditingController(
                                                                        text:
                                                                            r.notes ??
                                                                            '',
                                                                      );
                                                                  final totalCtrl =
                                                                      TextEditingController(
                                                                        text:
                                                                            '$total',
                                                                      );
                                                                  final ok = await material.showDialog<bool>(
                                                                    context:
                                                                        context,
                                                                    barrierDismissible:
                                                                        true,
                                                                    builder: (ctx) => AlertDialog(
                                                                      title: const Text(
                                                                        'Editar registro',
                                                                      ),
                                                                      content: SingleChildScrollView(
                                                                        child: Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            TextField(
                                                                              controller: meetingCtrl,
                                                                              decoration: const InputDecoration(
                                                                                labelText: 'Nome da reunião',
                                                                                border: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 12,
                                                                            ),
                                                                            TextField(
                                                                              controller: indicatorsCtrl,
                                                                              decoration: const InputDecoration(
                                                                                labelText: 'Indicadores (separados por vírgula)',
                                                                                border: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 12,
                                                                            ),
                                                                            TextField(
                                                                              controller: totalCtrl,
                                                                              keyboardType: TextInputType.number,
                                                                              decoration: const InputDecoration(
                                                                                labelText: 'Total',
                                                                                border: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 12,
                                                                            ),
                                                                            TextField(
                                                                              controller: notesCtrl,
                                                                              decoration: const InputDecoration(
                                                                                labelText: 'Observações',
                                                                                border: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                                                                ),
                                                                              ),
                                                                              maxLines: 3,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () => Navigator.of(ctx).pop(
                                                                            false,
                                                                          ),
                                                                          child: const Text(
                                                                            'Cancelar',
                                                                          ),
                                                                        ),
                                                                        FilledButton.icon(
                                                                          onPressed: () => Navigator.of(ctx).pop(
                                                                            true,
                                                                          ),
                                                                          icon: const Icon(
                                                                            Icons.check,
                                                                          ),
                                                                          label: const Text(
                                                                            'Salvar',
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                  if (!context.mounted) return;
                                                                  if (ok ==
                                                                      true) {
                                                                    final newMeeting =
                                                                        meetingCtrl
                                                                            .text
                                                                            .trim();
                                                                    final raw =
                                                                        indicatorsCtrl
                                                                            .text
                                                                            .split(
                                                                              ',',
                                                                            );
                                                                    final newIndicators = raw
                                                                        .map(
                                                                          (
                                                                            s,
                                                                          ) => s
                                                                              .trim(),
                                                                        )
                                                                        .where(
                                                                          (
                                                                            s,
                                                                          ) => s
                                                                              .isNotEmpty,
                                                                        )
                                                                        .toList();
                                                                    final newNotes =
                                                                        notesCtrl
                                                                            .text
                                                                            .trim();
                                                                    final parsedTotal = int.tryParse(
                                                                      totalCtrl
                                                                          .text
                                                                          .trim(),
                                                                    );
                                                                    final newTotal =
                                                                        parsedTotal ==
                                                                                null ||
                                                                            parsedTotal <
                                                                                0
                                                                        ? total
                                                                        : parsedTotal;
                                                                    final adjustedStanding = r
                                                                        .standing
                                                                        .clamp(
                                                                          0,
                                                                          newTotal,
                                                                        );
                                                                    final adjustedOccupied =
                                                                        newTotal -
                                                                        adjustedStanding;
                                                                    final globalIndex = widget
                                                                        .records
                                                                        .indexOf(
                                                                          paged[i],
                                                                        );
                                                                    if (globalIndex >=
                                                                        0) {
                                                                      widget
                                                                          .records[globalIndex] = _Record(
                                                                        dateTime:
                                                                            r.dateTime,
                                                                        occupied:
                                                                            adjustedOccupied,
                                                                        standing:
                                                                            adjustedStanding,
                                                                        indicators:
                                                                            newIndicators.isEmpty
                                                                            ? r.indicators
                                                                            : newIndicators,
                                                                        meetingType:
                                                                            newMeeting.isEmpty
                                                                            ? r.meetingType
                                                                            : newMeeting,
                                                                        notes:
                                                                      newNotes.isEmpty
                                                                          ? r.notes
                                                                          : newNotes,
                                                                      );
                                                                      final started = DateTime.now();
                                                                      showDialog(
                                                                        context: context,
                                                                        barrierDismissible: false,
                                                                        barrierColor: Colors.black45,
                                                                        builder: (_) => AlertDialog(
                                                                          content: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              LinearProgressIndicator(minHeight: 6.0),
                                                                              SizedBox(height: 12),
                                                                              Text('Salvando alterações...'),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                      await _persistRecordsFromScreen();
                                                                      final elapsed = DateTime.now().difference(started).inMilliseconds;
                                                                      final wait = 800 - elapsed;
                                                                      if (wait > 0) {
                    await dart_async.Future.delayed(Duration(milliseconds: wait));
                                                                      }
                                                                      if (context.mounted) {
                                                                        Navigator.of(context, rootNavigator: true).pop();
                                                                      }
                                                                      if (!context.mounted) {
                                                                        return;
                                                                      }
                                                                      final messenger = ScaffoldMessenger.of(context);
                                                                      final navigator = Navigator.of(context);
                                                                      messenger.showSnackBar(
                                                                        const SnackBar(
                                                                          content: Text(
                                                                            'Registro atualizado',
                                                                          ),
                                                                        ),
                                                                      );
                                                                      dart_async.Future.microtask(() {
                                                                        navigator.popUntil((route) => route.isFirst);
                                                                      });
                                                                    }
                                                                  }
                                                                } else if (value ==
                                                                    2) {
                                                                  // Excluir
                                                                  final ok = await material.showDialog<bool>(
                                                                    context:
                                                                        context,
                                                                    barrierDismissible:
                                                                        true,
                                                                    builder: (ctx) => material.AlertDialog(
                                                                      title: const material.Text(
                                                                        'Excluir registro',
                                                                      ),
                                                                      content:
                                                                          const material.Text(
                                                                            'Tem certeza que deseja remover este registro?',
                                                                          ),
                                                                      actions: [
                                                                        material.TextButton(
                                                                          onPressed: () => Navigator.of(ctx).pop(
                                                                            false,
                                                                          ),
                                                                          child: const material.Text(
                                                                            'Cancelar',
                                                                          ),
                                                                        ),
                                                                        material.FilledButton.icon(
                                                                          onPressed: () => Navigator.of(ctx).pop(
                                                                            true,
                                                                          ),
      icon: const Icon(
                                                                            Icons.delete_forever,
                                                                          ),
                                                                          label: const material.Text(
                                                                            'Excluir',
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                  if (!context.mounted) return;
                                                                  if (ok ==
                                                                      true) {
                                                                    final globalIndex = widget
                                                                        .records
                                                                        .indexOf(
                                                                          paged[i],
                                                                        );
                                                                    if (globalIndex >=
                                                                        0) {
                                                                      final started = DateTime.now();
                                                                      showDialog(
                                                                        context: context,
                                                                        barrierDismissible: false,
                                                                        barrierColor: Colors.black45,
                                                                        builder: (_) => AlertDialog(
                                                                          content: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              LinearProgressIndicator(minHeight: 6.0),
                                                                              SizedBox(height: 12),
                                                                              Text('Removendo registro...'),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                      widget.records.removeAt(
                                                                        globalIndex,
                                                                      );
                                                                      await _persistRecordsFromScreen();
                                                                      final elapsed = DateTime.now().difference(started).inMilliseconds;
                                                                      final wait = 800 - elapsed;
                                                                      if (wait > 0) {
                    await dart_async.Future.delayed(Duration(milliseconds: wait));
                                                                      }
                                                                      if (context.mounted) {
                                                                        Navigator.of(context, rootNavigator: true).pop();
                                                                      }
                                                                      if (!context.mounted) {
                                                                        return;
                                                                      }
                                                                      final messenger = ScaffoldMessenger.of(context);
                                                                      final navigator = Navigator.of(context);
                                                                      messenger.showSnackBar(
                                                                        const SnackBar(
                                                                          content: Text(
                                                                            'Registro removido',
                                                                          ),
                                                                        ),
                                                                      );
                                                                      dart_async.Future.microtask(() {
                                                                        navigator.popUntil((route) => route.isFirst);
                                                                      });
                                                                    }
                                                                  }
                                                                }
                                                              },
                                                              itemBuilder: (context) => const [
                                                                PopupMenuItem<int>(
                                                                  value: 1,
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons.edit,
                                                                      ),
                                                                      SizedBox(
                                                                        width: 8,
                                                                      ),
                                                                      Text(
                                                                        'Editar',
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                PopupMenuItem<int>(
                                                                  value: 2,
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons.delete,
                                                                      ),
                                                                      SizedBox(
                                                                        width: 8,
                                                                      ),
                                                                      Text(
                                                                        'Excluir',
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                const SizedBox(height: 4),
                Text(
                  'Reunião: ${r.meetingType}',
                ),
                                                    const material.SizedBox(height: 4),
                                                    material.Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: [
                                                        for (final name
                                                            in r.indicators)
                                                          Chip(
                                                            label: Text(name),
                                                          ),
                                                      ],
                                                    ),
                                                    const material.SizedBox(height: 8),
                                                    material.Row(
                                                      children: [
                                                        material.Text(
                                                          'Ocupados: ${r.occupied}',
                                                        ),
                                                        const material.SizedBox(
                                                          width: 16,
                                                        ),
                                                        material.Text(
                                                          'Em pé: ${r.standing}',
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }
                                    return Scrollbar(
                                      controller: _recordsVCtrl,
                                      thumbVisibility: true,
                                      child: SingleChildScrollView(
                                        controller: _recordsHCtrl,
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth: constraints.maxWidth,
                                          ),
                                          child: DataTable(
                                            sortColumnIndex: () {
                                              switch (s.column) {
                                                case SortColumn.dateTime:
                                                  return 0;
                                                case SortColumn.meetingType:
                                                  return 2;
                                                case SortColumn.indicators:
                                                  return 3;
                                                case SortColumn.occupied:
                                                  return 4;
                                                case SortColumn.standing:
                                                  return 5;
                                                case SortColumn.total:
                                                  return 6;
                                              }
                                            }(),
                                            sortAscending: s.ascending,
                                            columnSpacing: 16,
                                            columns: [
                                              DataColumn(
                                                label: const Text('Data/Hora'),
                                                onSort: (_, asc) {
                                                  sort.value = _SortConfig(
                                                    column: SortColumn.dateTime,
                                                    ascending: asc,
                                                  );
                                                  page.value = 0;
                                                  _saveUIPrefs();
                                                },
                                              ),
                                              const DataColumn(
                                                label: Text('Ações'),
                                              ),
                                              DataColumn(
                                                label: const Text('Reunião'),
                                                onSort: (_, asc) {
                                                  sort.value = _SortConfig(
                                                    column:
                                                        SortColumn.meetingType,
                                                    ascending: asc,
                                                  );
                                                  page.value = 0;
                                                  _saveUIPrefs();
                                                },
                                              ),
                                              DataColumn(
                                                label: const Text('Indicadores'),
                                                onSort: (_, asc) {
                                                  sort.value = _SortConfig(
                                                    column: SortColumn.indicators,
                                                    ascending: asc,
                                                  );
                                                  page.value = 0;
                                                  _saveUIPrefs();
                                                },
                                              ),
                                              DataColumn(
                                                label: const Text('Ocupados'),
                                                numeric: true,
                                                onSort: (_, asc) {
                                                  sort.value = _SortConfig(
                                                    column: SortColumn.occupied,
                                                    ascending: asc,
                                                  );
                                                  page.value = 0;
                                                  _saveUIPrefs();
                                                },
                                              ),
                                              DataColumn(
                                                label: const Text('Em pé'),
                                                numeric: true,
                                                onSort: (_, asc) {
                                                  sort.value = _SortConfig(
                                                    column: SortColumn.standing,
                                                    ascending: asc,
                                                  );
                                                  page.value = 0;
                                                  _saveUIPrefs();
                                                },
                                              ),
                                              DataColumn(
                                                label: const Text('Total'),
                                                numeric: true,
                                                onSort: (_, asc) {
                                                  sort.value = _SortConfig(
                                                    column: SortColumn.total,
                                                    ascending: asc,
                                                  );
                                                  page.value = 0;
                                                  _saveUIPrefs();
                                                },
                                              ),
                                              const DataColumn(
                                                label: Text('Por fileira'),
                                              ),
                                            ],
                                            rows: List<DataRow>.generate(
                                              paged.length,
                                              (index) => _dataRow(
                                                context,
                                                paged,
                                                index,
                                                df,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showRecordModal(
    List<_Record> records,
    int index,
    DateFormat df,
  ) async {
    final r = records[index];
    final theme = Theme.of(context);
    await material.showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return AlertDialog(
          icon: const Icon(Icons.receipt_long),
          title: const Text('Detalhes do registro'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      material.Text(
                        'Total',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const material.SizedBox(height: 4),
                      material.Text(
                        r.total.toString(),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const material.SizedBox(height: 4),
                      material.Text('Ocupados: ${r.occupied}    Em pé: ${r.standing}'),
                    ],
                  ),
                ),
                const material.SizedBox(height: 12),
                material.ListTile(
      leading: const Icon(Icons.calendar_today),
                  title: material.Text(df.format(r.dateTime)),
                ),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(r.meetingType),
                ),
                ListTile(
                  leading: const Icon(Icons.sell),
                  title: Text(r.indicators.join(', ')),
                ),
                if (r.perBlockOccupied.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.view_column),
                    title: Text(
                      List.generate(r.perBlockOccupied.length, (i) {
                        final cap = (i < r.perBlockCapacity.length)
                            ? r.perBlockCapacity[i]
                            : 0;
                        return '${r.perBlockOccupied[i]}/$cap';
                      }).join(', '),
                    ),
                  ),
                if ((r.notes ?? '').isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.notes),
                    title: Text(r.notes!),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // _withProgress removido por não ser utilizado (limpeza)

  DataRow _dataRow(
    BuildContext context,
    List<_Record> records,
    int index,
    DateFormat df,
  ) {
    final r = records[index];
    final pairs = (r.perBlockOccupied.isNotEmpty)
        ? List.generate(r.perBlockOccupied.length, (i) {
            final cap = (i < r.perBlockCapacity.length)
                ? r.perBlockCapacity[i]
                : 0;
            return '${r.perBlockOccupied[i]}/$cap';
          }).join(', ')
        : '—';
    final theme = Theme.of(context);
    return DataRow(
      onSelectChanged: (sel) {
        if (sel == true) _showRecordModal(records, index, df);
      },
      cells: [
        DataCell(
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 6),
              Text(df.format(r.dateTime)),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit),
              onPressed: () async {
                  final meetingCtrl = TextEditingController(
                    text: r.meetingType,
                  );
                  final indicatorsCtrl = TextEditingController(
                    text: r.indicators.join(', '),
                  );
                  final notesCtrl = TextEditingController(text: r.notes ?? '');
                  final formKey = GlobalKey<FormState>();
                  final ok = await material.showDialog<bool>(
                    context: context,
                    barrierDismissible: true,
                    builder: (ctx) => material.AlertDialog(
                      title: const material.Text('Editar registro'),
                      content: material.SingleChildScrollView(
                        child: material.Form(
                          key: formKey,
                          child: material.Column(
                            mainAxisSize: material.MainAxisSize.min,
                            children: [
                              material.TextFormField(
                                controller: meetingCtrl,
                                decoration: const material.InputDecoration(
                                  labelText: 'Nome da reunião',
                                  border: material.OutlineInputBorder(
                                    borderRadius: material.BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                                validator: (v) {
                                  final t = v?.trim() ?? '';
                                  if (t.isEmpty) return 'Informe o nome da reunião';
                                  if (t.length > 60) return 'Máximo de 60 caracteres';
                                  return null;
                                },
                              ),
                              const material.SizedBox(height: 12),
                              material.TextFormField(
                                controller: indicatorsCtrl,
                                decoration: const material.InputDecoration(
                                  labelText:
                                      'Nomes dos indicadores (separados por vírgula)',
                                  border: material.OutlineInputBorder(
                                    borderRadius: material.BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                              ),
                              const material.SizedBox(height: 12),
                              material.TextFormField(
                                controller: notesCtrl,
                                decoration: const material.InputDecoration(
                                  labelText: 'Notas (opcional)',
                                  border: material.OutlineInputBorder(
                                    borderRadius: material.BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                                maxLines: 3,
                                validator: (v) {
                                  final t = v?.trim() ?? '';
                                  if (t.isEmpty) return null;
                                  if (t.length > 200) return 'Máximo de 200 caracteres';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        material.TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const material.Text('Cancelar'),
                        ),
                        material.FilledButton(
                          onPressed: () {
                            final valid = formKey.currentState?.validate() ?? false;
                            if (valid) Navigator.of(ctx).pop(true);
                          },
                          child: const material.Text('Salvar'),
                        ),
                      ],
                    ),
                  );
                  if (!context.mounted) return;
                  if (ok == true) {
                    final newMeeting = meetingCtrl.text.trim();
                    final raw = indicatorsCtrl.text.split(',');
                    final newIndicators = raw
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();
                    final newNotes = notesCtrl.text.trim();
                    records[index] = _Record(
                      dateTime: r.dateTime,
                      occupied: r.occupied,
                      standing: r.standing,
                      indicators: newIndicators.isEmpty
                          ? r.indicators
                          : newIndicators,
                      meetingType: newMeeting.isEmpty
                          ? r.meetingType
                          : newMeeting,
                      notes: newNotes.isEmpty ? r.notes : newNotes,
                    );
                    final started = DateTime.now();
                    material.showDialog(
                      context: context,
                      barrierDismissible: false,
                      barrierColor: Colors.black45,
                      builder: (_) => material.AlertDialog(
                        content: material.Column(
                          mainAxisSize: material.MainAxisSize.min,
                          crossAxisAlignment: material.CrossAxisAlignment.start,
                          children: [
                            const material.LinearProgressIndicator(minHeight: 6.0),
                            const material.SizedBox(height: 12),
                            const material.Text('Salvando alterações...'),
                          ],
                        ),
                      ),
                    );
                    await _persistRecordsFromScreen();
                    final elapsed = DateTime.now().difference(started).inMilliseconds;
                    final wait = 800 - elapsed;
                    if (wait > 0) {
                    await dart_async.Future.delayed(Duration(milliseconds: wait));
                    }
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                    if (!context.mounted) return;
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Registro atualizado')),
                    );
            dart_async.Future.microtask(() {
                      navigator.popUntil((route) => route.isFirst);
                    });
                  }
                },
              ),
              IconButton(
                tooltip: 'Cartão PNG',
                icon: const Icon(Icons.image),
                onPressed: () async {
                  final png = await _buildAttendanceCardPng(r);
                  final name =
                      'cartao_${DateFormat('yyyyMMdd_HHmm').format(r.dateTime)}.png';
                  final file = await saveBytes(png, name);
                  await Share.shareXFiles([
                    XFile(file.path),
                  ], text: 'Cartão de Assistência');
                },
              ),
              IconButton(
                tooltip: 'Exportar relatório',
                icon: const Icon(Icons.upload_file),
                onPressed: () async {
                  final header =
                      'DataHora,Reuniao,Indicadores,Ocupados,EmPe,Total,PorFileiraOcupados,PorFileiraCapacidade,Notas';
                  final row = [
                    df.format(r.dateTime),
                    '"${r.meetingType.replaceAll('"', '\\"')}"',
                    '"${r.indicators.join('; ').replaceAll('"', '\\"')}"',
                    r.occupied.toString(),
                    r.standing.toString(),
                    r.total.toString(),
                    '"${r.perBlockOccupied.join('; ')}"',
                    '"${r.perBlockCapacity.join('; ')}"',
                    '"${(r.notes ?? '').replaceAll('"', '\\"')}"',
                  ].join(',');
                  final csv = '$header\n$row';
                  material.showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const material.Center(child: material.CircularProgressIndicator()),
                  );
                  await dart_async.Future.delayed(const Duration(milliseconds: 300));
                  await Share.share(csv);
                  if (!context.mounted) return;
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
              IconButton(
                tooltip: 'Remover',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final confirm = await material.showDialog<bool>(
                    context: context,
                    barrierDismissible: true,
                    builder: (ctx) => material.AlertDialog(
                      icon: const Icon(Icons.warning_amber),
                      title: const material.Text('Excluir registro?'),
                      content: material.Column(
                        mainAxisSize: material.MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          material.Text('Data: ${df.format(r.dateTime)}'),
                          material.Text('Reunião: ${r.meetingType}'),
                          material.Text(
                            'Total: ${r.total} (Ocupados: ${r.occupied}, Em pé: ${r.standing})',
                          ),
                          if ((r.notes ?? '').isNotEmpty)
                            material.Text('Notas: ${r.notes}'),
                          const material.SizedBox(height: 8),
                          const material.Text('Essa ação não pode ser desfeita.'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton.icon(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          label: const Text('Excluir'),
                        ),
                      ],
                    ),
                  );
                  if (!context.mounted) {
                    return;
                  }
                  if (confirm == true) {
                    final started = DateTime.now();
                    material.showDialog(
                      context: context,
                      barrierDismissible: false,
                      barrierColor: Colors.black45,
                      builder: (_) => material.AlertDialog(
                        content: material.Column(
                          mainAxisSize: material.MainAxisSize.min,
                          crossAxisAlignment: material.CrossAxisAlignment.start,
                          children: [
                            const material.LinearProgressIndicator(minHeight: 6.0),
                            const material.SizedBox(height: 12),
                            const material.Text('Excluindo...'),
                          ],
                        ),
                      ),
                    );
                    records.removeAt(index);
                    await _persistRecordsFromScreen();
                    final elapsed = DateTime.now().difference(started).inMilliseconds;
                    final wait = 800 - elapsed;
                    if (wait > 0) {
                    await dart_async.Future.delayed(Duration(milliseconds: wait));
                    }
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                    if (!context.mounted) {
                      return;
                    }
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Registro removido')),
                    );
            dart_async.Future.microtask(() {
                      navigator.popUntil((route) => route.isFirst);
                    });
                  }
                },
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(Icons.event, size: 16),
              const SizedBox(width: 6),
              Text(r.meetingType),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(Icons.sell, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(r.indicators.join(', '))),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(Icons.groups, size: 16),
              const SizedBox(width: 6),
              Text(r.occupied.toString()),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(Icons.directions_walk, size: 16),
              const SizedBox(width: 6),
              Text(r.standing.toString()),
            ],
          ),
        ),
        DataCell(
          material.Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: material.BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                material.BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: material.Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.summarize, size: 18),
                const SizedBox(width: 6),
                Text(
                  r.total.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(Icons.view_column, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(pairs)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Record {
  final DateTime dateTime;
  final int occupied;
  final int standing;
  final List<String> indicators;
  final String meetingType;
  final String? notes;
  final List<int> perBlockOccupied;
  final List<int> perBlockCapacity;
  _Record({
    required this.dateTime,
    required this.occupied,
    required this.standing,
    required this.indicators,
    required this.meetingType,
    this.notes,
    this.perBlockOccupied = const [],
    this.perBlockCapacity = const [],
  });
  int get total => occupied + standing;

  Map<String, dynamic> toJson() => {
    'dateTime': dateTime.toIso8601String(),
    'occupied': occupied,
    'standing': standing,
    'indicators': indicators,
    'meetingType': meetingType,
    'notes': notes,
    'perBlockOccupied': perBlockOccupied,
    'perBlockCapacity': perBlockCapacity,
  };

  factory _Record.fromJson(Map<String, dynamic> json) => _Record(
    dateTime:
        DateTime.tryParse(json['dateTime']?.toString() ?? '') ?? DateTime.now(),
    occupied: int.tryParse(json['occupied']?.toString() ?? '0') ?? 0,
    standing: int.tryParse(json['standing']?.toString() ?? '0') ?? 0,
    indicators:
        (json['indicators'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    meetingType: json['meetingType']?.toString() ?? '',
    notes: (json['notes']?.toString().isEmpty ?? true)
        ? null
        : json['notes'].toString(),
    perBlockOccupied:
        (json['perBlockOccupied'] as List?)
            ?.map((e) => int.tryParse(e.toString()) ?? 0)
            .toList() ??
        const [],
    perBlockCapacity:
        (json['perBlockCapacity'] as List?)
            ?.map((e) => int.tryParse(e.toString()) ?? 0)
            .toList() ??
        const [],
  );
}

// Classe de layouts salvos removida

class _IndicatorInput extends StatefulWidget {
  const _IndicatorInput({
    required this.onAdd,
    required this.indicators,
    required this.onRemove,
  });
  final ValueChanged<String> onAdd;
  final List<String> indicators;
  final void Function(int index) onRemove;

  @override
  State<_IndicatorInput> createState() => _IndicatorInputState();
}

class _IndicatorInputState extends State<_IndicatorInput> {
  late final TextEditingController _ctrl;
  bool _hoverAdd = false;
  bool _pressAdd = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _add() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    final cap = t[0].toUpperCase() + (t.length > 1 ? t.substring(1) : '');
    widget.onAdd(cap);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextField(
          controller: _ctrl,
                                decoration: InputDecoration(
                                  labelText: 'Adicionar nomes dos indicadores',
                                  hintText: 'Adicionar nomes dos indicadores',
                                  hintStyle: const TextStyle(fontSize: 14),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  suffixIcon: MouseRegion(
              onEnter: (_) => setState(() => _hoverAdd = true),
              onExit: (_) => setState(() => _hoverAdd = false),
              child: GestureDetector(
                onTapDown: (_) => setState(() => _pressAdd = true),
                onTapCancel: () => setState(() => _pressAdd = false),
                onTapUp: (_) => setState(() => _pressAdd = false),
                onTap: _add,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1.4,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _hoverAdd
                          ? [
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.30),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.18),
                            ]
                          : [
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              Theme.of(context).colorScheme.secondaryContainer,
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: Theme.of(context).brightness == Brightness.dark
                              ? 0.35
                              : 0.18,
                        ),
                        blurRadius: _pressAdd ? 3 : 6,
                        offset: _pressAdd
                            ? const Offset(0, 1)
                            : const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add),
                      const SizedBox(width: 6),
                      const Text('Adicionar'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          textAlign: TextAlign.start,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => _add(),
        ),
        const material.SizedBox(height: 8),
        material.Wrap(
          alignment: material.WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < widget.indicators.length; i++)
              material.InputChip(
                label: material.Text(widget.indicators[i]),
                onDeleted: () => widget.onRemove(i),
              ),
          ],
        ),
      ],
    );
  }
}

class _OverflowHint extends StatelessWidget {
  final bool visible;
  final AxisDirection direction;
  final int count;
  const _OverflowHint({
    required this.visible,
    required this.direction,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark
        ? Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
        : Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25);
    final Color fg = Theme.of(context).colorScheme.primary;
    final IconData icon = direction == AxisDirection.left
        ? Icons.keyboard_arrow_left
        : Icons.keyboard_arrow_right;

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 240),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.95, end: 1.05),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        builder: (context, scale, child) =>
            Transform.scale(scale: visible ? scale : 1.0, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              material.BoxShadow(
                color: fg.withValues(alpha: isDark ? 0.28 : 0.18),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: material.TextStyle(color: fg, fontWeight: material.FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
