import 'dart:io';
import 'package:music_player/music.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

Directory newDir;
var musicList = [];
bool storagePermission = false;

Future<Database> getDatabaseConnection() async {
  Database database;
  if (database == null){
    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    var dbPath = join(dir.path, 'songs_nosql.db');
    DatabaseFactory dbFactory = databaseFactoryIo;
    database = await dbFactory.openDatabase(dbPath);
    print("Connection done");
  }
  return database;
}

void closeConnection(Database database) async {
  var db = database;
  db.close();
  print("Connection closed");
}

Future<void> insertRecordInDatabase(Music music, StoreRef dataStore, Database database) async {
  await dataStore.record(music.musicPath).put(database, music.toMap());
}

Future<StoreRef> getStore(Database database) async {
  var dataStoreFac = StoreRef<String, Map<String, Object>>.main();
  return dataStoreFac;
}

Future<void> insertMusic(List<dynamic> songsList, StoreRef dataStoreFac, Database database) async {
  for (int k = 0; k < songsList.length; k++){
    var retriever = new MetadataRetriever();
    var parts = songsList.elementAt(k).split('/');
    var cover;
    try{
      await retriever.setFile(new File(songsList.elementAt(k)));
      cover = retriever.albumArt;
    }
    catch (e){
      print("No cover");
    }
    var music = Music(
      musicPath: songsList.elementAt(k),
      musicTitle: parts[parts.length - 1].trim(),
      albumArt: cover,
    );
    await insertRecordInDatabase(music, dataStoreFac, database);
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
        // if (itemList.elementAt(i).path == "/storage/6562-3037/.android_secure" || itemList.elementAt(i).path == "/storage/self"){
        //   continue;
        // }
        // if (itemList.elementAt(i).path == "/storage/emulated"){
        //   newDir = Directory(itemList.elementAt(i).path + "/0");
        // }
        // else{
        //   newDir = Directory(itemList.elementAt(i).path);
        // }
      }
    }
  }
}

Future<List<dynamic>> getMusic(StoreRef dataStore, Database database) async {
  final finder = Finder(sortOrders: [
    SortOrder('music_title'),
  ]);
  final result = await dataStore.find(
    database,
    finder: finder,
  );
  var record = result.map((item){
    var music = Music.fromMap(item.value);
    return music;
  }).toList();
  return record;
}

