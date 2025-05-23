import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'UploadReport.dart';
import 'package:dhadkan_front/utils/http/http_client.dart';
import 'package:dhadkan_front/utils/storage/secure_storage_service.dart';
import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:dhadkan_front/utils/theme/theme.dart';
import 'package:dhadkan_front/utils/constants/colors.dart';

// Report class
class Report {
  final String id;
  final String patient;
  final String mobile;
  final String time;
  final Map<String, dynamic> files;
  final bool hasReports;

  Report({
    required this.id,
    required this.patient,
    required this.mobile,
    required this.time,
    required this.files,
    required this.hasReports,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'] ?? '',
      patient: json['patient'] ?? '',
      mobile: json['mobile'] ?? '',
      time: json['time'] ?? '',
      files: json['files'] ?? {},
      hasReports: json['hasReports'] ?? false,
    );
  }
}

// ReportFile class
class ReportFile {
  final String path;
  final String url;
  final String type;
  final String originalname;
  final int size;
  final String uploadedAt;
  final String? reportTime;

  ReportFile({
    required this.path,
    required this.url,
    required this.type,
    required this.originalname,
    required this.size,
    required this.uploadedAt,
    this.reportTime,
  });

  factory ReportFile.fromJson(Map<String, dynamic> json) {
    return ReportFile(
      path: json['path'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? '',
      originalname: json['originalname'] ?? '',
      size: json['size'] ?? 0,
      uploadedAt: json['uploadedAt'] ?? '',
      reportTime: json['reportTime'],
    );
  }
}

class ReportPage extends StatefulWidget {
  final String patientId;

  const ReportPage({Key? key, required this.patientId}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late Future<Report?> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = _fetchReport();
  }

  Future<Report?> _fetchReport() async {
    try {
      print('Fetching report for patient: ${widget.patientId}');
      String? token = await SecureStorageService.getData('authToken');
      if (token == null) {
        print('No auth token found');
        throw Exception('Authentication required. Please login again.');
      }

      final response = await MyHttpHelper.get("/reports/${widget.patientId}", token);

      print('API Response: $response');

      if (response == null) {
        print('Response is null');
        return null;
      }

      if (response['success'] == false) {
        print('API Error: ${response['message']}');
        if (response['message']?.contains('token') == true) {
          throw Exception('Authentication failed. Please login again.');
        }
        throw Exception(response['message'] ?? 'Unknown error');
      }

      if (response['error'] != null) {
        print('API Error: ${response['error']}');
        throw Exception(response['error']);
      }

      if (response['report'] == null) {
        print('No report data in response');
        return null;
      }

      print('Report data found: ${response['report']}');
      return Report.fromJson(response['report']);
    } catch (e) {
      print('Error fetching report: $e');
      throw Exception('Failed to load report: $e');
    }
  }

  void _navigateToUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadReportPage(patientId: widget.patientId),
      ),
    ).then((_) {
      setState(() {
        _reportFuture = _fetchReport();
      });
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _viewFile(String path, String type, String reportName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileViewerScreen(
          filePath: MyHttpHelper.mediaURL + path,
          fileType: type,
          reportName: reportName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1FF), // Changed to match PatientDrugDataScreen
      appBar: AppBar(
        title: Text(
          'Medical Reports',
          style: MyTextTheme.textTheme.titleMedium?.copyWith(
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<Report?>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _reportFuture = _fetchReport();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No reports found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _navigateToUpload,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.data!.hasReports) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No reports uploaded yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _navigateToUpload,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            final report = snapshot.data!;
            final reportTypes = [
              {'key': 'opd_card', 'name': 'OPD Card', 'icon': Icons.badge},
              {'key': 'echo', 'name': 'Echo', 'icon': Icons.favorite},
              {'key': 'ecg', 'name': 'ECG', 'icon': Icons.monitor_heart},
              {'key': 'cardiac_mri', 'name': 'Cardiac MRI', 'icon': Icons.medical_services},
              {'key': 'bnp', 'name': 'BNP', 'icon': Icons.science},
              {'key': 'biopsy', 'name': 'Biopsy', 'icon': Icons.biotech},
              {'key': 'biochemistry_report', 'name': 'Biochemistry Report', 'icon': Icons.analytics},
            ];

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reportTypes.length,
                    itemBuilder: (context, index) {
                      final reportType = reportTypes[index];
                      final fileData = report.files[reportType['key']];

                      if (fileData == null) {
                        return const SizedBox.shrink();
                      }

                      final reportFile = ReportFile.fromJson(fileData);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0, // Remove shadow
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: MyColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  reportType['icon'] as IconData,
                                  color: MyColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reportType['name'] as String,
                                      style: MyTextTheme.textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Uploaded: ${_formatDate(reportFile.uploadedAt)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  _viewFile(reportFile.path, reportFile.type, reportType['name'] as String);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: Text(
                                  'View',
                                  style: MyTextTheme.textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToUpload,
                        icon: const Icon(Icons.refresh),
                        label: Text(
                          'Re-upload Report',
                          style: MyTextTheme.textTheme.titleMedium?.copyWith(
                            fontSize: 15.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

// FileViewerScreen class
class FileViewerScreen extends StatelessWidget {
  final String filePath;
  final String fileType;
  final String reportName;

  const FileViewerScreen({
    Key? key,
    required this.filePath,
    required this.fileType,
    required this.reportName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(reportName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: fileType == 'pdf'
            ? Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'PDF Viewer',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'PDF viewing functionality will be implemented here',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Implement external PDF viewer launch or use a package like flutter_pdfview
                },
                child: const Text('Open PDF'),
              ),
            ],
          ),
        )
            : InteractiveViewer(
          child: Image.network(
            filePath,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}