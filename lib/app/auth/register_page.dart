import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymer/app/admin/addmember/addmember_controller.dart';
import 'package:gymer/service/register/register_service.dart';
import 'package:gymer/widget/loading/loadingwidget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterService service = RegisterService();
  AddmemberController controller = AddmemberController();
  FirebaseAuth auth = FirebaseAuth.instance;

  int? remainingDays;
  String? _selectedPackage;

  Future<void> _registerUser() async {
    if (_selectedPackage == '2 Minggu') {
      remainingDays = 14;
    } else if (_selectedPackage == '1 Bulan') {
      remainingDays = 30;
    }

    remainingDays = 0;
    _selectedPackage = 'Tidak ada paket';

    try {
      LoadingDialog.show(context);

      String memberName = controller.nameController.text;
      String memberEmail = controller.emailController.text;
      String memberPassword = controller.passwordController.text;

      await service.registerUser(memberName, memberEmail, memberPassword,
          _selectedPackage!, remainingDays!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi berhasil!')),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      print(e.toString());
    } finally {
      LoadingDialog.hide(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextFormField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  hintText: 'Nama',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.passwordController,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _registerUser();
                      },
                      child: const Text('Daftar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
