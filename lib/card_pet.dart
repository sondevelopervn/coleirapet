import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'editar_pet.dart';

class CardPet extends StatefulWidget {

  final Map<dynamic, dynamic> data;
  final bool edit;

  const CardPet(this.data, this.edit);

  @override
  _CardPetState createState() => _CardPetState(data, edit);
}

class _CardPetState extends State<CardPet> {

  final Map<dynamic, dynamic> data;

  final bool edit;

  _CardPetState(this.data, this.edit);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: edit != true ? null : (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EditPet(data["idPet"])));
          },
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.zero,
                    width: double.infinity,
                    height: 200,
                    child: Image.network(
                      data["img"],
                      fit: BoxFit.cover,
                    )),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    children: <Widget>[
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
                      edit == false ? SizedBox(height: 0,) : Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "Código: " + data["idPet"],
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          softWrap: true,
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            text: '',
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Atende pelo nome de: ',
                                  style: TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold, )),
                              TextSpan(
                                  text: data["nome"],
                                  style: TextStyle(
                                    fontSize: 20,
                                  )),
                            ],
                          ),
                        ),
                      ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: <Widget>[
                              Text("Raça: ",
                                  style: TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(data["raca"], style: TextStyle(fontSize: 20))
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "Sexo: ",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(data["sexo"], style: TextStyle(fontSize: 20))
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                text: '',
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'Descrição: ',
                                      style: TextStyle(
                                          fontSize: 20, fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text: data["descricao"],
                                      style: TextStyle(
                                        fontSize: 20,
                                      )),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: <Widget>[
                              RichText(
                                text: TextSpan(
                                  text: '',
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'Cidade: ',
                                        style: TextStyle(
                                            fontSize: 20, fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text: data["cidade"],
                                        style: TextStyle(
                                          fontSize: 20,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Contato: " + data["telefone"],
                                  style: TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold)),

                              // neste IconButton, o usuário pode ligar para o número que está sendo exibido no Card

                              IconButton(
                                hoverColor: Colors.red,
                                icon: Icon(Icons.call, size: 30, color: Colors.green),
                                onPressed: () {
                                  var telefone = data["telefone"];

                                  launch('tel:$telefone');
                                },
                              )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                )
              ]
          ),
        ),
      ),
    );
  }
}
