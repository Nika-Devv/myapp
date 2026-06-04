import 'package:flutter/material.dart';
import 'list_view_detail.dart';
import '../models/user_model.dart';

class ListViewInsertion extends StatefulWidget {
  const ListViewInsertion({super.key});

  @override
  State<ListViewInsertion> createState() => _ListViewInsertionState();
}

class _ListViewInsertionState extends State<ListViewInsertion> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final List<UserData> _userList = [];

  void _addData() {
    final String name = _nameController.text.trim();
    final String age = _ageController.text.trim();
    final String phone = _phoneController.text.trim();

    if (name.isNotEmpty && age.isNotEmpty && phone.isNotEmpty) {
      setState(() {
        _userList.add(UserData(name: name, age: age, phone: phone));
      });
      _nameController.clear();
      _ageController.clear();
      _phoneController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  void _navigateToDetail(int index) async {
    // Navigate to detail page and wait for the updated user object
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListViewDetail(user: _userList[index]),
      ),
    );

    // If we got an updated user back, refresh the list
    if (updatedUser != null && updatedUser is UserData) {
      setState(() {
        _userList[index] = updatedUser;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Entry & List'),
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
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _addData,
                icon: const Icon(Icons.add),
                label: const Text('Add User to List'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Divider(height: 40),
            Expanded(
              child: _userList.isEmpty
                  ? const Center(child: Text('No entries found.'))
                  : ListView.builder(
                      itemCount: _userList.length,
                      itemBuilder: (context, index) {
                        final user = _userList[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () => _navigateToDetail(index), // Navigate on click
                            leading: CircleAvatar(
                              child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
                            ),
                            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Age: ${user.age} • Phone: ${user.phone}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                // Delete functionality
                                setState(() {
                                  _userList.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
