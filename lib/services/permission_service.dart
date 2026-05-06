import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {

  /// Request the appropriate storage permission based on Android version.
  Future<bool> requestStoragePermission() async {
    // Android 13+ uses READ_MEDIA_AUDIO instead of READ_EXTERNAL_STORAGE
    if (Platform.isAndroid) {
      // Try READ_MEDIA_AUDIO first (Android 13+)
      var audioStatus = await Permission.audio.status;
      if (audioStatus.isGranted) return true;

      audioStatus = await Permission.audio.request();
      if (audioStatus.isGranted) return true;

      // Fallback for Android < 13: READ_EXTERNAL_STORAGE
      var storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) return true;

      storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) return true;

      if (storageStatus.isPermanentlyDenied || audioStatus.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    }

    return true;
  }

  /// Also called for Android 13+ audio permission — handled above.
  Future<bool> requestAudioPermission() async {
    return requestStoragePermission();
  }

  Future<bool> hasPermissions() async {
    if (!Platform.isAndroid) return true;
    final audio = await Permission.audio.isGranted;
    final storage = await Permission.storage.isGranted;
    return audio || storage;
  }
}
