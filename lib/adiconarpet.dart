import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:brasil_fields/formatter/telefone_input_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_buttons/grouped_buttons.dart';

class AddPet extends StatefulWidget {
  final String userID;

  const AddPet(this.userID);

  @override
  _AddPetState createState() => _AddPetState(userID);
}

class _AddPetState extends State<AddPet> {

  final String userID;

  _AddPetState(this.userID);

  // String que recebe a URL de download da imagem
  String urlImage;

  // variável que verifica se a imagem está sendo enviada para o Storage
  bool isSending = false;

  // variável para salvar o nome do arquivo gerado no Storage
  String nameDoc = "";

  // variável para salvar a imagem
  File _pickedImage;

  // verifica se existe uma imagem selecionada
  bool imgSelected = false;

  // função que captura a imagem através da camera
  Future<File> getImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _pickedImage = image;
      imgSelected = true;
    });
    return image;
  }

  // função que captura a imagem através da galeria
  Future<File> getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = image;
      imgSelected = true;
    });
    return image;
  }

  // informa o alert para o usuário apagar ou não a foto
  void alertImage() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Deseja remover essa foto?"),
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
                onPressed: () {
                  Navigator.of(context).pop();

                  setState(() {
                    return _pickedImage = null;
                  });
                },
              )
            ],
          );
        });
  }

  // controladores para os TextFormField
  final _nomecontroller = TextEditingController();
  final _racacontroller = TextEditingController();
  final _sexocontroller = TextEditingController();
  final _telefonecontroller = TextEditingController();
  final _desciptioncontroller = TextEditingController();
  final _cidadecontroller = TextEditingController();

  // key para o Form
  final _formKey = GlobalKey<FormState>();

  // Key para o Scaffold
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // inicio da tela de layou com o scaffold
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Adicionar Pet"),
        centerTitle: true,
      ),

      // aqui, verifica se está enviando a imagem, se estiver, ele retornará um indicador de envio, senão, retorna o Form
      body: isSending == true
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(15),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Text(
                    "Insira abaixo as informações de seu pet perdido",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                MaterialButton(
                  // se a imagem for nula, os botões estaram habilitados, se existir uma imagem os botões serão desabilitados
                    child: Text("Tirar Foto"),
                    onPressed: _pickedImage != null
                        ? null
                        : () {
                      getImageFromCamera();
                    }),
                MaterialButton(
                    child: Text("Abrir Galeria"),
                    onPressed: _pickedImage != null
                        ? null
                        : () {
                      getImageFromGallery();
                    })
              ],
            ),
            _pickedImage != null
                ? Text(
              "Pressione na imagem para remover",
              style: TextStyle(fontStyle: FontStyle.italic),
            )
                : Padding(
              padding: EdgeInsets.zero,
            ),
            InkWell(
              child: Align(
                  alignment: Alignment.topLeft,
                  // se a imagem foi selecionada, vai retornar a mesma em um Container,
                  // senão, vai retornar o campo para inserir a mesma
                  child: _pickedImage == null
                      ? Container(
                    width: double.infinity,
                    height: 200,
                    color: Theme.of(context).primaryColor,
                    child: Center(
                      child: Text(
                        "+",
                        style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  )
                      : Container(
                    width: double.infinity,
                    height: 200,
                    child: Image.file(_pickedImage, fit: BoxFit.cover),
                  )),

              // nesse on tap, está chamando a função para excluir a foto
              onTap: () {
                if(_pickedImage != null)
                  alertImage();
              }
            ),

            SizedBox(
              height: 15,
            ),
            //inicio dos TextFormField
            // controller serve para pegar o texto do campo
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
                orientation: GroupedButtonsOrientation.VERTICAL,
                labels: <String>[
                  "Macho",
                  "Fêmea",
                ],
                onSelected: (String selected) => _sexocontroller.text = selected
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
                      _pickedImage = null;
                      imgSelected = false;
                    });
                  },
                )),
            SizedBox(
              height: 25,
            ),
            SizedBox(
              height: 50,
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                child: Text(
                  "Salvar",
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                onPressed: () {
                  // verifica se a imagem foi ou não inserida
                  if (urlImage == "") {
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text("Imagem não inserida!"),
                      duration: Duration(seconds: 5),
                      backgroundColor: Colors.red,
                    ));
                  } else if (_formKey.currentState.validate()) {
                    // se a imagem foi inserida e todos os campos preenchidos, vai entrar nesse if
                    // vai chamar a função enviar(context), função responsável pelo envio da imagem ao Storage
                    enviar(context);
                    setState(() {
                      // informa que está enviando para poder exibir o indicador na tela
                      isSending = true;
                    });
                  }
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "O processo de envio pode demorar*",
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).primaryColor),
            )
          ],
        ),
      ),
    );
  }

  Future enviar(BuildContext context) async {
    // nesta função, primeiro pega a imagem e envia para o storage, depois retorna a URL de download para poder salvar no Firestore
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(
        DateTime.now().millisecondsSinceEpoch.toString()); // designa o local e nome do arquivo
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_pickedImage); // envia foto
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete; // aguardar finalizar o envio
    String url = await taskSnapshot.ref.getDownloadURL(); // recupera a URL de download
    String idImg = await taskSnapshot.ref.getName(); // recupera o nome da imagem
    setState(() {
      // seta o estado das variáveis abaixo para poder salvar no Firestore
      urlImage = url;
      nameDoc = idImg;
    });
    // formatando data para exibir como data de publicação
    DateTime now = DateTime.now();
    String formattedDate = DateFormat(' dd/MM/y - HH:mm').format(now);
    savePet(formattedDate, url);
  }

  Future savePet(String date, String url) async {
    // inicia o envio para o firestore e salva no Firestore com o nome da imagem enviada
    await Firestore.instance.collection("pets").document(nameDoc).setData({
      // abaixo, onde está ...controller.text são os campos de texto,
      "nome": _nomecontroller.text,
      "raca": _racacontroller.text,
      "sexo": _sexocontroller.text,
      "descricao": _desciptioncontroller.text,
      "cidade": _cidadecontroller.text,
      "sexo": _sexocontroller.text == "" ? "Não informado" : _sexocontroller.text,
      "telefone": _telefonecontroller.text,
      "img": url, // nome da imagem recuperada na função enviar(context)
      "datapublicacao": date.toString(), // data formatada
      "idPet": nameDoc, // nome da imagem no storage
      "idUser": userID // id do usuário logado

      // o nome da imagem no Storage foi um meio para poder fazer a pesquisa de um uníco item posteriormente
    });

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Pet inserido com sucesso!"),
      duration: Duration(seconds: 5),
      backgroundColor: Colors.green,
    ));

    Navigator.of(context).pop();
  }
}
