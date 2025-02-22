import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/authprovider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    print('User avatar: ${user.avatar}'); // Debug print to check avatar

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.oswald(
            fontSize: 24,
            color: const Color.fromARGB(221, 44, 163, 58),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(80.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : user.avatar != null
                          ? NetworkImage(user.avatar!) as ImageProvider
                          : const AssetImage('assets/default.png'),
                  backgroundColor: const Color.fromARGB(255, 252, 250, 250),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            _buildProfileInfo('Name', user.name),
            _buildProfileInfo('Email', user.email),
            _buildProfileInfo('Phone', user.phone),
            _buildProfileInfo('Address', user.address),
            const SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _editProfile,
                  child: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(221, 44, 163, 58), // Green color
                  ),
                ),
                const SizedBox(width: 20.0),
                ElevatedButton(
                  onPressed: _image == null ? null : _updateAvatar,
                  child: const Text('Update Avatar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(221, 44, 163, 58), // Green color
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black87, // Text color
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _updateAvatar() async {
    if (_image == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token') ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      String apiUrl =
          'http://127.0.0.1:8000/api/customer/profile/update/avatar';

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';

      request.files
          .add(await http.MultipartFile.fromPath('avatar', _image!.path));

      var response = await request.send();

      var responseText = await response.stream.bytesToString();
      print('Response status code: ${response.statusCode}');
      print('Response body: $responseText');

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(responseText);
        authProvider.updateAvatar(jsonResponse['customer']['avatar']);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update avatar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      Navigator.pop(context); // Dismiss the loading dialog
    }
  }

  Future<void> _editProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final TextEditingController nameController =
        TextEditingController(text: user.name);
    final TextEditingController emailController =
        TextEditingController(text: user.email);
    final TextEditingController phoneController =
        TextEditingController(text: user.phone);
    final TextEditingController addressController =
        TextEditingController(text: user.address);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Profile',
            style: GoogleFonts.oswald(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(height: 8.0),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name and Email cannot be empty'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Address cannot be empty'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final token = await SharedPreferences.getInstance()
                    .then((prefs) => prefs.getString('token') ?? '');

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(child: CircularProgressIndicator());
                  },
                );

                try {
                  final response = await http.put(
                    Uri.parse(
                        'http://127.0.0.1:8000/api/customer/profile/edit'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                    body: json.encode({
                      'name': nameController.text,
                      'email': emailController.text,
                      'phone': phoneController.text,
                      'address': addressController.text,
                    }),
                  );

                  if (response.statusCode == 201 ||
                      response.statusCode == 204) {
                    authProvider.updateUserProfile(
                      nameController.text,
                      emailController.text,
                      phoneController.text,
                      addressController.text,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update profile'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                } finally {
                  Navigator.of(context).pop(); // Dismiss the loading dialog
                  Navigator.of(context).pop(); // Close the edit profile dialog
                }
              },
              child: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }
}
