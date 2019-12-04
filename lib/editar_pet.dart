import 'package:brasil_fields/formatter/telefone_input_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coleirapet/main.dart';
import 'package:coleirapet/meus_pets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_buttons/grouped_buttons.dart';

class EditPet extends StatefulWidget {

  final String petID;

  const EditPet(this.petID);

  @override
  _EditPetState createState() => _EditPetState(petID);
}

class _EditPetState extends State<EditPet> {

  final String petID;

  _EditPetState(this.petID);

  // variável que verifica se a imagem está sendo enviada para o Storage
  bool isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Pet"),
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
                    .where("idPet", isEqualTo: petID)
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
                                child: EditedPet(
                                    snapshot.data.documents[index].data, petID));
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
}

class EditedPet extends StatefulWidget {

  final Map<dynamic, dynamic> data;

  final String petID;

  const EditedPet(this.data, this.petID);

  @override
  _EditedPetState createState() => _EditedPetState(data, petID);
}

class _EditedPetState extends State<EditedPet> {

  bool isSending = false;

  final String petID;

  final Map<dynamic, dynamic> data;

  _EditedPetState(this.data, this.petID);

  final _keyForm = GlobalKey<FormState>();
  final _nomecontroller = TextEditingController();
  final _racacontroller = TextEditingController();
  final _sexocontroller = TextEditingController();
  final _telefonecontroller = TextEditingController();
  final _desciptioncontroller = TextEditingController();
  final _cidadecontroller = TextEditingController();

  // Key para o Scaffold
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
//    _nomecontroller.text = data["nome"];

    return isSending == true ? Center(child: CircularProgressIndicator(),) : Form(
      key: _keyForm,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(15),
        children: <Widget>[
          TextFormField(
            controller: _nomecontroller,
            decoration:
            InputDecoration(hintText: "atende pelo nome de"),
            validator: (text) {
              //com o controller, se o campo for vazío, vai retornar uma mensagem ao clicar em enviar (todos os TextFormField possuem isso)
              if (text.isEmpty) return "campo inválido";
            },
          ),
          SizedBox(
            height: 15,
          ),
          TextFormField(
            controller: _racacontroller,
            decoration: InputDecoration(hintText: "raça"),
            validator: (text) {
              if (text.isEmpty) return "campo inválido";
            },
          ),

          SizedBox(
            height: 15,
          ),

          Text("Sexo:", style: TextStyle(color: Colors.grey),),
          RadioButtonGroup(
              picked: _sexocontroller.text,
              orientation: GroupedButtonsOrientation.VERTICAL,
              labels: <String>[
                "Macho",
                "Fêmea",
              ],
              onSelected: (String selected) => selected != "" ?
                _sexocontroller.text = selected : "Não Informado",
          ),

          SizedBox(
            height: 15,
          ),

          TextFormField(
            controller: _desciptioncontroller,
            decoration: InputDecoration(
                hintText: "coloque uma breve descrição"),
            validator: (text) {
              if (text.isEmpty) return "campo inválido";
            },
          ),

          SizedBox(
            height: 15,
          ),

          TextFormField(
            controller: _cidadecontroller,
            decoration: InputDecoration(hintText: "coloque a cidade"),
            validator: (text) {
              if (text.isEmpty) return "campo inválido";
            },
          ),

          SizedBox(
            height: 15,
          ),

          TextFormField(
            inputFormatters: [
              WhitelistingTextInputFormatter.digitsOnly,
              TelefoneInputFormatter(digito_9: true),
            ],
            controller: _telefonecontroller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "(99)99999-9999"),
            validator: (text) {
              if (text.isEmpty) return "campo inválido";
            },
          ),

          SizedBox(
            height: 10,
          ),

          Align(
              alignment: Alignment.bottomRight,
              child: MaterialButton(
                // botão que limpa a tela, apaga o texto dos campos de textos e deixa como null e false as informações de imagem
                child: Text("Limpar"),
                onPressed: () {
                  setState(() {
                    _nomecontroller.text = "";
                    _racacontroller.text = "";
                    _sexocontroller.text = "";
                    _desciptioncontroller.text = "";
                    _cidadecontroller.text = "";
                    _telefonecontroller.text = "";
                  });
                },
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                iconSize: 45,
                color: Colors.blue,
                icon: Icon(Icons.delete_forever),
                onPressed: (){
                  excluirAlert(petID);
                },
              ),
              RaisedButton(
                child: Text("Salvar", style: TextStyle(color: Colors.white, fontSize: 20),),
                color: Theme.of(context).primaryColor,
                onPressed: (){
                  print(petID);
                  if (_keyForm.currentState.validate()) {
                    savePet(petID);
                    setState(() {
                      // informa que está enviando para poder exibir o indicador na tela
                      isSending = true;
                    });
                  }
                },
              ),
              SizedBox(
                height: 25,
              ),
            ],
          )
        ],
      ),
    );
  }

  Future savePet(String id) async {
    // inicia o envio para o firestore e salva no Firestore com o nome da imagem enviada
    await Firestore.instance.collection("pets").document(id).updateData({
      "nome": _nomecontroller.text,
      "raca": _racacontroller.text,
      "sexo": _sexocontroller.text,
      "descricao": _desciptioncontroller.text,
      "cidade": _cidadecontroller.text,
      "sexo": _sexocontroller.text == "" ? "Não informado" : _sexocontroller.text,
      "telefone": _telefonecontroller.text,
    });

    Navigator.of(context).pop();
  }

  void excluirAlert(String petID) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Deseja remover esse pet?"),
            content: Text("Esta ação não poderá ser desfeita."),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Cancelar",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  "Sim",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final StorageReference ref = FirebaseStorage.instance.ref().child(petID);
                  await ref.delete();
                  await Firestore.instance.collection("pets").document(petID).delete();

                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>MyApp()));
                },
              )
            ],
          );
        });
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _nomecontroller.text = data["nome"];
    _racacontroller.text = data["raca"];
    _sexocontroller.text = data["sexo"];
    _telefonecontroller.text = data["telefone"];
    _desciptioncontroller.text = data["descricao"];
    _cidadecontroller.text = data["cidade"];
  }
}


