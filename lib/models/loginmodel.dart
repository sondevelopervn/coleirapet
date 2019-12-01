import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {

  // facilitando o inicio da função para chamar o firebase
  FirebaseAuth _auth = FirebaseAuth.instance;

  //variável do usuário do firebase
  FirebaseUser firebaseUser;

  // mapa de dados de cada usuário
  Map<String, dynamic> userData = Map();

  // variável para podermos verificar se está carregando ou não
  bool isLoading = false;

  // inicio da funçõa de cadastro do usuário
  // primeiro informa que está carregando, e notifica os listeners
  // listener são os responsáveis para informar ao Model o estado do usuário

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

  // função de login do usuário
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

  // função que pega o usuário atual
  @override
  void addListener(VoidCallback listener) {
   super.addListener(listener);
    _loadCurrentUser();
  }

  // função para redefinir a senha
  void recoverPass(String email){
    _auth.sendPasswordResetEmail(email: email);
  }

  // função que salva os dados do usuário e insere dentro do Map
  Future<Null> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    await Firestore.instance.collection("users").document(firebaseUser.uid).setData(userData);
  }

  // função que verifica se o usuário está logado
  bool isLoggedIn(){
    return FirebaseUser != null;
  }

  // função para deslogar usuário
  void signOut() async{

    print(isLoggedIn());
    await FirebaseAuth.instance.signOut();
    userData = Map();
    notifyListeners();
    print(isLoggedIn());

  }

  // função que carrega o usuário atual
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