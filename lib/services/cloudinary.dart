import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Cloudinary {
  static Future<String> uploadToCloudinary(File imageFile) async {
    const cloudName = "dowmhkair";
    const uploadPreset = "Instapop_upload";

    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final resStr = await response.stream.bytesToString();
    final data = json.decode(resStr);
    return data['secure_url'];
  }
}