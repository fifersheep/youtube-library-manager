import 'package:flutter/material.dart';
import 'package:youtube_library_manager/src/data/repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFDD5555)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<PlaylistItem> songs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  signInWithGoogle();
                },
                child: const Text("Sign In"),
              ),
              ElevatedButton(
                onPressed: () {
                  handleAuthorizeScopes();
                },
                child: const Text("Authorize"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final data = await fetchSongs();
                  setState(() {
                    songs = data;
                  });
                },
                child: const Text("Show Songs"),
              ),
            ],
          ),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final song = songs[index];
                return Column(
                  children: [
                    Text(song.title),
                    Text(song.videoOwnerChannelTitle ?? "N/A"),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return Container(
                  height: 1,
                  color: Colors.grey,
                );
              },
              itemCount: songs.length,
            ),
          ),
        ],
      ),
    );
  }
}
