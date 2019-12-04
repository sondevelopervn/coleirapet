import 'package:coleirapet/card_pet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'adiconarpet.dart';
import 'drawer.dart';
import 'login.dart';
import 'models/loginmodel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    // inicio do aplicativo

    // antes de tudo, o ScopedModel<UserData> está inseri aí para poder ser acessado de todas as classe que estiver abaixo

    // portanto, tudo que estiver dentro do MaterialApp tem acesso aos dados do usuário utilizando o ScopedModelDescendant

    return ScopedModel<UserModel>(
      model: UserModel(), // definindo o modelo do ScopedModel

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: 'ColeiraPet', // nome do app

        theme: ThemeData(
          primarySwatch: Colors.deepOrange, // definindo uma cor padrão
        ),

        home: MyHomePage(title: 'Coleirapet'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // inicio da tela de layout

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Expanded(
              // função StreamBuilder que pega os dados do Firestore e se houver alguma mudança atualiza automaticamente

              // stream, fica ouvindo o Firestore

              child: StreamBuilder(
                stream: Firestore.instance.collection("pets").snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:

                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );

                    default:
                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            return Container(
                                child: CardPet(
                                    snapshot.data.documents[index].data, false));
                          });
                  }
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ScopedModelDescendant<UserModel>(
        builder: (context, child, model) {
          return FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              if (model.isLoggedIn()) {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => AddPet(model.firebaseUser.uid)));
              } else {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              }
            },
          );
        },
      ),
      drawer: DrawerScreen(),
    );
  }
}
