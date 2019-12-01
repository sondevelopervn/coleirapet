import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'adiconarpet.dart';
import 'drawer.dart';
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
                  switch(snapshot.connectionState){
                    case ConnectionState.none:
                    case ConnectionState.waiting :
                      return Center(child: CircularProgressIndicator(),);
                    default:
                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            return Container(child: BuscaPets(snapshot.data.documents[index].data));
                          }
                      );
                  }
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddPet()));
        },
      ),
      drawer: DrawerScreen(),
    );
  }
}

class BuscaPets extends StatelessWidget {

  // classe para contruir a tela que exibirá os dados do Firestore
  // aqui serão exibidos os dados dentro do card

  final Map<String, dynamic> data;

  BuscaPets(this.data);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                width: 350,
                height: 200,
                child: Image.network(
                  data["img"],
                  fit: BoxFit.cover,
                )
            ),
            Align(
              alignment: Alignment.topRight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text("Publicado em: " + data["datapublicacao"], textAlign: TextAlign.right,),
//                  Text(data[getCurrentTag()]),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                Text("Atende pelo nome de: ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(data["nome"], style: TextStyle(fontSize: 20))
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                Text("Raça: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                Text(data["raca"], style: TextStyle(fontSize: 20))
              ],
            ),
            SizedBox(
              height: 20,
            ),
            RichText(
              text: TextSpan(
                text: '',
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(text: 'Descrição: ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextSpan(text: data["descricao"], style: TextStyle(fontSize: 20,)),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text("Cidade: " + data["cidade"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Contato: " + data["telefone"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                // neste IconButton, o usuário pode ligar para o número que está sendo exibido no Card
                IconButton(
                  hoverColor: Colors.red,
                  icon: Icon(Icons.call, size: 30, color: Colors.green),
                  onPressed: (){
                    var telefone = data["telefone"];
                    launch('tel:$telefone');
                  },
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ]
      ),
    );
  }
}
