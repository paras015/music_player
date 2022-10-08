import 'dart:io';
import 'dart:typed_data';
import 'package:music_player/data/music.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Directory newDir;
var musicList = [];
bool storagePermission = false;

Future<Database> getDatabaseConnection() async {
  Database database;
  if (database == null){
    database = await openDatabase(join(await getDatabasesPath(), 'songs_sql.db'),
                                  onCreate: (db, version){
                                    return db.execute(
                                      'CREATE TABLE all_songs(musicPath TEXT PRIMARY KEY, musicTitle TEXT, albumArt BLOB)',
                                    );
                                  },
                                  version: 1
                                  );
  }
  return database;
}

void closeConnection(Database database) async {
  var db = database;
  db.close();
  print("Connection closed");
}

Future<void> insertRecordInDatabase(Music music, Database database) async {
  await database.insert(
    'all_songs',
    music.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> insertMusic(List<dynamic> songsList, Database database) async {
  for (int k = 0; k < songsList.length; k++){
    print(songsList[k]);
    var retriever = new MetadataRetriever();
    var parts = songsList.elementAt(k).split('/');
    Uint8List cover;
    try{
      await retriever.setFile(new File(songsList.elementAt(k)));
      cover = retriever.albumArt;
      cover = await FlutterImageCompress.compressWithList(
        cover,
        quality: 25,
      );
    }
    catch (e){
      print("No cover");
    }
    var music = Music(
      musicPath: songsList.elementAt(k),
      musicTitle: parts[parts.length - 1].trim(),
      albumArt: cover,
    );
    await insertRecordInDatabase(music, database);
  }
  emptyList();
}


Future<List> getRootDirectory() async{
  var status = await Permission.storage.request();
  if (status.isGranted) {
    newDir = Directory('/storage');
    storagePermission = true;
    return newDir.listSync();
  }
  else {
    storagePermission = false;
    return [];
  }
}

List<dynamic> getSongsPath(){
  return musicList;
}

void emptyList(){
  musicList = [];
}

Future<void> findFiles(var itemList) async {
  if (storagePermission){
    var tempList;
    for (int i = 0; i < itemList.length; i++){
      if (itemList.elementAt(i).runtimeType.toString() == "_Directory"){
        try{
          if (itemList.elementAt(i).path == "/storage/emulated"){
            newDir = Directory(itemList.elementAt(i).path + "/0");
          }
          else{
            newDir = Directory(itemList.elementAt(i).path);
          }
          tempList = newDir.listSync();
          var findMusic = newDir.listSync().map((item) => item.path).where((
              item) => item.endsWith(".mp3")).toList();
          musicList = musicList + findMusic;
          findFiles(tempList);
        }
        catch(e){
          print("Directory not accessible - " + itemList.elementAt(i).path);
        }
      }
    }
  }
}

Future<List<dynamic>> getMusic(Database database) async {
  try{
    var result = await database.query('all_songs', orderBy: 'musicTitle ASC');
    return List.generate(result.length, (i) {
      return Music(
        musicPath: result[i]['musicPath'],
        musicTitle: result[i]['musicTitle'],
        albumArt: result[i]['albumArt'],
      );
    });
  }
  catch(e){
    print(e);
    return [];
  }

}

