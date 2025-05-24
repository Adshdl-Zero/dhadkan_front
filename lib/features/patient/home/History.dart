import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:dhadkan_front/utils/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dhadkan_front/features/patient/home/PatientHomeScreen.dart';

class History extends StatefulWidget {
  final List<PatientDrugRecord> history;
  final String Function(String?) formatDate;
  final String Function(String?) formatTime;

  const History({
    super.key,
    required this.history,
    required this.formatDate,
    required this.formatTime,
  });

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text(
            'No history records found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: [
        ...widget.history.map((record) => _buildHistoryCard(record)),
      ],
    );
  }

  Widget _buildHistoryCard(PatientDrugRecord record) {
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
            const SizedBox(height: 16),
            _buildPatientInfo(record), // This now includes diagnosis if it exists
            if (record.medicines != null && record.medicines!.isNotEmpty)
              _buildMedicinesSection(record.medicines!),
          ],
        ),
      ),
    );
  }


  Widget _buildRecordHeader(PatientDrugRecord record) {
    String dateStr = widget.formatDate(record.createdAt);
    String timeStr = widget.formatTime(record.createdAt);

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
        // First row: Status + Weight
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Status', record.status ?? 'Better'),
            _buildInfoRow('Weight', record.weight?.toString() ?? 'N/A'),
          ],
        ),

        // Second row: Can walk + SBP
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoRow('Can walk for 5 min', record.canWalk ?? 'YES'),
            _buildInfoRow('SBP', record.sbp?.toString() ?? 'N/A'),
          ],
        ),

        // Third row: Can climb + DBP
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Can climb stairs', record.canClimb ?? 'YES'),
            _buildInfoRow('DBP', record.dbp?.toString() ?? 'N/A'),
          ],
        ),

        // Diagnosis with reduced spacing
        if (record.diagnosis != null) ...[
          const SizedBox(height: 4),
          _buildInfoRow(
              'Diagnosis',
              (record.diagnosis == 'Other' ? record.otherDiagnosis : record.diagnosis) ?? 'N/A'
          ),
        ],
      ],
    );
  }

  Widget _buildDiagnosisInfo(PatientDrugRecord record) {
    return _buildInfoRow(
        'Diagnosis',
        (record.diagnosis == 'Other' ? record.otherDiagnosis : record.diagnosis) ?? 'N/A'
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

  Widget _buildMedicinesSection(List<Medicine> medicines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Medicines',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF03045E),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...medicines
            .asMap()
            .entries
            .map((entry) {
          int index = entry.key;
          Medicine medicine = entry.value;
          String label = String.fromCharCode('A'.codeUnitAt(0) + (index % 26));

          return _buildCollapsibleMedicineItem(medicine, label);
        }),
      ],
    );
  }

  Widget _buildCollapsibleMedicineItem(Medicine medicine, String label) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          'Medicine $label: ${medicine.name ?? 'N/A'}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 2.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Format: ${medicine.format ?? 'N/A'}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Dosage: ${medicine.dosage ?? 'N/A'} mg',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Frequency: ${medicine.frequency ?? 'N/A'}',
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  'Company name: ${medicine.companyName ?? 'N/A'}',
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}