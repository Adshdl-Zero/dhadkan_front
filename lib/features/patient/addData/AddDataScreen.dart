import 'package:dhadkan_front/Custom/CustomElevatedButton.dart';
import 'package:dhadkan_front/features/common/TopBar.dart';
import 'package:dhadkan_front/utils/constants/colors.dart';
import 'package:dhadkan_front/utils/device/device_utility.dart';
import 'package:dhadkan_front/utils/http/http_client.dart';
import 'package:dhadkan_front/utils/storage/secure_storage_service.dart';
import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:flutter/material.dart';

class AddData extends StatefulWidget {
  const AddData({super.key});

  @override
  State<AddData> createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  String _token = "";
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController sbpController = TextEditingController();
  final TextEditingController dbpController = TextEditingController();

  final TextEditingController otherDiagnosisController = TextEditingController();

  final TextEditingController otherFrequencyAController = TextEditingController();
  final TextEditingController otherFrequencyBController = TextEditingController();
  final TextEditingController otherFrequencyCController = TextEditingController();
  final TextEditingController otherFrequencyDController = TextEditingController();

  String formatAValue = 'Tablet';
  String formatBValue = 'Tablet';
  String formatCValue = 'Tablet';
  String formatDValue = 'Tablet';

  String frequencyAValue = 'Once a day';
  String frequencyBValue = 'Once a day';
  String frequencyCValue = 'Once a day';
  String frequencyDValue = 'Once a day';

  String? statusValue;
  String? canWalkValue;
  String? canClimbValue;
  String? diagnosisValue;

  final TextEditingController medicineAController = TextEditingController();
  final TextEditingController dosageAController = TextEditingController();
  final TextEditingController genericAController = TextEditingController();
  final TextEditingController companynameAController = TextEditingController();

  final TextEditingController medicineBController = TextEditingController();
  final TextEditingController dosageBController = TextEditingController();
  final TextEditingController genericBController = TextEditingController();
  final TextEditingController companynameBController = TextEditingController();

  final TextEditingController medicineCController = TextEditingController();
  final TextEditingController dosageCController = TextEditingController();
  final TextEditingController genericCController = TextEditingController();
  final TextEditingController companynameCController = TextEditingController();

  final TextEditingController medicineDController = TextEditingController();
  final TextEditingController dosageDController = TextEditingController();
  final TextEditingController genericDController = TextEditingController();
  final TextEditingController companynameDController = TextEditingController();

  final List<String> frequencyOptions = ['Once a day', 'Twice a day', 'Thrice a day', 'Other'];
  final List<String> formatOptions = ['Tablet', 'Syrup'];
  final List<String> statusOptions = ['Same', 'Better', 'Worse'];
  final List<String> yesNoOptions = ['Yes', 'No'];
  final List<String> diagnosisOptions = ['DCM', 'IHD with EF', 'HCM', 'NSAA', 'Other'];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    diagnosisController.dispose();
    otherDiagnosisController.dispose();
    weightController.dispose();
    sbpController.dispose();
    dbpController.dispose();

    otherFrequencyAController.dispose();
    otherFrequencyBController.dispose();
    otherFrequencyCController.dispose();
    otherFrequencyDController.dispose();

    medicineAController.dispose();
    dosageAController.dispose();
    genericAController.dispose();
    companynameAController.dispose();

    medicineBController.dispose();
    dosageBController.dispose();
    genericBController.dispose();
    companynameBController.dispose();

    medicineCController.dispose();
    dosageCController.dispose();
    genericCController.dispose();
    companynameCController.dispose();

    medicineDController.dispose();
    dosageDController.dispose();
    genericDController.dispose();
    companynameDController.dispose();

