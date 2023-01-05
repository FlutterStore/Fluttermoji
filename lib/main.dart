// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttermoji/fluttermoji.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key,}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    checkper();
    super.initState();
  }


  checkper() async
  {
    await Permission.storage.isDenied.then((value) => Permission.storage.request());
    await Permission.camera.isDenied.then((value) => Permission.camera.request());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fluttermoji",style: TextStyle(fontSize: 15),),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FluttermojiCircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 100,
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            children: [
              const Spacer(flex: 2),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 35,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Customize"),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const NewPage())),
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}
class NewPage extends StatefulWidget {
  const NewPage({super.key});

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {

  Directory directory = Directory('/storage/emulated/0/Pictures/fluttermojis');
  
  @override
  void initState() {
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    super.initState();
  }

@override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: RepaintBoundary(
                  key: previewContainers,
                  child: FluttermojiCircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              SizedBox(
                width: min(600, width * 0.85),
                child: Row(
                  children: [
                    Text(
                      "Customize",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const Spacer(),
                    FluttermojiSaveWidget(
                      onTap: (){
                        takeScreenShot().then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Successfully Save'))
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                child: FluttermojiCustomizer(
                  // attributeIcons: const [
                  //   'haircolor.svg',
                  //   'beard.svg'
                  // ],
                  // attributeTitles: const [
                  //   'Hair Colour',
                  //   'Facial Hair'
                  // ],
                  scaffoldWidth: min(600, MediaQuery.of(context).size.width),
                  autosave: true,
                  theme: FluttermojiThemeData(

                    boxDecoration: const BoxDecoration(boxShadow: [BoxShadow()])
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  GlobalKey previewContainers = GlobalKey();
  Future<void> takeScreenShot() async {
    var rng = Random();
    final RenderRepaintBoundary boundary = previewContainers.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final ByteData? byteData =
        await image.toByteData(format: ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    File imgFile =
        File('/storage/emulated/0/Pictures/fluttermojis/Bitemoji_${rng.nextInt(1000)}.png');
    await imgFile.writeAsBytes(pngBytes);
  }
}

