import 'dart:typed_data';

class Music{
  int id;
  String musicPath;
  String musicTitle;
  Uint8List albumArt;

  Music({this.musicPath, this.musicTitle, this.albumArt});

  Map<String, dynamic> toMap() {
    return {
      'music_path': musicPath,
      'music_title': musicTitle,
      'album_art' : albumArt,
    };
  }

  @override
  String toString() {
    return 'Music{music_path: $musicPath, music_title: $musicTitle, album_art: $albumArt}';
  }

  static Music fromMap(Map<String, dynamic> map){
    List<int> coverArt;
    if (map['album_art'] == null){

    }
    else {
      var li = map['album_art'].map((m) {
        return m;
      }).toList();
      coverArt = List<int>.from(li);
      coverArt = Uint8List.fromList(coverArt);
    }
    return Music(
      musicTitle: map['music_title'],
      musicPath: map['music_path'],
      albumArt: coverArt
    );
  }

}