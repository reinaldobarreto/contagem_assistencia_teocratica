import 'dart:io';
import 'package:image/image.dart' as img;

/// Gera uma versão com padding transparente do ícone original
/// para se adequar melhor à zona segura dos adaptive launcher icons.
///
/// - Lê `assets/icon/contagem-assistencia.png`
/// - Cria um canvas maior com fundo transparente
/// - Centraliza o ícone original reduzindo a ocupação para ~66% (safe-zone)
/// - Grava em `assets/icon/contagem-assistencia_padded.png`
void main() {
  const sourcePath = 'assets/icon/contagem-assistencia.png';
  const targetPath = 'assets/icon/contagem-assistencia_padded.png';
  const foregroundPath = 'assets/icon/contagem-assistencia_foreground.png';
  const monoPath = 'assets/icon/contagem-assistencia_monochrome.png';

  final sourceFile = File(sourcePath);
  if (!sourceFile.existsSync()) {
    stderr.writeln('Arquivo não encontrado: $sourcePath');
    exit(1);
  }

  final bytes = sourceFile.readAsBytesSync();
  final sourceImage = img.decodeImage(bytes);
  if (sourceImage == null) {
    stderr.writeln('Falha ao decodificar a imagem PNG: $sourcePath');
    exit(1);
  }

  // Tamanho do canvas alvo: mantemos quadrado para melhor resultado
  final maxSide = sourceImage.width > sourceImage.height
      ? sourceImage.width
      : sourceImage.height;

  // Canvas maior para permitir margem; aqui ampliamos 1.36x e
  // colocamos o conteúdo numa área de ~72% (um pouco maior, para evitar
  // aparência de ícone "pequeno" em alguns launchers).
  // Isso evita cortes por máscaras arredondadas e diferentes fabricantes.
  final canvasSide = (maxSide * 1.36).ceil();
  final canvas = img.Image(width: canvasSide, height: canvasSide);
  // Preencher fundo com roxo para melhor contraste no launcher (Android/iOS)
  // Roxo escolhido: #7B1FA2 (RGB: 123, 31, 162)
  final purple = img.ColorInt8.rgba(123, 31, 162, 255);
  for (var y = 0; y < canvasSide; y++) {
    for (var x = 0; x < canvasSide; x++) {
      img.drawPixel(canvas, x, y, purple);
    }
  }

  // Escalar o ícone para ocupar ~72% do lado do canvas
  final safeFraction = 0.72; // zona segura (ajustada)
  final targetSide = (canvasSide * safeFraction).ceil();

  // Preservar proporção do ícone original e preparar um glifo branco
  img.Image resized;
  if (sourceImage.width >= sourceImage.height) {
    resized = img.copyResize(sourceImage, width: targetSide);
  } else {
    resized = img.copyResize(sourceImage, height: targetSide);
  }

  // Centralizar no canvas com o conteúdo original (mantendo cores)
  final dx = ((canvasSide - resized.width) / 2).round();
  final dy = ((canvasSide - resized.height) / 2).round();
  img.compositeImage(canvas, resized, dstX: dx, dstY: dy, blend: img.BlendMode.alpha);

  // Salvar como PNG
  final outBytes = img.encodePng(canvas);
  File(targetPath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(outBytes);

  stdout.writeln('Ícone padded gerado: $targetPath');

  // Gerar foreground transparente (glifo branco), para adaptive icon Android
  final fgCanvas = img.Image(width: canvasSide, height: canvasSide);
  // Fundo transparente
  for (var y = 0; y < fgCanvas.height; y++) {
    for (var x = 0; x < fgCanvas.width; x++) {
      img.drawPixel(fgCanvas, x, y, img.ColorInt8.rgba(0, 0, 0, 0));
    }
  }
  // Criar versão branca do conteúdo redimensionado
  final whiteResized = img.Image.from(resized);
  for (var y = 0; y < whiteResized.height; y++) {
    for (var x = 0; x < whiteResized.width; x++) {
      final p = whiteResized.getPixel(x, y);
      final a = p != 0 ? 255 : 0;
      if (a > 0) {
        img.drawPixel(whiteResized, x, y, img.ColorInt8.rgba(255, 255, 255, a));
      } else {
        img.drawPixel(whiteResized, x, y, img.ColorInt8.rgba(0, 0, 0, 0));
      }
    }
  }
  // Centralizar o glifo branco em canvas transparente
  img.compositeImage(fgCanvas, whiteResized, dstX: dx, dstY: dy, blend: img.BlendMode.alpha);
  final fgBytes = img.encodePng(fgCanvas);
  File(foregroundPath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(fgBytes);
  stdout.writeln('Foreground transparente gerado: $foregroundPath');

  // Também gerar PNGs para atalhos Android em diferentes densidades
  void _saveShortcutPng(img.Image base, String dir, int size) {
    final scaled = img.copyResize(base, width: size, height: size);
    final bytes = img.encodePng(scaled);
    final path = 'android/app/src/main/res/$dir/shortcut_icon.png';
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);
    stdout.writeln('Shortcut PNG gerado: $path (${size}x$size)');
  }

  void _saveShortcutPngV2(img.Image base, String dir, int size) {
    final scaled = img.copyResize(base, width: size, height: size);
    final bytes = img.encodePng(scaled);
    final path = 'android/app/src/main/res/$dir/shortcut_icon_v2.png';
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);
    stdout.writeln('Shortcut PNG v2 gerado: $path (${size}x$size)');
  }

  _saveShortcutPng(canvas, 'drawable-mdpi', 48);
  _saveShortcutPng(canvas, 'drawable-hdpi', 72);
  _saveShortcutPng(canvas, 'drawable-xhdpi', 96);
  _saveShortcutPng(canvas, 'drawable-xxhdpi', 144);
  _saveShortcutPng(canvas, 'drawable-xxxhdpi', 192);
  // Também em mipmap para maior compatibilidade
  _saveShortcutPng(canvas, 'mipmap-mdpi', 48);
  _saveShortcutPng(canvas, 'mipmap-hdpi', 72);
  _saveShortcutPng(canvas, 'mipmap-xhdpi', 96);
  _saveShortcutPng(canvas, 'mipmap-xxhdpi', 144);
  _saveShortcutPng(canvas, 'mipmap-xxxhdpi', 192);

  // Versão v2 (nome de recurso diferente) para forçar atualização de atalho fixado
  _saveShortcutPngV2(canvas, 'drawable-mdpi', 48);
  _saveShortcutPngV2(canvas, 'drawable-hdpi', 72);
  _saveShortcutPngV2(canvas, 'drawable-xhdpi', 96);
  _saveShortcutPngV2(canvas, 'drawable-xxhdpi', 144);
  _saveShortcutPngV2(canvas, 'drawable-xxxhdpi', 192);
  _saveShortcutPngV2(canvas, 'mipmap-mdpi', 48);
  _saveShortcutPngV2(canvas, 'mipmap-hdpi', 72);
  _saveShortcutPngV2(canvas, 'mipmap-xhdpi', 96);
  _saveShortcutPngV2(canvas, 'mipmap-xxhdpi', 144);
  _saveShortcutPngV2(canvas, 'mipmap-xxxhdpi', 192);

  // Gerar variante monocromática (branco sobre transparente) para Android 13+ themed icons
  final mono = img.Image(width: sourceImage.width, height: sourceImage.height);
  // Fundo transparente
  for (var y = 0; y < mono.height; y++) {
    for (var x = 0; x < mono.width; x++) {
      final p = sourceImage.getPixel(x, y);
      final a = p != 0 ? 255 : 0; // Aproximação: pixel não vazio vira branco opaco
      if (a > 0) {
        final white = img.ColorInt8.rgba(255, 255, 255, a);
        img.drawPixel(mono, x, y, white);
      } else {
        img.drawPixel(mono, x, y, img.ColorInt8.rgba(0, 0, 0, 0));
      }
    }
  }

  final monoBytes = img.encodePng(mono);
  File(monoPath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(monoBytes);
  stdout.writeln('Ícone monocromático gerado: $monoPath');
}