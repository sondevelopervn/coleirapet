import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {

  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser firebaseUser;

  Map<String, dynamic> userData = Map();

  bool isLoading = false;

  void signUp({@required Map<String, dynamic> userData,
    @required String pass, @required VoidCallback onSuccess, @required VoidCallback onFail}){

    isLoading = true;
    notifyListeners();

    _auth.createUserWithEmailAndPassword(
        email: userData["email"],
        password: pass
    ).then((user) async {
          firebaseUser = user.user;
          await _loadCurrentUser();

          await _saveUserData(userData);

          onSuccess();
          isLoading = false;
          notifyListeners();
    }).catchError((e){
      onFail();
      isLoading = false;
      notifyListeners();
    });

  }

  void signIn({@required String email, @required String pass, @required VoidCallback onSuccess, @required VoidCallback onFail}) async{
    isLoading = true;
    notifyListeners();

    _auth.signInWithEmailAndPassword(email: email, password: pass).then(
        (user) async{
          firebaseUser = user.user;

          await _loadCurrentUser();

          onSuccess();
          isLoading = false;
          notifyListeners();
        }).catchError((e){
        onFail();
        isLoading = false;
        notifyListeners();
    });


    isLoading = false;
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
   super.addListener(listener);
    _loadCurrentUser();
  }

  void recoverPass(String email){
    _auth.sendPasswordResetEmail(email: email);
  }

  Future<Null> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    await Firestore.instance.collection("users").document(firebaseUser.uid).setData(userData);
  }

  bool isLoggedIn(){
    return FirebaseUser != null;
  }

  void signOut() async{

    print(isLoggedIn());
    await FirebaseAuth.instance.signOut();
    userData = Map();
    notifyListeners();
    print(isLoggedIn());

  }

  Future<Null> _loadCurrentUser() async {
    if(firebaseUser == null)
      firebaseUser = await _auth.currentUser();
    if(firebaseUser != null) {
      if (userData["name"] == null) {
        DocumentSnapshot docUser = await Firestore.instance.collection("users")
            .document(firebaseUser.uid)
            .get();

        userData = docUser.data;
        notifyListeners();
      }
    }
    }
}