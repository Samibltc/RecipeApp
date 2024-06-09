
# Recipe App

This Flutter-based mobile application allows users to discover, create, and manage recipes. The app integrates with Firebase for authentication, data storage, and real-time updates.

## Features

- **User Authentication**: Sign up, log in, and manage user profiles with Firebase Authentication.
- **Recipe Management**: Create, edit, and delete recipes. Each recipe includes a name, description, photo, and list of ingredients.
- **Categorized Recipes**: Browse recipes by categories such as Turkish, Greek, Italian, and Chinese.
- **Favorites**: Mark recipes as favorites and view them in the user profile.
- **Cart Functionality**: Add ingredients to a cart and manage them.
- **Image Upload**: Users can upload and update their profile photos and recipe images.

## Screenshots

![Login Screen](assets/images/loginbackground.jpg)
![Recipe List](assets/images/food_background.jpg)

## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Firebase account: [Create Firebase Project](https://console.firebase.google.com/)

### Setup

1. **Clone the repository**
   ```sh
   git clone https://github.com/Samibltc/RecipeApp.git
   cd recipe-app
   ```

2. **Install dependencies**
   ```sh
   flutter pub get
   ```

3. **Configure Firebase**

   - Add your `google-services.json` file to `android/app` directory.
   - Add your `GoogleService-Info.plist` file to `ios/Runner` directory.
   - Ensure Firebase Authentication and Firestore are enabled in your Firebase console.

4. **Run the app**
   ```sh
   flutter run
   ```

### Firebase Configuration

- **Firebase Authentication**: Enable Email/Password sign-in method.
- **Firestore**: Create collections for `User`, `Recipe`, `Ingredients`, and `Cart`.

#### Firestore Structure

- **User**
  ```
  Collection: User
  Document: <userId>
  Fields:
    - Username: string
    - aboutMe: string
    - email: string
    - favRecipe: string
    - profilePhoto: string
  ```

- **Recipe**
  ```
  Collection: Recipe
  Document: <recipeId>
  Fields:
    - RecipeName: string
    - Photo: string
    - calories: number
    - category: string
    - description: string
    - ingredientsID: string
  ```

- **Ingredients**
  ```
  Collection: Ingredients
  Document: <ingredientId>
  Fields:
    - RecipeID: string
    - ingredients: array of objects {name: string, quantity: string}
  ```

- **Cart**
  ```
  Collection: Cart
  Document: <cartId>
  Fields:
    - cartRecipes: string
    - cartUser: string
  ```

## Deployment

### Android

1. **Build APK**
   ```sh
   flutter build apk
   ```

2. **Install APK on device**
   ```sh
   flutter install
   ```

### iOS

1. **Build iOS App**
   ```sh
   flutter build ios
   ```

2. **Run on iOS Simulator or device**

### Firebase Hosting

If you want to deploy the app on Firebase Hosting (Web version):

1. **Install Firebase CLI**
   ```sh
   npm install -g firebase-tools
   ```

2. **Login to Firebase**
   ```sh
   firebase login
   ```

3. **Initialize Firebase in your project**
   ```sh
   firebase init
   ```

4. **Deploy to Firebase Hosting**
   ```sh
   firebase deploy
   ```

## Contributing

Contributions are welcome! Please fork the repository and create a pull request with your changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter: [https://flutter.dev](https://flutter.dev)
- Firebase: [https://firebase.google.com](https://firebase.google.com)
