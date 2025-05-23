import 'package:dhadkan_front/features/auth/LandingScreen.dart';
import 'package:dhadkan_front/features/doctor/home/PatientDrugDataScreen.dart';
import 'package:dhadkan_front/features/patient/home/PatientGraph.dart';
import 'package:dhadkan_front/utils/device/device_utility.dart';
import 'package:dhadkan_front/utils/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:dhadkan_front/utils/http/http_client.dart';
import 'package:dhadkan_front/features/common/TopBar.dart';

class AllPatientsPage extends StatefulWidget {
  const AllPatientsPage({super.key});

  @override
  _AllPatientsPageState createState() => _AllPatientsPageState();
}

class _AllPatientsPageState extends State<AllPatientsPage> {
  List<dynamic> data = [];
  bool isLoading = true;
  String _token = "";
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final token = await SecureStorageService.getData('authToken');
      if (token == null || token.isEmpty) {
        _redirectToLanding();
      } else {
        setState(() => _token = token);
        await _fetchPatients();
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Initialization failed";
        isLoading = false;
      });
      // Added for more detailed error logging
      print("Error during initialization: $e");
    }
  }

  void _redirectToLanding() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LandingScreen()),
      );
    });
  }

  Future<void> _fetchPatients() async {
    try {
      setState(() => isLoading = true);
      final response = await MyHttpHelper.private_post(
          '/doctor/allpatient',
          {},
          _token
      );

      if (response['success'] == true || response['success'] == 'true') {
        // Ensure data is always a List and handle potential null 'data' key
        setState(() {
          data = List<dynamic>.from(response['data'] ?? []);
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = response['message']?.toString() ?? "Failed to load patients";
        });
      }
    } catch (e) {
      setState(() => _errorMessage = "Network error occurred");
      print("Error fetching patients: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildPatientCard(Map<String, dynamic> patientData) {
    // Ensure patientData['patient'] is treated as nullable Map<String, dynamic>
    // and default to an empty map if null.
    final patient = patientData['patient'] as Map<String, dynamic>? ?? {};
    final graphData = patientData['graphData'];

    // Line 93, now with an explicit check for the key's existence and then toString()
    final name = (patient.containsKey('name') ? patient['name']?.toString() : null) ?? 'Name not available';
    final mobile = (patient.containsKey('mobile') ? patient['mobile']?.toString() : null) ?? 'Mobile not available';
    final patientId = (patient.containsKey('_id') ? patient['_id']?.toString() : null) ?? '_id not available';
    final uhid = (patient.containsKey('uhid') ? patient['uhid']?.toString() : null) ?? 'UHID not available';

    // print('Patient Name: $name, Type: ${name.runtimeType}');
    // print('Patient Mobile: $mobile, Type: ${mobile.runtimeType}');

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                    Text('UHID:$uhid', style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700])),
                  ],
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _navigateToPatientDetail(mobile, name, patientId),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, // Remove default padding if you want text closer to icon
                      minimumSize: Size.zero, // Remove minimum size constraints
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink hit test area
                      alignment: Alignment.centerRight, // Align content to the right
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Keep row content tight
                      children: const [
                        Text(
                          'More Info',
                          style: TextStyle(fontSize: 14, color: Colors.black54), // Adjust color as needed
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 20, // Adjust icon size to fit text
                          color: Colors.black54, // Adjust color as needed
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          if (graphData != null)
            PatientGraph(graphData: graphData)
          else
            const Text("No health data available",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _navigateToPatientDetail(String mobile, String name, String patientId) async {
    // The parameters are already Non-Nullable Strings due to the ?? operator in _buildPatientCard
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDrugDataScreen(
          patientMobile: mobile,
          patientName: name,
          patientId: patientId,
        ),
      ),
    );
    await _fetchPatients(); // Refresh data after returning
  }

  @override
  Widget build(BuildContext context) {
    final paddingWidth = MyDeviceUtils.getScreenWidth(context) * 0.05;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!), // Use ! only if you're certain it's not null here
            ElevatedButton(
              onPressed: _fetchPatients,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (data.isEmpty) {
      return const Center(child: Text("No patients found"));
    }

    return Scaffold(
      appBar: AppBar(title: const TopBar(title: "All Patients")),
      body: RefreshIndicator(
        onRefresh: _fetchPatients,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingWidth),
          child: ListView(
            children: [
              for (final item in data)
                if (item is Map<String, dynamic>)
                  _buildPatientCard(item)
                else
                // Added print statement for debugging invalid items
                  (() {
                    print('Skipping invalid patient data item: $item');
                    return const SizedBox.shrink();
                  })(),
            ],
          ),
        ),
      ),
    );
  }
}