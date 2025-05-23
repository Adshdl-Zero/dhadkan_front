import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:dhadkan_front/utils/theme/theme.dart';
import 'package:dhadkan_front/utils/constants/colors.dart';
import 'package:dhadkan_front/utils/http/http_client.dart';
import 'package:file_selector/file_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dhadkan_front/utils/storage/secure_storage_service.dart';

class UploadReportPage extends StatefulWidget {
  final String patientId;

  const UploadReportPage({Key? key, required this.patientId}) : super(key: key);

  @override
  _UploadReportPageState createState() => _UploadReportPageState();
}

class _UploadReportPageState extends State<UploadReportPage> {
  final Map<String, File?> _selectedFiles = {
    'opd_card': null,
    'echo': null,
    'ecg': null,
    'cardiac_mri': null,
    'bnp': null,
    'biopsy': null,
    'biochemistry_report': null,
  };

  final Map<String, String> _fieldLabels = {
    'opd_card': 'OPD Card',
    'echo': 'Echo',
    'ecg': 'ECG',
    'cardiac_mri': 'Cardiac MRI',
    'bnp': 'BNP',
    'biopsy': 'Biopsy',
    'biochemistry_report': 'Biochemistry Report',
  };

  bool _isUploading = false;

  Future<String?> _getAuthToken() async {
    try {
      String? token = await SecureStorageService.getData('authToken');
      print('Retrieved token: ${token != null ? "Token exists (${token
          .length} chars)" : "No token found"}');

      // Additional debug: check if token starts with expected format
      if (token != null) {
        print('Token starts with: ${token.substring(
            0, token.length > 20 ? 20 : token.length)}...');
      }

      return token;
    } catch (e) {
      print('Error retrieving auth token: $e');
      return null;
    }
  }

  // Debug function to validate token
  Future<bool> _validateToken(String token) async {
    try {
      // You can add a simple API call to validate the token
      // For now, just check if it's not empty and has reasonable length
      return token.isNotEmpty && token.length > 10;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  Future<void> _pickFiles(String fieldName) async {
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(label: 'Images', extensions: ['jpg', 'jpeg', 'png']),
          XTypeGroup(label: 'PDF', extensions: ['pdf']),
        ],
      );

      if (file != null) {
        setState(() {
          _selectedFiles[fieldName] = File(file.path);
        });
        print('Selected file for $fieldName: ${file.name}');
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }

  Future<void> _uploadFiles() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Enhanced token retrieval and validation
      final authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No authentication token found');
      }

      // Validate token before proceeding
      bool isValidToken = await _validateToken(authToken);
      if (!isValidToken) {
        throw Exception('Invalid authentication token');
      }

      // Convert Map<String, File?> to Map<String, List<File>> for compatibility
      final Map<String, List<File>> filesToUpload = {};
      _selectedFiles.forEach((key, file) {
        if (file != null) {
          filesToUpload[key] = [file];
          print('Adding file for upload - $key: ${file.path
              .split('/')
              .last}');
        }
      });

      if (filesToUpload.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select at least one file to upload',
              style: MyTextTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white),
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      print('Uploading files: ${filesToUpload.keys.toList()}');
      print('Patient ID: ${widget.patientId}');
      print('Auth token length: ${authToken.length}');

      final response = await MyHttpHelper.private_multipart_post(
        '/reports/upload/${widget.patientId}',
        filesToUpload,
        authToken,
        {'patientId': widget.patientId},
      );

      print('Upload response: $response');

      // Check for different response formats
      if (response['statusCode'] == 201 ||
          response['success'] == true ||
          (response.containsKey('success') && response['success'])) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Files uploaded successfully',
              style: MyTextTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white),
            ),
            backgroundColor: MyColors.primary,
          ),
        );
        Navigator.pop(context, true);
      } else if (response['statusCode'] == 401) {
        // Handle 401 specifically
        print('Authentication failed - 401 error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Authentication failed. Please login again.',
              style: MyTextTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );

        // Optionally clear the token and navigate to login
        await SecureStorageService.deleteData('authToken');
        // Navigator.pushReplacementNamed(context, '/login');

      } else {
        // Handle other errors
        if (response['errors'] != null) {
          for (var error in (response['errors'] as List)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  error.toString(),
                  style: MyTextTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          String errorMessage = response['error'] ??
              response['message'] ??
              'Unknown error occurred';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Upload failed: $errorMessage',
                style: MyTextTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to upload files: $e',
            style: MyTextTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Debug: Check token on page load
    _checkTokenOnLoad();
  }

  Future<void> _checkTokenOnLoad() async {
    final token = await _getAuthToken();
    print(
        'Token check on page load: ${token != null ? "Available" : "Missing"}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Medical Reports',
          style: MyTextTheme.textTheme.titleMedium?.copyWith(
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        // actions: [
        //   // Debug button to check token
        //   IconButton(
        //     icon: Icon(Icons.info),
        //     onPressed: () async {
        //       final token = await _getAuthToken();
        //       showDialog(
        //         context: context,
        //         builder: (context) => AlertDialog(
        //           title: Text('Debug Info'),
        //           content: Text('Token: ${token != null ? "Available" : "Missing"}\nPatient ID: ${widget.patientId}'),
        //           actions: [
        //             TextButton(
        //               onPressed: () => Navigator.pop(context),
        //               child: Text('OK'),
        //             ),
        //           ],
        //         ),
        //       );
        //     },
        //   ),
        //],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._selectedFiles.keys.map((field) =>
                _buildFileUploadSection(
                  _fieldLabels[field]!,
                  field,
                  _selectedFiles[field],
                )),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadFiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : Text(
                'Submit Reports',
                style: MyTextTheme.textTheme.titleMedium?.copyWith(
                  fontSize: 15.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadSection(String title, String fieldName, File? file) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0, // Remove shadow
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: MyTextTheme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            if (file == null)
              Text(
                'No file selected',
                style: MyTextTheme.textTheme.bodyMedium,
              )
            else
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(
                  file.path.split('/').last,
                  style: MyTextTheme.textTheme.bodyMedium,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedFiles[fieldName] = null;
                    });
                  },
                ),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _pickFiles(fieldName),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                file == null ? 'Select File' : 'Change File',
                style: MyTextTheme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}