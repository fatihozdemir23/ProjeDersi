import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proje Dersi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Mobil Görüntü İşleme'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? selectedImage;
  String? message, facecount;
  bool kontrol = true;
  uploadImage() async {
    setState(() {
      kontrol = true;
    });
    final request =
        http.MultipartRequest("POST", Uri.parse("http://10.0.2.2:5000/upload"));
    final headers = {"Content-type": "multipart/form-data"};
    request.files.add(http.MultipartFile('image',
        selectedImage!.readAsBytes().asStream(), selectedImage!.lengthSync(),
        filename: "dosya.jpg"));
    request.headers.addAll(headers);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);

    setState(() {
      message = "http://10.0.2.2:5000/upload/" + resJson['path'].toString();
      facecount = resJson['facecount'].toString();
    });
  }

  Future getImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    selectedImage = File(pickedImage!.path);
    setState(() {});
  }

  void _incrementCounter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            selectedImage == null
                ? Text("İşlencek Resmi seçiniz")
                : Column(
                    children: [
                      SizedBox(
                          width: 200,
                          height: 200,
                          child: Image.file(selectedImage!)),
                      facecount == null
                          ? Text("Yüz Tespit Edilemedi")
                          : Text(
                              "Tespit Edilen Yüz Sayısı:" +
                                  facecount.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                      if (kontrol == false)
                        SizedBox(
                            width: 400,
                            height: 200,
                            child: Image.network(message.toString()))
                      else
                        CircularProgressIndicator()
                    ],
                  ),
            ElevatedButton(
                onPressed: () async {
                  await uploadImage();
                  setState(() {
                    kontrol = false;
                  });
                },
                child: Text("Yükle")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Resim Çek',
        child: const Icon(Icons.add_a_photo),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
