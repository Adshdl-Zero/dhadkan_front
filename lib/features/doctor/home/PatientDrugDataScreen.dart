import 'package:dhadkan_front/features/doctor/DoctorButtonsindisplaydata.dart';
import 'package:dhadkan_front/features/patient/home/PatientGraph.dart';
import 'package:dhadkan_front/utils/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dhadkan_front/utils/http/http_client.dart';

// Function to fetch patient drug data using existing HTTP client
Future<List<PatientDrugRecord>> fetchPatientDrugData(
    String patientMobile, String token) async {
  final response = await MyHttpHelper.private_post(
      '/doctor/patient-drug-data/mobile/$patientMobile', {}, token);

  List<PatientDrugRecord> records = List<PatientDrugRecord>.from(
      (response['data'] as List).map((item) => PatientDrugRecord.fromJson(item))
  );

  return records;
}

// Function to fetch patient details
Future<Map<String, dynamic>> fetchPatientDetails(String patientmobile, String token) async {
  try {
    final response = await MyHttpHelper.private_post(
        '/doctor/getinfo/$patientmobile',
        {},
        token
    );

    if (response.containsKey('status') && response['status'] == 'success') {
      return response['data'];
    } else {
      throw Exception(response['message'] ?? 'Failed to fetch patient details');
    }
  } catch (e) {
    throw Exception('Error fetching patient details: $e');
  }
}

// Class to hold patient details
class PatientDetails {
  final String name;
  final String uhid;
  final String age;
  final String gender;
  final String mobile;
  final String disease;

  PatientDetails({
    required this.name,
    required this.uhid,
    required this.age,
    required this.gender,
    required this.mobile,
    required this.disease,
  });

  factory PatientDetails.fromJson(Map<String, dynamic> json) {
    return PatientDetails(
      name: json['name'] ?? 'N/A',
      uhid: json['uhid'] ?? 'N/A',
      age: json['age'] ?? 'N/A',
      gender: json['gender'] ?? 'N/A',
      mobile: json['mobile'] ?? 'N/A',
      disease: json['diagnosis'] == 'Other'
          ? json['customDisease']
          : json['diagnosis'],
    );
  }
}

class PatientDrugDataScreen extends StatefulWidget {
  final String patientMobile;
  final String patientName;
  final String patientId;
  const PatientDrugDataScreen({
    super.key,
    required this.patientMobile,
    required this.patientName,
    required this.patientId,
  });

  @override
  State<PatientDrugDataScreen> createState() => _PatientDrugDataScreenState();
}

class _PatientDrugDataScreenState extends State<PatientDrugDataScreen> {
  String _token = "";
  bool _isLoading = true;
  List<PatientDrugRecord> _drugRecords = [];
  String _errorMessage = '';

