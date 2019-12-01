import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPet extends StatefulWidget {
  final textScanner;

  const SearchPet(this.textScanner);

  @override
  _SearchPetState createState() => _SearchPetState(textScanner);
}

class _SearchPetState extends State<SearchPet> {

  final String textSearch;

  bool qrOk = false;

  _SearchPetState(this.textSearch);

  @override
  Widget build(BuildContext context) {
    print(textSearch);
    return Scaffold(
        appBar: AppBar(
          title: Text("Busca de Pets"),
          centerTitle: true,
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child:
          //!qrOk ?
         // Center(child: Text("este é o código: $textSearch"),)
              //:
          Column(
            children: <Widget>[
              Expanded(
                child: FutureBuilder(
                  future: Firestore.instance
                      .collection('pets')
                      .where((textSearch){
                      textSearch["idPet"];
                    })
                      .getDocuments(),
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
                                  child: BuscaPets(
                                      snapshot.data.documents[index]));
                            });
                    }
                  },
                ),
              )
            ],
          ),
        )
    );
  }
}

class BuscaPets extends StatelessWidget {
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
            Text("Contato: " + data["telefone"],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 20,
            ),
          ]),
    );
  }
}
