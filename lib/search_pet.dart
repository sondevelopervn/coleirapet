import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'card_pet.dart';
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
                  stream: Firestore.instance
                      .collection("pets")
                      .where("idPet", isEqualTo: textSearch)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // verifica se a busca é nula e retorna um indicador de progresso
                    if (snapshot.data == null)
                      return Center(child: CircularProgressIndicator());

                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      //case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      default:
                        return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              if (snapshot.data.documents == null) {
                                return Container(
                                  child: Center(
                                    child: Text("Nenhum dado"),
                                  ),
                                );
                              }
                              return Container(
                                // chamando a classe CardPet passando o edit como false
                                  child: CardPet(
                                      snapshot.data.documents[index].data, false));
                            });
                    }
                  },
                ),
              ),

              // este botão retorna para o Main
              RaisedButton(
                child: Text(
                  "Voltar ao menu principal!",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => MyApp()));
                },
                color: Theme.of(context).primaryColor,
              )
            ],
          ),
        ));
  }
}