import 'dart:typed_data';

class Music{
  int id;
  String musicPath;
  String musicTitle;
  Uint8List albumArt;

  Music({this.musicPath, this.musicTitle, this.albumArt});

  Map<String, dynamic> toMap() {
    return {
      'musicPath': musicPath,
      'musicTitle': musicTitle,
      'albumArt' : albumArt,
    };
  }

  @override
  String toString() {
    return 'Music{musicPath: $musicPath, musicTitle: $musicTitle, albumArt: $albumArt}';
  }

  static Music fromMap(Map<String, dynamic> map){
    List<int> coverArt;
    if (map['albumArt'] == null){

    }
    else {
      var li = map['albumArt'].map((m) {
        return m;
      }).toList();
      coverArt = List<int>.from(li);
      coverArt = Uint8List.fromList(coverArt);
    }
    return Music(
      musicTitle: map['musicTitle'],
      musicPath: map['musicPath'],
      albumArt: coverArt
    );
  }

}