    super.dispose();
  }

  Future<void> _initialize() async {
    String? token = await SecureStorageService.getData('authToken');
    if (mounted) {
      setState(() {
        _token = token ?? '';
      });
    }
  }

  Future<void> handleSubmit(BuildContext context) async {
    if (diagnosisValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a diagnosis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (diagnosisValue == 'Other' && otherDiagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify a diagnosis for "Other"'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final patientData = {
        'diagnosis': diagnosisValue!,
        'otherDiagnosis': diagnosisValue == 'Other' ? otherDiagnosisController.text.trim() : '',
        'weight': weightController.text,
        'sbp': sbpController.text,
        'dbp': dbpController.text,
        'status': statusValue ?? '',
        'can_walk': canWalkValue ?? '',
        'can_climb': canClimbValue ?? '',
        'medicines': [
          if (medicineAController.text.isNotEmpty)
            {
              'name': medicineAController.text,
              'format': formatAValue,
              'dosage': dosageAController.text,
              'frequency': frequencyAValue,
              if (frequencyAValue == 'Other' && otherFrequencyAController.text.isNotEmpty)
                'customFrequency': otherFrequencyAController.text,
              'generic': genericAController.text,
              'company_name': companynameAController.text,
            },
          if (medicineBController.text.isNotEmpty)
            {
              'name': medicineBController.text,
              'format': formatBValue,
              'dosage': dosageBController.text,
              'frequency': frequencyBValue,
              if (frequencyBValue == 'Other' && otherFrequencyBController.text.isNotEmpty)
                'customFrequency': otherFrequencyBController.text,
              'generic': genericBController.text,
              'company_name': companynameBController.text,
            },
          if (medicineCController.text.isNotEmpty)
            {
              'name': medicineCController.text,
              'format': formatCValue,
              'dosage': dosageCController.text,
              'frequency': frequencyCValue,
              if (frequencyCValue == 'Other' && otherFrequencyCController.text.isNotEmpty)
                'customFrequency': otherFrequencyCController.text,
              'generic': genericCController.text,
              'company_name': companynameCController.text,
            },
          if (medicineDController.text.isNotEmpty)
            {
              'name': medicineDController.text,
              'format': formatDValue,
              'dosage': dosageDController.text,
              'frequency': frequencyDValue,
              if (frequencyDValue == 'Other' && otherFrequencyDController.text.isNotEmpty)
                'customFrequency': otherFrequencyDController.text,
              'generic': genericDController.text,
              'company_name': companynameDController.text,
            },
        ],
      };

      final response = await MyHttpHelper.private_post(
        '/patient/add',
        patientData,
        _token,
      );

      if (response.containsKey('success') && response['success'] == "true") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient data added successfully'),
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to add patient data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MyDeviceUtils.getScreenWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: const TopBar(title: 'Add Data'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildDiagnosisDropdown(
                label: 'Diagnosis',
                value: diagnosisValue,
                onChanged: (value) {
                  setState(() {
                    diagnosisValue = value;
                  });
                },
              ),
              if (diagnosisValue == 'Other')
                Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildTextFormField(
                        label: 'Specify Diagnosis',
                        controller: otherDiagnosisController),
                  ],
                ),
              const SizedBox(height: 20),
              _buildTextFormField(
                  label: 'Weight', controller: weightController),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                        label: 'SBP', controller: sbpController),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextFormField(
                        label: 'DBP', controller: dbpController),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildStatusDropdown(
                label: 'Status',
                value: statusValue,
                onChanged: (value) {
                  setState(() {
                    statusValue = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildYesNoDropdown(
                label: 'Can Walk For 5 Min',
                value: canWalkValue,
                onChanged: (value) {
                  setState(() {
                    canWalkValue = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildYesNoDropdown(
                label: 'Can Climb Stairs',
                value: canClimbValue,
                onChanged: (value) {
                  setState(() {
                    canClimbValue = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildCollapsibleMedicineSection(
                medicineLabel: 'Medicine A',
                nameController: medicineAController,
                formatValue: formatAValue,
                onFormatChanged: (value) {
                  setState(() {
                    formatAValue = value!;
                  });
                },
                dosageController: dosageAController,
                frequencyValue: frequencyAValue,
                onFrequencyChanged: (value) {
                  setState(() {
                    frequencyAValue = value!;
                  });
                },
                otherFrequencyController: otherFrequencyAController,
                genericController: genericAController,
                companyNameController: companynameAController,
              ),
              _buildCollapsibleMedicineSection(
                medicineLabel: 'Medicine B',
                nameController: medicineBController,
                formatValue: formatBValue,
                onFormatChanged: (value) {
                  setState(() {
                    formatBValue = value!;
                  });
                },
                dosageController: dosageBController,
                frequencyValue: frequencyBValue,
                onFrequencyChanged: (value) {
                  setState(() {
                    frequencyBValue = value!;
                  });
                },
                otherFrequencyController: otherFrequencyBController,
                genericController: genericBController,
                companyNameController: companynameBController,
              ),
              _buildCollapsibleMedicineSection(
                medicineLabel: 'Medicine C',
                nameController: medicineCController,
                formatValue: formatCValue,
                onFormatChanged: (value) {
                  setState(() {
                    formatCValue = value!;
                  });
                },
                dosageController: dosageCController,
                frequencyValue: frequencyCValue,
                onFrequencyChanged: (value) {
                  setState(() {
                    frequencyCValue = value!;
                  });
                },
                otherFrequencyController: otherFrequencyCController,
                genericController: genericCController,
                companyNameController: companynameCController,
              ),
              _buildCollapsibleMedicineSection(
                medicineLabel: 'Medicine D',
                nameController: medicineDController,
                formatValue: formatDValue,
                onFormatChanged: (value) {
                  setState(() {
                    formatDValue = value!;
                  });
                },
                dosageController: dosageDController,
                frequencyValue: frequencyDValue,
                onFrequencyChanged: (value) {
                  setState(() {
                    frequencyDValue = value!;
                  });
                },
                otherFrequencyController: otherFrequencyDController,
                genericController: genericDController,
                companyNameController: companynameDController,
              ),
              const SizedBox(height: 30),
              CustomElevatedButton(
                text: "Add Data",
                height: 40,
                onPressed: () => handleSubmit(context),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildFrequencyDropdown({
    required String label,
    required String value,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            labelStyle: const TextStyle(color: Colors.black),
          ),
          style: const TextStyle(color: Colors.black),
          dropdownColor: Colors.white,
          value: value,
          items: frequencyOptions.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFormatDropdown({
    required String label,
    required String value,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            labelStyle: const TextStyle(color: Colors.black),
          ),
          style: const TextStyle(color: Colors.black),
          dropdownColor: Colors.white,
          value: value,
          items: formatOptions.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown({
    required String label,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            labelStyle: const TextStyle(color: Colors.black),
          ),
          style: const TextStyle(color: Colors.black),
          dropdownColor: Colors.white,
          value: value,
          hint: const Text("Select status"),
          items: statusOptions.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildYesNoDropdown({
    required String label,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            labelStyle: const TextStyle(color: Colors.black),
          ),
          style: const TextStyle(color: Colors.black),
          dropdownColor: Colors.white,
          value: value,
          hint: const Text("Select"),
          items: yesNoOptions.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCollapsibleMedicineSection({
    required String medicineLabel,
    required TextEditingController nameController,
    required String formatValue,
    required Function(String?) onFormatChanged,
    required TextEditingController dosageController,
    required String frequencyValue,
    required Function(String?) onFrequencyChanged,
    required TextEditingController otherFrequencyController,
    required TextEditingController genericController,
    required TextEditingController companyNameController,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          '$medicineLabel',
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
        tilePadding: EdgeInsets.zero,
        children: [
          _buildTextFormField(
              label: 'Medicine Name', controller: nameController),
          const SizedBox(height: 20),
          _buildFormatDropdown(
            label: 'Format',
            value: formatValue,
            onChanged: onFormatChanged,
          ),
          const SizedBox(height: 20),
          _buildTextFormField(label: 'Dosage', controller: dosageController),
          const SizedBox(height: 20),
          _buildFrequencyDropdown(
            label: 'Frequency',
            value: frequencyValue,
            onChanged: onFrequencyChanged,
          ),
          if (frequencyValue == 'Other')
            Column(
              children: [
                const SizedBox(height: 20),
                _buildTextFormField(
                    label: 'Custom Frequency',
                    controller: otherFrequencyController),
              ],
            ),
          const SizedBox(height: 20),
          _buildTextFormField(label: 'Generic', controller: genericController),
          const SizedBox(height: 20),
          _buildTextFormField(
              label: 'Company Name', controller: companyNameController),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDiagnosisDropdown({
    required String label,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            labelStyle: const TextStyle(color: Colors.black),
          ),
          style: const TextStyle(color: Colors.black),
          dropdownColor: Colors.white,
          value: value,
          hint: const Text("Select diagnosis"),
          items: diagnosisOptions.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}