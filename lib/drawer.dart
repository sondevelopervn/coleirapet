import 'package:coleirapet/login.dart';
import 'package:coleirapet/scan_qrcode.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'models/loginmodel.dart';

class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
                color: Colors.deepOrangeAccent,
                image: DecorationImage(
                    image: AssetImage("images/pets.jpg"), fit: BoxFit.cover)),
          ),
          Container(
            padding: EdgeInsets.only(left: 15),
            child: ScopedModelDescendant<UserModel>(
              builder: (context, child, model){
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Olá, ${!model.isLoggedIn() ? "" : model.userData["name"]}",
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10,),
                    GestureDetector(
                      child: Text(
                        !model.isLoggedIn() ?
                        "Entre ou cadastre-se" : "Sair",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      onTap: (){
                        if(model.isLoggedIn())
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>LoginScreen()));
                        else{
                          model.signOut();
                        }
                      },
                    )
                  ],
                );
              },
            )
          ),
          Divider(color: Colors.black),
          ListTile(
            trailing: Icon(
              Icons.pets,
              size: 40,
            ),
            title: Text(
              'Achei um Pet!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ScanScreen()));
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
