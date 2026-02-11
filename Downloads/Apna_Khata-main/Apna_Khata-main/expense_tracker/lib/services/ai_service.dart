import 'dart:async'; // Required for handling TimeoutException
import 'dart:convert'; // Required for encoding and decoding JSON data
import 'package:http/http.dart'
    as http; // The core package for making HTTP requests
import 'package:http_parser/http_parser.dart'; // Required for specifying file content types in uploads
import 'package:flutter/foundation.dart'; // Required for debugPrint

/// A dedicated service class to handle all communication with the Python AI backend.
/// This centralizes the network logic, making the UI code cleaner and easier to maintain.
class AiService {
  // --- CONFIGURATION ---
  // IMPORTANT: This is the IP address where your Python Flask server is running.
  // You must update this value every time your computer's local IP address changes.
  final String _baseUrl = 'http://10.177.97.51:5000'; // <-- UPDATE AS NEEDED

  /// Sends a simple text string to the backend for analysis.
  /// Used for both manual text entry and transcribed voice input.
  /// This method calls the high-accuracy hybrid model on the backend.
  Future<Map<String, dynamic>?> processExpenseText(String text) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/process'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: json.encode({'text': text}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint(
          'Failed to process text. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return null;
      }
    } on TimeoutException {
      debugPrint(
        'Error: Text processing timed out. The local server did not respond.',
      );
      return null;
    } on http.ClientException catch (e) {
      debugPrint(
        'Error connecting to AI service for text processing: $e. Is the server running and the IP address correct?',
      );
      return null;
    } catch (e) {
      debugPrint('An unexpected error occurred during text processing: $e');
      return null;
    }
  }

  /// Uploads a receipt image file to the backend for OCR and analysis.
  Future<Map<String, dynamic>?> analyzeReceiptImage(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/process-image-receipt'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'receipt',
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 45),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint(
          "Failed to analyze receipt image. Status: ${response.statusCode}, Body: ${response.body}",
        );
        return null;
      }
    } on TimeoutException {
      debugPrint(
        'Error: Image analysis timed out. The local server did not respond.',
      );
      return null;
    } on http.ClientException catch (e) {
      debugPrint(
        'Error connecting to AI service for image analysis: $e. Is the server running and the IP address correct?',
      );
      return null;
    } catch (e) {
      debugPrint("An unexpected error occurred during image analysis: $e");
      return null;
    }
  }

  // --- NEW METHOD FOR VOICE TRANSCRIPTION ---
  /// Uploads a recorded audio file to the backend to get the transcribed text.
  /// This method ONLY performs Speech-to-Text. The classification happens in a second step.
  Future<String?> transcribeVoiceExpense(String audioPath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/process-voice-expense'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'audio', // This field name must match the key expected by the Flask server
          audioPath,
          contentType: MediaType('audio', 'wav'), // Specify the audio format
        ),
      );

      debugPrint("Uploading voice recording for transcription...");
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      var response = await http.Response.fromStream(streamedResponse);
      debugPrint(
        "Backend responded to transcription request with status: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        // The backend returns a simple JSON: {'transcribed_text': 'the text'}
        // We return just the text string.
        return body['transcribed_text'];
      } else {
        debugPrint("Failed to transcribe voice: ${response.body}");
        return null;
      }
    } on TimeoutException {
      debugPrint('Error: Voice transcription timed out.');
      return null;
    } on http.ClientException catch (e) {
      debugPrint('Error connecting to AI service for voice transcription: $e.');
      return null;
    } catch (e) {
      debugPrint("An unexpected error occurred during voice transcription: $e");
      return null;
    }
  }

  // --- NEW METHOD FOR PDF IMPORT ---
  /// Uploads a PDF file to the backend for analysis.
  Future<Map<String, dynamic>?> analyzePdfReceipt(String pdfPath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/process-pdf-receipt'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'pdf', // Matches the key in app.py
          pdfPath,
          contentType: MediaType('application', 'pdf'),
        ),
      );

      debugPrint("Uploading PDF for analysis...");
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 45),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        debugPrint("PDF analysis successful: ${response.body}");
        return json.decode(response.body);
      } else {
        debugPrint(
          "Failed to analyze PDF. Status: ${response.statusCode}, Body: ${response.body}",
        );
        return null;
      }
    } on TimeoutException {
      debugPrint(
        'Error: PDF analysis timed out. The local server did not respond.',
      );
      return null;
    } on http.ClientException catch (e) {
      debugPrint(
        'Error connecting to AI service for PDF analysis: $e. Is the server running?',
      );
      return null;
    } catch (e) {
      debugPrint("An unexpected error occurred during PDF analysis: $e");
      return null;
    }
  }
}
