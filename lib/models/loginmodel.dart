import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class UserModel extends Model {
  // referencia para o firebase auth
  FirebaseAuth _auth = FirebaseAuth.instance;

  // recebe o usuário do firebase
  FirebaseUser firebaseUser;

  // recebe todos os dados do usuário
  Map<String, dynamic> userData = Map();

  // verifica se está carregando
  bool isLoading = false;

  // essa parte é para deixa statico o UserModel
  static UserModel of(BuildContext context) =>
      ScopedModel.of<UserModel>(context);

  // listener para carregar o usuário atual
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);

    _loadCurrentUser();
  }

  // função de cadastro
  void signUp(
      {@required Map<String, dynamic> userData, // dados do usuário
      @required String pass, // senha
      @required VoidCallback onSuccess, // função de sucesso
      @required VoidCallback onFail // função de falha
      }) {
    isLoading = true;
    notifyListeners();
    _auth.createUserWithEmailAndPassword(
        email: userData["email"], password: pass)
        .then((user) async {
      firebaseUser = user.user;
      await _saveUserData(userData);
      onSuccess();
      isLoading = false;
      notifyListeners();
      }).catchError((e) {
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

  // função de login
  void signIn(
      {@required String email,
      @required String pass,
      @required VoidCallback onSuccess,
      @required VoidCallback onFail}) async {
    isLoading = true;
    notifyListeners();
    _auth.signInWithEmailAndPassword(email: email, password: pass)
      .then((user) async {
      firebaseUser = user.user;
      await _loadCurrentUser();
      onSuccess();
      isLoading = false;
      notifyListeners();
      }).catchError((e) {
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

  // função de logout
  void signOut() async {
    await _auth.signOut();
    userData = Map();
    firebaseUser = null;
    notifyListeners();
  }

  // função para redefinir senha
  void recoverPass(String email) {
    _auth.sendPasswordResetEmail(email: email);
  }

  // verifica se o usuário está logado
  bool isLoggedIn() {
    return firebaseUser != null;
  }

  // salva os dados do usuário no firestore
  Future<Null> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    await Firestore.instance
        .collection("users")
        .document(firebaseUser.uid)
        .setData(userData);
  }

  // carrega os dados usuário se ele não for nulo
  Future<Null> _loadCurrentUser() async {
    if (firebaseUser == null) firebaseUser = await _auth.currentUser();
    if (firebaseUser != null) {
      if (userData["name"] == null) {
        DocumentSnapshot docUser = await Firestore.instance
            .collection("users")
            .document(firebaseUser.uid)
            .get();
        userData = docUser.data;
      }
    }
    notifyListeners();
  }
}
