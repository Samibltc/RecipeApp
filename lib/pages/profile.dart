import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../custom_app_bar.dart';
import 'login.dart';
import 'recipe.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _aboutMeController;
  late String _profilePhotoUrl;
  late List<dynamic> _favRecipes;
  late bool _isLoading;
  File? _newProfileImage;

  @override
  void initState() {
    super.initState();
    _aboutMeController = TextEditingController();
    _profilePhotoUrl = '';
    _favRecipes = [];
    _isLoading = true;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('User').doc(widget.userId).get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _aboutMeController.text = userData['aboutMe'] ?? '';
          _profilePhotoUrl = userData['profilePhoto'] ?? '';
          _favRecipes = userData['favRecipe'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      await FirebaseFirestore.instance.collection('User').doc(widget.userId).update({
        'aboutMe': _aboutMeController.text,
      });
      if (_newProfileImage != null) {
        String fileName = '${widget.userId}_profile.jpg';
        UploadTask uploadTask = FirebaseStorage.instance.ref().child('profile_images/$fileName').putFile(_newProfileImage!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('User').doc(widget.userId).update({
          'profilePhoto': downloadUrl,
        });
        setState(() {
          _profilePhotoUrl = downloadUrl;
          _newProfileImage = null;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile')));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _logOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showBackButton: true, userId: widget.userId),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _newProfileImage != null
                      ? FileImage(_newProfileImage!)
                      : (_profilePhotoUrl.isNotEmpty
                      ? NetworkImage(_profilePhotoUrl)
                      : AssetImage('assets/images/default_profile.png')) as ImageProvider,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _aboutMeController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'About Me',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Update Profile'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _logOut,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Log Out'),
              ),
              SizedBox(height: 32),
              Text(
                'Favorite Recipes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _favRecipes.length,
                itemBuilder: (context, index) {
                  final recipeRef = _favRecipes[index] as DocumentReference;
                  return FutureBuilder<DocumentSnapshot>(
                    future: recipeRef.get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return ListTile(title: Text('Loading...'));
                      }
                      if (!snapshot.data!.exists) {
                        return ListTile(title: Text('Recipe not found'));
                      }
                      final recipeData = snapshot.data!.data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          leading: recipeData['Photo'] != null
                              ? Image.network(recipeData['Photo'], width: 50, height: 50, fit: BoxFit.cover)
                              : Icon(Icons.image),
                          title: Text(recipeData['RecipeName']),
                          subtitle: Text(recipeData['description']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipePage(
                                  recipeId: recipeRef.id,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
