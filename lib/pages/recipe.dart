import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../custom_app_bar.dart';

class RecipePage extends StatefulWidget {
  final String recipeId;
  final String userId;

  RecipePage({required this.recipeId, required this.userId});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  late DocumentSnapshot recipeData;
  late List ingredients;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    fetchRecipeData();
  }

  Future<void> fetchRecipeData() async {
    try {
      DocumentSnapshot recipeSnapshot = await FirebaseFirestore.instance
          .collection('Recipe')
          .doc(widget.recipeId)
          .get();
      DocumentSnapshot ingredientsSnapshot = await FirebaseFirestore.instance
          .collection('Ingredients')
          .doc(widget.recipeId)
          .get();

      setState(() {
        recipeData = recipeSnapshot;
        ingredients = ingredientsSnapshot['ingredients'];
      });

      checkIfFavorite();
    } catch (e) {
      print('Error fetching recipe data: $e');
    }
  }

  Future<void> checkIfFavorite() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.userId)
          .get();

      setState(() {
        isFavorite = userSnapshot['favRecipe'] == widget.recipeId;
      });
    } catch (e) {
      print('Error checking if favorite: $e');
    }
  }

  Future<void> toggleFavorite() async {
    try {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('User')
          .doc(widget.userId);

      if (isFavorite) {
        await userRef.update({'favRecipe': FieldValue.delete()});
      } else {
        await userRef.update({'favRecipe': widget.recipeId});
      }

      setState(() {
        isFavorite = !isFavorite;
      });
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<void> addToCart() async {
    try {
      await FirebaseFirestore.instance.collection('Cart').add({
        'cartRecipes': FirebaseFirestore.instance.collection('Recipe').doc(widget.recipeId),
        'cartUser': FirebaseFirestore.instance.collection('User').doc(widget.userId),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to cart!')),
      );
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (recipeData == null || ingredients == null) {
      return Scaffold(
        appBar: CustomAppBar(showBackButton: true, userId: widget.userId),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(showBackButton: true, userId: widget.userId),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(recipeData['Photo']),
              SizedBox(height: 16),
              Text(
                recipeData['RecipeName'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '${recipeData['calories']} kcal',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                recipeData['description'],
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Ingredients:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...ingredients.map((ingredient) {
                return ListTile(
                  title: Text('${ingredient['name']}: ${ingredient['quantity']}'),
                );
              }).toList(),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: toggleFavorite,
                      child: Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFavorite ? Colors.red : Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: addToCart,
                      child: Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
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
