import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'models/loginmodel.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // key para o Form
  final _formKey = GlobalKey<FormState>();

  // controllers para os TextFormField
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  // key para o Scaffold
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    // inicio da tela de layout
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Criar conta"),
        centerTitle: true,
      ),
      // ScopedModelDescendant serve para verificar o estado do usuário, se está logado ou não, pegar informações como nome, idade...
      body: ScopedModelDescendant<UserModel>(
          builder: (context, child, model){

            // verifica se está carregando ou não para poder exibir o indicador (os dados estão em loginmodel.dart)
            if(model.isLoading)
              return Center(child: CircularProgressIndicator(),);

            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: <Widget>[
                  TextFormField(
                    //com o controller, se o campo for vazío, vai retornar uma mensagem ao clicar em enviar (todos os TextFormField possuem isso)
                    controller: _nameController,
                    decoration: InputDecoration(
                        hintText: "nome"
                    ),
                    validator: (text){
                      if(text.isEmpty) return "Nome inválido";
                    },
                  ),
                  SizedBox(height: 16,),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        hintText: "e-mail"
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (text){
                      if(text.isEmpty || !text.contains("@")) return "E-mail inválido";
                    },
                  ),
                  SizedBox(height: 16,),
                  TextFormField(
                    controller: _passController,
                    decoration: InputDecoration(
                        hintText: "senha"
                    ),
                    obscureText: true,
                    validator: (text){
                      if(text.isEmpty || text.length < 6) return "Senha inválida";
                    },
                  ),
                  SizedBox(height: 16,),
                  SizedBox(
                    height: 44,
                    child: RaisedButton(
                      onPressed: (){
                        // verifica se todos os campos estão preenchidos
                        if(_formKey.currentState.validate()){

                          Map<String, dynamic> userData = {
                            // salva no Map do modelo usuário as informações de e-mail e senha
                            "name": _nameController.text,
                            "email": _emailController.text,
                          };

                          // chama a função signUp em loginmodel.dart
                          model.signUp(
                              userData: userData,
                              pass: _passController.text,
                              onSuccess: _onSuccess,
                              onFail: _onFail
                          );
                        }

                      },
                      child: Text("Criar conta", style: TextStyle(fontSize: 18),),
                      textColor: Colors.white,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              ),
            );
          }
          )
    );
  }

  // essa função é responsável por informar ao usuário que foi criado com sucesso
  void _onSuccess(){
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Usuário criado com sucesso!"),
      backgroundColor: Theme.of(context).primaryColor,
      duration: Duration(seconds: 2),
        )
      );
      Future.delayed(Duration(seconds: 2)).then((_){
        Navigator.of(context).pop();
      });
  }

  // se houve algum erro no envio dos dados, apresentará esta mensagem
  void _onFail(){
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Erro ao criar usuário!"),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 1),
    )
    );
  }
}
