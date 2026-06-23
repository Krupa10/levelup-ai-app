import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResumeService {
  static const String resumeKey = "resume_path";

  static Future<String?> pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf"],
    );

    if (result == null) return null;

    final path = result.files.single.path;

    if (path != null) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(resumeKey, path);
    }

    return path;
  }

  static Future<String?> getResume() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(resumeKey);
  }
}
