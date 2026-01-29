import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class PdfService {
  // 🖨️ Receipt Generate karne ka function
  static Future<void> generateReceipt(Map<String, dynamic> member) async {
    final pdf = pw.Document();

    // 🕒 Aaj ki Date
    final date = DateTime.now().toString().split(' ')[0];

    // 📄 PDF Design (Receipt Layout)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5, // Chhota Size (Receipt jaisa)
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              pw.Header(
                level: 0,
                child: pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text("ATOMIC GYM", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Be The Best Version of You", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 10),
                      pw.Text("OFFICIAL RECEIPT", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              
              pw.SizedBox(height: 20),
              pw.Divider(),

              // --- MEMBER DETAILS ---
              _buildRow("Receipt No:", "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}"),
              _buildRow("Date:", date),
              pw.SizedBox(height: 10),
              
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Column(
                  children: [
                     _buildRow("Member Name:", member['name'] ?? "Unknown"),
                     pw.SizedBox(height: 5),
                     _buildRow("Phone:", member['phone'] ?? "N/A"),
                     pw.SizedBox(height: 5),
                     _buildRow("Plan Type:", member['membership_type'] ?? "Monthly"),
                  ]
                )
              ),

              pw.SizedBox(height: 20),

              // --- PAYMENT INFO ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Total Amount Paid:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Rs. ${member['membership_fee'] ?? '0'}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                ]
              ),

              pw.SizedBox(height: 40),
              pw.Divider(),

              // --- FOOTER ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Thank You!", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text("No Refund Policy", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 80, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 5),
                      pw.Text("Authorized Signature", style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // 🖨️ Print/Share Dialog Open Karo
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Chhota Helper Function (Row Banane ke liye)
  static pw.Widget _buildRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}