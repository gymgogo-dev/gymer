import 'package:flutter/material.dart';
import 'package:gymer/service/database/database_service.dart';

class MemberInfoScreen extends StatefulWidget {
  final Map<String, dynamic> member;

  const MemberInfoScreen({super.key, required this.member});

  @override
  State<MemberInfoScreen> createState() => _MemberInfoScreenState();
}

class _MemberInfoScreenState extends State<MemberInfoScreen> {
  final DatabaseService _databaseService = DatabaseService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _remainingDaysController;
  String? _selectedPackage;

  final List<String> packages = ['2 Minggu', '1 Bulan', 'Tidak ada paket'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member['nama'] ?? '');
    _emailController =
        TextEditingController(text: widget.member['email'] ?? '');

    final membership = widget.member['membership'] as Map<String, dynamic>;
    _remainingDaysController =
        TextEditingController(text: membership['remainingDays'].toString());
    _selectedPackage = membership['package'];
  }

  Future<void> _updateMember() async {
    try {
      String uid = widget.member['uid'];

      final updatedData = {
        'nama': _nameController.text,
        'email': _emailController.text,
        'membership': {
          'package': _selectedPackage ?? '',
          'remainingDays': int.tryParse(_remainingDaysController.text) ?? 0,
        }
      };

      await _databaseService.updateMember(uid, updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data member berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Member'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Nama',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedPackage,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.card_giftcard),
                hintText: 'Pilih Paket',
              ),
              items: packages.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedPackage = newValue;

                  // Atur remainingDays berdasarkan paket yang dipilih
                  if (_selectedPackage == '2 Minggu') {
                    _remainingDaysController.text = '14';
                  } else if (_selectedPackage == '1 Bulan') {
                    _remainingDaysController.text = '30';
                  } else if (_selectedPackage == 'Tidak ada paket') {
                    _remainingDaysController.text = '0';
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remainingDaysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Hari Tersisa',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateMember,
                    child: const Text('Update Member'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
