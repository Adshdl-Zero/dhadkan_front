import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:dhadkan_front/utils/device/device_utility.dart';
import 'package:dhadkan_front/utils/http/http_client.dart';
import 'package:dhadkan_front/utils/storage/secure_storage_service.dart';
import 'package:dhadkan_front/features/auth/LandingScreen.dart';
import 'package:dhadkan_front/features/common/TopBar.dart';
import 'package:dhadkan_front/features/patient/home/History.dart';
import 'package:dhadkan_front/features/patient/home/PatientButtons.dart';
import 'package:dhadkan_front/features/patient/home/PatientGraph.dart';

export 'package:dhadkan_front/features/patient/home/PatientHomeScreen.dart' show PatientDrugRecord, Medicine;

//-------------------- Display Widget --------------------
class Display extends StatelessWidget {
  final dynamic data;
  const Display({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data?['name'] ?? 'N/A';
    final uhid = data?['uhid'] ?? 'N/A';
    final mobile = data?['mobile'] ?? 'N/A';
    final doctorMobile = data?['doctorMobile'] ?? 'N/A';
    final diagnosisDisplay = data?['diagnosis']?.toString() ?? 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(children: [
          Text("Name: ", style: MyTextTheme.textTheme.headlineSmall),
          Text(name, style: MyTextTheme.textTheme.bodyMedium),
        ]),
        Row(children: [
          Text("UHID: ", style: MyTextTheme.textTheme.headlineSmall),
          Text(uhid, style: MyTextTheme.textTheme.bodyMedium),
        ]),
        Row(children: [
          Text("Phone: ", style: MyTextTheme.textTheme.headlineSmall),
          Text(mobile, style: MyTextTheme.textTheme.bodyMedium),
        ]),
        Row(children: [
          Text("Doctor Mobile: ", style: MyTextTheme.textTheme.headlineSmall),
          Text(doctorMobile, style: MyTextTheme.textTheme.bodyMedium),
        ]),
        Row(children: [
          Text("Disease: ", style: MyTextTheme.textTheme.headlineSmall),
          Text(diagnosisDisplay, style: MyTextTheme.textTheme.bodyMedium),
        ]),
      ],
    );
  }
}

//-------------------- Heading Widget --------------------
class Heading extends StatefulWidget {
  const Heading({super.key});

  @override
  _HeadingState createState() => _HeadingState();
}

class _HeadingState extends State<Heading> {
  String _token = "";
  Map<String, dynamic> patientDetails = {
    "name": " ",
    "mobile": " ",
    "age": " ",
    "uhid": " ",
    "gender": " ",
    "doctorMobile": " ",
    "diagnosis": " ",
    "id": " ",
    "doctorId": " ", // Add doctorId to store doctor's ID
  };

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  _initialize() async {
    String? token = await SecureStorageService.getData('authToken');
    if (mounted) {
      setState(() {
        _token = token ?? '';
      });
    }

    if (_token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Authentication error. Please login again.")));
      }
      return;
    }

    try {
      Map<String, dynamic> response = await MyHttpHelper.private_post(
          '/auth/get-details', {}, _token);
      if (mounted) {
        if (response['status'] == 'success' && response['data'] != null) {
          print(response['data']);
          setState(() {
            patientDetails = {
              ...response['data'],
              "id": response['data']['id'] ?? " ",
              "doctorId": response['data']['doctorId'] ?? " ", // Store doctorId
            };
          });
        } else if (response['success'] == 'true' || response['success'] == true) {
          setState(() {
            patientDetails = {
              ...response['data'],
              "id": response['data']['id'] ?? " ",
              "doctorId": response['data']['doctorId'] ?? " ",
            };
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to load details: ${response['message'] ?? response['error'] ?? 'Unknown error'}")));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Error loading patient data.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(45),
              ),
              child: ClipOval(
                  child: Image.asset(
                    'assets/Images/patient2.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 60, color: Colors.grey);
                    },
                  )
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Display(data: patientDetails),
            ),
          ],
        ),
      ),
    );
  }
}

//-------------------- Data Model Classes --------------------
class PatientDrugRecord {
  final String? id;
  final String? name;
  final int? age;
  final int? weight;
  final int? sbp;
  final int? dbp;
  final String? diagnosis;
  final String? otherDiagnosis;
  final String? mobile;
  final String? status;
  final String? fillername;
  final String? canWalk;
  final String? canClimb;
  final List<Medicine>? medicines;
  final String? createdBy;
  final String? createdAt;

  PatientDrugRecord(
      this.id,
      this.name,
      this.age,
      this.weight,
      this.sbp,
      this.dbp,
      this.diagnosis,
      this.otherDiagnosis,
      this.mobile,
      this.status,
      this.fillername,
      this.canWalk,
      this.canClimb,
      this.medicines,
      this.createdBy,
      this.createdAt,
      );

  factory PatientDrugRecord.fromJson(Map<String, dynamic> json) {
    return PatientDrugRecord(
      json['_id'],
      json['name'],
      json['age'],
      json['weight'],
      json['sbp'],
      json['dbp'],
      json['diagnosis'],
      json['otherDiagnosis'],
      json['mobile'],
      json['status'],
      json['fillername'],
      json['can_walk'],
      json['can_climb'],
      (json['medicines'] as List<dynamic>?)
          ?.map((e) => Medicine.fromJson(e))
          .toList(),
      json['created_by'],
      json['created_at'],
    );
  }
}

