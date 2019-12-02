import 'package:coleirapet/search_pet.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {

  // key para o controller
  GlobalKey qrKey = GlobalKey();

  // variável que salvará o texto do QRCode
  var qrText;

  QRViewController controller;

  @override
  Widget build(BuildContext context) {

    // inicio da tela de layout
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              overlay: QrScannerOverlayShape(
                  borderRadius: 10,
                  borderColor: Colors.red,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 300
              ),
              onQRViewCreated: _onQrViewCreate,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }


  // função que vai ler o QRCode e retornar o texto
  void _onQrViewCreate(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData){
      setState(() {
        qrText = scanData;
        // chamando a função abaixo, faz com que não ocorra erro na hora de transição tela para outra
        // a camera aberta em segundo plano faz com que o app tenha travamentos
        controller?.pauseCamera();
        // Neste Navigator, será transportado dessa tela para a tela de pesquisa o testo do qrcode
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>SearchPet(qrText)));
      });
    });
  }
}
