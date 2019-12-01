import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class SearchPet extends StatefulWidget {

  // variável para receber o dado do QRCode
  final textScanner;

  // contrutor da classe
  const SearchPet(this.textScanner);

  @override
  _SearchPetState createState() => _SearchPetState(textScanner);
}

class _SearchPetState extends State<SearchPet> {


  // aqui é exibido o texto do QRCode
  final String textSearch;

  // verifica se possui algum texto
  bool qrOk = false;

  // contrutor da classe
  _SearchPetState(this.textSearch);

  @override
  Widget build(BuildContext context) {
    // inicio da tela de layout
    return Scaffold(
        appBar: AppBar(
          title: Text("Busca de Pets"),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder(
                  // função para pegar o documento com o mesmo nome do texto QRCode
                  stream: Firestore.instance.collection("pets").where("idPet", isEqualTo: textSearch).snapshots(),
                  builder: (context, snapshot) {
                    switch(snapshot.connectionState){
                      case ConnectionState.none:
                      //case ConnectionState.waiting:
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
              ),
              // este botão retorna para o Main
              RaisedButton(
                child: Text("Voltar ao menu principal!", style: TextStyle(color: Colors.white),),
                onPressed: (){
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>MyApp()));
                },
                color: Theme.of(context).primaryColor,
              )
            ],
          ),
        )
    );
  }
}

class BuscaPets extends StatelessWidget {

  // assim como na tela de listagem (MyApp - main), essa faz a mesma coisa, pega os dados e exibe dentro de um card
  final Map<dynamic, dynamic> data;

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
                )),
            Align(
              alignment: Alignment.topRight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "Publicado em: " + data["datapublicacao"],
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                Text(
                  "Atende pelo nome de: ",
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
                Text("Raça: ",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                  TextSpan(
                      text: 'Descrição: ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: data["descricao"],
                      style: TextStyle(
                        fontSize: 20,
                      )),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text("Cidade: " + data["cidade"],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
          ]),
    );
  }
}