class Medicine {
  final String? name;
  final String? format;
  final String? dosage;
  final String? frequency;
  final String? companyName;

  Medicine({
    this.name,
    this.format,
    this.dosage,
    this.frequency,
    this.companyName,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'],
      format: json['format'],
      dosage: json['dosage'],
      frequency: json['frequency'] == 'Other'
          ? json['customFrequency']
          : json['frequency'],
      companyName: json['company_name'],
    );
  }
}

//-------------------- PatientHome Screen --------------------
class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  _PatientHomeState createState() => _PatientHomeState();
}

Future<void> _logout(BuildContext context) async {
  await SecureStorageService.deleteData('authToken');
  if (Navigator.of(context).canPop()) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LandingScreen()),
          (Route<dynamic> route) => false,
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LandingScreen()),
    );
  }
}

class _PatientHomeState extends State<PatientHome> {
  String _token = "";
  Timer? _timer;
  String patientId = "";
  String doctorId = ""; // Add doctorId variable
  List<PatientDrugRecord> history = [];
  Map<String, dynamic> graphData = {
    'sbp': [],
    'dbp': [],
    'weight': []
  };

  @override
  void initState() {
    super.initState();
    _initializeAndSetupTimer();
  }

  Future<void> _initializeAndSetupTimer() async {
    await _initializeToken();
    if (_token.isNotEmpty) {
      await _fetchPatientDetails();
      _fetchData();
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted) {
          _fetchData();
        } else {
          timer.cancel();
        }
      });
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LandingScreen()),
        );
      }
    }
  }

  Future<void> _initializeToken() async {
    String? token = await SecureStorageService.getData('authToken');
    if (mounted) {
      setState(() {
        _token = token ?? '';
      });
      if (_token.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LandingScreen()),
        );
      }
    }
  }

  Future<void> _fetchPatientDetails() async {
    try {
      Map<String, dynamic> response = await MyHttpHelper.private_post(
          '/auth/get-details', {}, _token);
      if (mounted) {
        if (response['status'] == 'success' && response['data'] != null) {
          setState(() {
            patientId = response['data']['id'] ?? '';
            doctorId = response['data']['doctorId'] ?? ''; // Store doctorId
          });
        } else if (response['success'] == 'true' || response['success'] == true) {
          setState(() {
            patientId = response['data']['id'] ?? '';
            doctorId = response['data']['doctorId'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error fetching patient details: $e');
    }
  }

  Future<void> _fetchData() async {
    if (_token.isEmpty) {
      if (_token.isEmpty && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LandingScreen()),
        );
      }
      return;
    }

    try {
      Map<String, dynamic> response = await MyHttpHelper.private_post(
          '/patient/get-daily-data', {}, _token);
      if (mounted) {
        if (response['success'] == 'true' || response['success'] == true) {
          List<dynamic> patientDrugData = response['data'] ?? [];
          List<PatientDrugRecord> records = patientDrugData
              .map((item) => PatientDrugRecord.fromJson(item))
              .toList();

          setState(() {
            history = records;
            graphData = _generateGraphDataFromRecords(records);
          });
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Map<String, dynamic> _generateGraphDataFromRecords(List<PatientDrugRecord> records) {
    List<dynamic> sbpValues = [];
    List<dynamic> dbpValues = [];
    List<dynamic> weightValues = [];

    for (var record in records) {
      sbpValues.add(record.sbp ?? 0);
      dbpValues.add(record.dbp ?? 0);
      weightValues.add(record.weight ?? 0);
    }

    sbpValues = sbpValues.reversed.toList();
    dbpValues = dbpValues.reversed.toList();
    weightValues = weightValues.reversed.toList();

    return {
      'sbp': sbpValues,
      'dbp': dbpValues,
      'weight': weightValues,
    };
  }

  Map<String, dynamic> _generateEmptyGraphData() {
    return {
      'sbp': [],
      'dbp': [],
      'weight': [],
    };
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      final istDate = date.add(const Duration(hours: 5, minutes: 30));
      final day = istDate.day;
      final month = DateFormat('MMM').format(istDate);
      return '$day${_getDaySuffix(day)} $month';
    } catch (e) {
      return dateStr;
    }
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      final istDate = date.add(const Duration(hours: 5, minutes: 30));
      return DateFormat('h:mm a').format(istDate).toLowerCase();
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> displayGraphData = graphData['sbp']?.isNotEmpty == true ||
        graphData['dbp']?.isNotEmpty == true ||
        graphData['weight']?.isNotEmpty == true
        ? graphData
        : _generateEmptyGraphData();

    return Scaffold(
      appBar: AppBar(
        title: const TopBar(title: "Patient Home"),
        actions: [
          IconButton(
            onPressed: () {
              _logout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Heading(),
              PatientGraph(graphData: displayGraphData),
              const SizedBox(height: 16),
              PatientButtons(patientId: patientId, doctorId: doctorId), // Pass patientId and doctorId (line 497)
              const SizedBox(height: 6),
              const SizedBox(height: 16),
              History(
                history: history,
                formatDate: _formatDate,
                formatTime: _formatTime,
              ),
              const SizedBox(height: 24)
            ],
          ),
        ),
      ),
    );
  }
}