import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfTextService {
  static String extractText(Uint8List pdfBytes) {
    final document = PdfDocument(inputBytes: pdfBytes);

    try {
      final extractedText =
          PdfTextExtractor(document).extractText();

      return extractedText;
    } finally {
      document.dispose();
    }
  }
}