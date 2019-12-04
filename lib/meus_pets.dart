import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'card_pet.dart';

class MeusPets extends StatefulWidget {



  final String userID;

  const MeusPets(this.userID);

  @override
  _MeusPetsState createState() => _MeusPetsState(userID);
}

class _MeusPetsState extends State<MeusPets> {

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  final String userID;

  _MeusPetsState(this.userID);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meus Pets"),
        centerTitle: true,
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
                    .where("idUser", isEqualTo: this.userID)
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
                            var tamanho = snapshot.data.documents.length;

                            if (snapshot.data.documents == null) {
                              return Container(
                                child: Center(
                                  child: Text("Nenhum dado"),
                                ),
                              );
                            }
                            return Container(
                                child: CardPet(
                                    snapshot.data.documents[index].data, true));
                          });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}


