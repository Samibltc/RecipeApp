import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../custom_app_bar.dart';

class CartPage extends StatelessWidget {
  final String userId;

  CartPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showBackButton: true, userId: userId),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Cart')
            .where('cartUser', isEqualTo: FirebaseFirestore.instance.collection('User').doc(userId))
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final cartItems = snapshot.data!.docs;
          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              final recipeRef = cartItem['cartRecipes'] as DocumentReference;

              return Dismissible(
                key: Key(cartItem.id),
                background: Container(
                  color: Colors.red,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  FirebaseFirestore.instance
                      .collection('Cart')
                      .doc(cartItem.id)
                      .delete()
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Item removed from cart'),
                    ));
                  });
                },
                child: FutureBuilder<DocumentSnapshot>(
                  future: recipeRef.get(),
                  builder: (context, recipeSnapshot) {
                    if (!recipeSnapshot.hasData) {
                      return ListTile(title: Text('Loading...'));
                    }
                    final recipeData = recipeSnapshot.data!;
                    Map<String, dynamic> recipeDataMap = recipeData.data() as Map<String, dynamic>;
                    if (!recipeData.exists) {
                      return ListTile(title: Text('Recipe not found'));
                    }
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('Ingredients')
                          .doc(recipeDataMap['ingredientsID'])
                          .get(),
                      builder: (context, ingredientsSnapshot) {
                        if (!ingredientsSnapshot.hasData) {
                          return ListTile(title: Text('Loading ingredients...'));
                        }
                        final ingredientsData = ingredientsSnapshot.data!;
                        Map<String, dynamic> ingredientsDataMap = ingredientsData.data() as Map<String, dynamic>;
                        if (!ingredientsData.exists || !ingredientsDataMap.containsKey('ingredients')) {
                          return ListTile(title: Text('Ingredients not found'));
                        }
                        final ingredientsList = ingredientsDataMap['ingredients'] as List<dynamic>;
                        return Card(
                          child: ExpansionTile(
                            title: Text(recipeDataMap['RecipeName']),
                            children: [
                              ...ingredientsList.map((ingredient) {
                                return ListTile(
                                  title: Text('${ingredient['name']}: ${ingredient['quantity']}'),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
