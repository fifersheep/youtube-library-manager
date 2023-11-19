import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/youtube.readonly',
  ],
);

GoogleSignInAccount? _currentUser;

Future<void> signInWithGoogle() async {
  try {
    _currentUser = await _googleSignIn.signIn();
  } catch (error) {
    // error
  }
}

Future<void> handleAuthorizeScopes() async {
  await _googleSignIn.requestScopes([
    'email',
    'https://www.googleapis.com/auth/youtube.readonly',
  ]);
}

class PlaylistItem {
  final String title;
  final String? videoOwnerChannelTitle;

  const PlaylistItem({required this.title, required this.videoOwnerChannelTitle});
}

Future<List<PlaylistItem>> fetchSongs() async {
  final playlistIds = await _fetchPlaylistIds();
  final authHeaders = await _currentUser?.authHeaders;
  final urls = playlistIds.map((id) => http.get(
        Uri.parse('https://www.googleapis.com/youtube/v3/playlistItems?playlistId=$id&part=snippet&maxResults=50'),
        headers: authHeaders,
      ));

  final results = await Future.wait(urls);
  final blah = results.expand((res) {
    final data = json.decode(res.body);
    List<dynamic> items = data["items"];
    // String nextPageToken = data["nextPageToken"]
    return items
        .map((e) => PlaylistItem(
              title: e["snippet"]["title"] as String,
              videoOwnerChannelTitle: e["snippet"]["videoOwnerChannelTitle"] as String?,
            ))
        .toList();
  });

  return blah.toList();
}

Future<List<String>> _fetchPlaylistIds() async {
  const String apiUrl = 'https://www.googleapis.com/youtube/v3/playlists?mine=true&maxResults=50';
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: await _currentUser?.authHeaders,
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    List<dynamic> songs = data["items"];
    return songs.map((e) => e["id"] as String).toList();
  } else {
    throw Exception('Failed to load songs');
  }
}
