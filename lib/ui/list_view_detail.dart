import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ListViewDetail extends StatefulWidget {
  final UserData user;
  const ListViewDetail({super.key, required this.user});

  @override
  State<ListViewDetail> createState() => _ListViewDetailState();
}

class _ListViewDetailState extends State<ListViewDetail> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _ageController = TextEditingController(text: widget.user.age);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _update() {
    final String name = _nameController.text.trim();
    final String age = _ageController.text.trim();
    final String phone = _phoneController.text.trim();

    if (name.isNotEmpty && age.isNotEmpty && phone.isNotEmpty) {
      // Create a new UserData object with updated values
      final updatedUser = UserData(name: name, age: age, phone: phone);
      // Return the updated user to the previous screen
      Navigator.pop(context, updatedUser);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _update,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
