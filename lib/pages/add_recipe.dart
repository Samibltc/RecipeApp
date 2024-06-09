import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AddRecipePage extends StatefulWidget {
  final String userId;

  AddRecipePage({required this.userId});

  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  String _recipeName = '';
  String _description = '';
  int _calories = 0;
  String _category = 'Turkish';
  List<Map<String, dynamic>> _ingredients = [];
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _addIngredient() async {
    final ingredientNameController = TextEditingController();
    final ingredientQuantityController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Ingredient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ingredientNameController,
                decoration: InputDecoration(labelText: 'Ingredient Name'),
              ),
              TextField(
                controller: ingredientQuantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _ingredients.add({
                    'name': ingredientNameController.text,
                    'quantity': ingredientQuantityController.text,
                  });
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadRecipe() async {
    if (_formKey.currentState!.validate() && _image != null) {
      _formKey.currentState!.save();
      final recipeRef = FirebaseFirestore.instance.collection('Recipe').doc();
      final imageUrl = await _uploadImage(_image!, recipeRef.id);

      await recipeRef.set({
        'RecipeName': _recipeName,
        'description': _description,
        'calories': _calories,
        'category': _category,
        'Photo': imageUrl,
        'ingredientsID': recipeRef.id,
      });

      final ingredientsRef = FirebaseFirestore.instance.collection('Ingredients').doc(recipeRef.id);
      await ingredientsRef.set({
        'RecipeID': recipeRef.id,
        'ingredients': _ingredients,
      });

      Navigator.pop(context);
    }
  }

  Future<String> _uploadImage(File image, String recipeId) async {
    final storageRef = FirebaseStorage.instance.ref().child('recipe_images').child('$recipeId.jpg');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Recipe Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a recipe name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _recipeName = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _description = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Calories'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the calories';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _calories = int.parse(value!);
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _category,
                  onChanged: (newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                  items: ['Turkish', 'Greek', 'Italian', 'Chinese']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                SizedBox(height: 10),
                Text('Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ..._ingredients.map((ingredient) => ListTile(
                  title: Text('${ingredient['name']}: ${ingredient['quantity']}'),
                )),
                TextButton(
                  onPressed: _addIngredient,
                  child: Text('Add Ingredient'),
                ),
                SizedBox(height: 10),
                _image == null
                    ? Text('No image selected.')
                    : Image.file(_image!),
                TextButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadRecipe,
                  child: Text('Add Recipe'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
