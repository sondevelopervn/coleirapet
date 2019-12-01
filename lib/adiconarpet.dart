import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:brasil_fields/formatter/telefone_input_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddPet extends StatefulWidget {
  @override
  _AddPetState createState() => _AddPetState();
}

class _AddPetState extends State<AddPet> {

  String urlImage;
  bool isSending = false;

  File _pickedImage;
  bool imgSelected = false;

  Future<File> getImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _pickedImage = image;
      imgSelected = true;
    });
    return image;
  }

  final _nomecontroller = TextEditingController();
  final _racacontroller = TextEditingController();
  final _sexocontroller = TextEditingController();
  final _telefonecontroller = TextEditingController();
  final _desciptioncontroller = TextEditingController();
  final _cidadecontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String nameDoc = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Adicionar Pet"),
        centerTitle: true,
      ),
      body: isSending == true ? Center(child: CircularProgressIndicator(),) : Form(
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
            InkWell(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: !imgSelected ? Container(
                    width: 150,
                    height: 100,
                    color: Colors.grey,
                    child: Center(
                      child: Text("+", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ) : Container(
                    child: InkWell( child: Text("* Imagem selecionada, clique aqui se deseja alterar * ", style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).primaryColor)),
                      onTap: (){
                        setState(() {
                          _pickedImage = null;
                          imgSelected = false;
                        });
                      }
                    ),
                  ),
                ),
              onTap: getImageFromCamera,
            ),
            TextFormField(
              controller: _nomecontroller,
              decoration: InputDecoration(hintText: "atende pelo nome de"),
              validator: (text) {
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
            TextFormField(
              controller: _sexocontroller,
              decoration: InputDecoration(hintText: "macho ou fêmea"),
              validator: (text) {
                if (text.isEmpty) return "campo inválido";
              },
            ),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: _desciptioncontroller,
              decoration:
                  InputDecoration(hintText: "coloque uma breve descrição"),
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
            SizedBox(height: 10,),
            Align(
              alignment: Alignment.bottomRight,
              child:
                MaterialButton(
                  child: Text("Limpar"),
                  onPressed: (){
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
                )
            ),
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
                  if(urlImage == ""){
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text("Imagem não inserida!"),
                      duration: Duration(seconds: 5),
                      backgroundColor: Colors.red,
                    ));
                  }
                  else if (_formKey.currentState.validate()) {
                    enviar(context);
                    setState(() {
                      isSending = true;
                    });
                  }
                },
              ),
            ),
            SizedBox(height: 10,),
            Text("O processo de envio pode demorar*", style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).primaryColor),)
          ],
        ),
      ),
    );
  }

  Future enviar(BuildContext context) async {

    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(DateTime.now().millisecondsSinceEpoch.toString());
    StorageUploadTask uploadTask =  firebaseStorageRef.putFile(_pickedImage);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String url = await taskSnapshot.ref.getDownloadURL();
    String idImg = await taskSnapshot.ref.getName();

    print(idImg);

    setState(() {
      urlImage = url;
      nameDoc = idImg;
    });

    DateTime now = DateTime.now();
    String formattedDate =
    DateFormat(' dd/MM/y - HH:mm').format(now);
    savePet(formattedDate, url);
  }

  Future savePet(String date, String url) async {
    await Firestore.instance.collection("pets").document(nameDoc).setData({
      "nome": _nomecontroller.text,
      "raca": _racacontroller.text,
      "sexo": _sexocontroller.text,
      "descricao": _desciptioncontroller.text,
      "cidade": _cidadecontroller.text,
      "sexo": _sexocontroller.text,
      "telefone": _telefonecontroller.text,
      "img": url,
      "datapublicacao": date.toString(),
      "idPet": nameDoc
    });
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Pet inserido com sucesso!"),
      duration: Duration(seconds: 5),
      backgroundColor: Colors.green,
    ));
    Navigator.of(context).pop();
  }
}
