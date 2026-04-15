import 'package:flutter_riverpod/legacy.dart';
import 'package:multi_store_app/models/user.dart';

class UserProvider extends StateNotifier<User?> {
  //constructor initializing with default User object
  //purpose : Manage the state of the user object allowing udpates
  UserProvider()
    : super(
        User(
          id: '',
          fullName: '',
          email: '',
          state: '',
          city: '',
          locality: '',
          password: '',
          token: '',
        ),
      );
  //Getter method to extract value from an object

  User? get user => state;

  //method to set user state from Json
  //purpose : updates the user state based on json String representation of user Object

  void setUser(String userJson) {
    state = User.fromJson(userJson);
  }

  //Method to clear user state
  void signOut() {
    state = null;
  }

  //Method to recreate the user state
  void recreateUserState({
    required String state,
    required String city,
    required String locality,
  }) {
    if (this.state != null) {
      this.state = User(
        id: this.state!.id, // this will preserve the existing user id
        fullName: this.state!.fullName,  // this will preserve the existing user fullName
        email: this.state!.email, // this will preserve the existing user email
        state: state,
        city: city,
        locality: locality,
        password: this.state!.password, // this will preserve the existing user password
        token: this.state!.token, // this will preserve the existing user token
      );
    }
  }
}

//make the data accisible within the application
final userProvider = StateNotifierProvider<UserProvider, User?>(
  (ref) => UserProvider(),
);