  // Add PatientDetails
  PatientDetails? _patientDetails;
  bool _loadingPatientDetails = true;
  String _patientDetailsError = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    String? token = await SecureStorageService.getData('authToken');
    if (mounted) {
      setState(() {
        _token = token ?? '';
      });

      if (_token.isNotEmpty) {
        // Fetch both drug data and patient details
        await Future.wait([
          _fetchPatientDrugData(),
          _fetchPatientDetails(),
        ]);
      } else {
        setState(() {
          _errorMessage = 'Authentication token not found';
          _isLoading = false;
          _loadingPatientDetails = false;
        });
      }
    }
  }

  Future<void> _fetchPatientDrugData() async {
    try {
      final records = await fetchPatientDrugData(
          widget.patientMobile, _token);

      if (mounted) {
        setState(() {
          _drugRecords = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error fetching drug data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // Add method to fetch patient details
  Future<void> _fetchPatientDetails() async {
    try {
      // Note: Using mobile number as ID, adjust if your API needs a different ID
      final detailsData = await fetchPatientDetails(widget.patientMobile, _token);

      if (mounted) {
        setState(() {
          _patientDetails = PatientDetails.fromJson(detailsData);
          _loadingPatientDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _patientDetailsError = 'Error fetching patient details: ${e.toString()}';
          _loadingPatientDetails = false;
        });
      }
    }
  }
  Map<String, dynamic> _generateGraphData() {
    // Initialize empty arrays for each data point
    List<dynamic> sbpValues = [];
    List<dynamic> dbpValues = [];
    List<dynamic> weightValues = [];

    // Iterate through drug records to collect data points
    for (var record in _drugRecords) {
      // Add values if they exist, otherwise add 0
      sbpValues.add(record.sbp ?? 0);
      dbpValues.add(record.dbp ?? 0);
      weightValues.add(record.weight ?? 0);
    }

    sbpValues = sbpValues.reversed.toList();
    dbpValues = dbpValues.reversed.toList();
    weightValues = weightValues.reversed.toList();

    // Return data in format expected by PatientGraph
    return {
      'sbp': sbpValues,
      'dbp': dbpValues,
      'weight': weightValues,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF03045E),
        title: Text(
          'Drug data for ${widget.patientName}',
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold,),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: _buildBody(),
    );
  }

// Map<String, dynamic> _generateEmptyGraphData() {
//   return {
//     'sbp': [0, 0],
//     'dbp': [0, 0],
//     'weight': [0, 0],
//   };
// }

  Map<String, dynamic> _generateEmptyGraphData() {
    return {
      'sbp': [],
      'dbp': [],
      'weight': [],
    };
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = '';
                  });
                  _fetchPatientDrugData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    Map<String, dynamic> graphData = _drugRecords.isNotEmpty
        ? _generateGraphData()
        : _generateEmptyGraphData();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Always show patient details card
        _buildPatientDetailsCard(),


        // Always show graph (with empty data if needed)
        PatientGraph(graphData: graphData),
        SizedBox( height: 10,),
        DoctorButtonsindisplaydata(patientMobile: widget.patientMobile,
                                    patientId: widget.patientId,),
        const SizedBox(height: 16),

        if (_drugRecords.isNotEmpty)
        // Show all drug records
          ...List.generate(_drugRecords.length, (index){
            return _buildDrugRecordCard(_drugRecords[index]);
          })
        // else
        //   // Show a message when no drug records
        //   Container(
        //     margin: const EdgeInsets.only(top: 4),
        //     padding: const EdgeInsets.all(16),
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.circular(16),
        //     ),
        //     child: const Center(
        //       child: Text(
        //         'No drug records found for this patient',
        //         style: TextStyle(fontSize: 16),
        //       ),
        //     ),
        //   ),
      ],
    );
  }


  Widget _buildDrugRecordCard(PatientDrugRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecordHeader(record),
            const SizedBox(height: 10),
            _buildPatientInfo(record),
            _buildDiagnosisAndAbility(record),
            _buildMedicinesTitle(),
            if (record.medicines != null && record.medicines!.isNotEmpty)
              _buildMedicinesList(record.medicines!),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordHeader(PatientDrugRecord record) {
    String dateStr = _formatDate(record.createdAt);
    String timeStr = _formatTime(record.createdAt);

    return Center(
      child: Column(
        children: [
          Text(
            dateStr,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF03045E),
            ),
          ),
          Text(
            timeStr,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo(PatientDrugRecord record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Second row: Status + Weight
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Status', record.status ?? 'Better'),
            _buildInfoRow('Weight', record.weight?.toString() ?? ''),
          ],
        ),

        // Third row: Can walk + Sbp
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoRow('Can walk for 5 min', record.canWalk ?? 'YES'),
            _buildInfoRow('SBP', record.sbp?.toString() ?? ''),
          ],
        ),

        // Fourth row: Can climb + Dbp
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Can climb stairs', record.canClimb ?? 'YES'),
            _buildInfoRow('DBP', record.dbp?.toString() ?? ''),
          ],
        ),
      ],
    );
  }

  Widget _buildDiagnosisAndAbility(PatientDrugRecord record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Diagnosis', (record.diagnosis == 'Other' ? record.otherDiagnosis : record.diagnosis) ?? 'N/A'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: '$label : ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicinesTitle() {
    return const Center(
      child: Text(
        'Medicines',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF03045E),
        ),
      ),
    );
  }

  Widget _buildMedicinesList(List<Medicine> medicines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...medicines.asMap().entries.map((entry) {
          int index = entry.key;
          Medicine medicine = entry.value;
          String label = String.fromCharCode('A'.codeUnitAt(0) + (index % 26));

          return Column(
            children: [
              _buildCollapsibleMedicineItem(medicine, label),
            ],
          );
        }),
      ],
    );
  }


  Widget _buildCollapsibleMedicineItem(Medicine medicine, String label) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          'Medicine $label: ${medicine.name}',
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Format: ${medicine.format ?? 'N/A'}',
                        style: const TextStyle(color: Colors.black)),
                    Text('Dosage: ${medicine.dosage ?? 'N/A'} mg',
                        style: const TextStyle(color: Colors.black)),
                  ],
                ),

                const SizedBox(height: 4),
                Text('Frequency: ${medicine.frequency ?? 'N/A'}',
                    style: const TextStyle(color: Colors.black)),
                const SizedBox(height: 4),
                Text('Company name: ${medicine.companyName ?? 'N/A'}',
                    style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Updated patient details card with fetched data
  Widget _buildPatientDetailsCard() {
    if (_loadingPatientDetails) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20.0),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_patientDetailsError.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Could not load patient details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _patientDetailsError,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadingPatientDetails = true;
                  _patientDetailsError = '';
                });
                _fetchPatientDetails();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/Images/patient2.png'),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientDetailRow('Name', _patientDetails?.name ?? 'N/A'),
                  //_buildPatientDetailRow('UHID', _patientDetails?.uhid ?? 'N/A'),
                  _buildPatientDetailRow('Age', _patientDetails?.age ?? 'N/A'),
                  _buildPatientDetailRow('Gender', _patientDetails?.gender ?? 'N/A'),
                  _buildPatientDetailRow('Phone', _patientDetails?.mobile ?? 'N/A'),
                  _buildPatientDetailRow('Disease', _patientDetails?.disease ?? 'N/A'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      // Parse the original date
      final date = DateTime.parse(dateStr);

      // Convert to IST by adding 5 hours and 30 minutes
      // UTC+5:30 is the offset for Indian Standard Time
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
      // Parse the original date
      final date = DateTime.parse(dateStr);

      // Convert to IST by adding 5 hours and 30 minutes
      final istDate = date.add(const Duration(hours: 5, minutes: 30));

      // Format with IST indication
      return DateFormat('h:mm a').format(istDate).toLowerCase(); // e.g. "12:40 pm IST"
    } catch (e) {
      return dateStr;
    }
  }
}

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