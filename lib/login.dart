import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'criarconta.dart';

import 'main.dart';

import 'models/loginmodel.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // controller para os campos TextFormField

  final _emailController = TextEditingController();

  final _passController = TextEditingController();

  // key para o Scaffold

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // key para o Form

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // inicio da tela de layout

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Entrar"),
          centerTitle: true,
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Criar conta",
                style: TextStyle(fontSize: 15),
              ),
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignUpScreen()));
              },
            )
          ],
        ),

        // aqui também utiliza o ScopedModelDescendant para verificar os dados do usuário

        body:
        ScopedModelDescendant<UserModel>(builder: (context, child, model) {
          if (model.isLoading)
            return Center(
              child: CircularProgressIndicator(),
            );

          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                TextFormField(
                  //com o controller, se o campo for vazío, vai retornar uma mensagem ao clicar em enviar (todos os TextFormField possuem isso)

                  controller: _emailController,

                  decoration: InputDecoration(hintText: "e-mail"),

                  keyboardType: TextInputType.emailAddress,

                  validator: (text) {
                    if (text.isEmpty || !text.contains("@"))
                      return "E-mail inválido";
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _passController,
                  decoration: InputDecoration(hintText: "senha"),
                  obscureText: true,
                  validator: (text) {
                    if (text.isEmpty || text.length < 6)
                      return "Senha inválida";
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                    onPressed: () {
                      if (_emailController.text.isEmpty) {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text("Insira seu e-mail!"),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 1),
                        ));
                      } else {
                        model.recoverPass(_emailController.text);

                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text("Confira seu e-mail!"),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 1),
                        ));
                      }
                    },
                    child: Text(
                      "Esqueci minha senha",
                      textAlign: TextAlign.right,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 44,
                  child: RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {}

                      // chama a função signIn que está em loginmodel.dart

                      model.signIn(
                          email: _emailController.text,
                          pass: _passController.text,
                          onSuccess: _onSuccess,
                          onFail: _onFail);
                    },
                    child: Text(
                      "Entrar",
                      style: TextStyle(fontSize: 18),
                    ),
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              ],
            ),
          );
        }));
  }

  // essa função é responsável por informar ao usuário que foi criado com sucesso

  void _onSuccess() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => MyApp()));
  }

  // se houve algum erro no envio dos dados, apresentará esta mensagem

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Erro ao logar!"),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 1),
    ));
  }
}
