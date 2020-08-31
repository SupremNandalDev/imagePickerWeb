import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick and Post to Server'),
        centerTitle: true,
      ),
      body: ChangeNotifierProvider<MyProvider>(
        create: (context) => MyProvider(),
        child: Consumer<MyProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                if (provider.image != null) Image.network(provider.image.path),
                MaterialButton(
                  onPressed: () async {
                    var image = await ImagePicker()
                        .getImage(source: ImageSource.gallery);
                    provider.setImage(image);
                  },
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text('Get image'),
                ),
                MaterialButton(
                  onPressed: () {
                    if (provider.image == null) return;
                    provider.makePostRequest();
                  },
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text('make post request...'),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class MyProvider extends ChangeNotifier {
  var image;

  Future setImage(img) async {
    this.image = img;
    this.notifyListeners();
  }

  Future makePostRequest() async {
    String url = 'your end point';
    var headers = {
      //YOUR HEADERS
    };
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);
    Uint8List data = await this.image.readAsBytes();
    List<int> list = data.cast();
    request.files.add(http.MultipartFile.fromBytes('your_field_name', list,
        filename: 'myFile.png'));

    // Now we can make this call

    var response = await request.send();
    //We've made a post request...
    //Let's read response now

    response.stream.bytesToString().asStream().listen((event) {
      var parsedJson = json.decode(event);
      print(parsedJson);
      print(response.statusCode);
      //It's done...
    });
  }
}
