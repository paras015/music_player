import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/search_songs/music_search_event.dart';
import 'package:music_player/search_songs/music_search_state.dart';
import 'package:music_player/database.dart';
import 'package:sembast/sembast.dart';

class MusicSearchBloc extends Bloc<MusicSearchEvent, MusicSearchState>{
  MusicSearchBloc(MusicSearchState initialState) : super(InitApp());

  MusicSearchState get initialState => InitApp();

  @override
  void onTransition(Transition<MusicSearchEvent, MusicSearchState> transition) {
    print(transition);
    super.onTransition(transition);
  }

  @override
  Stream<MusicSearchState> mapEventToState(MusicSearchEvent event) async* {
    print("------");
    print(event);
    yield* mapIncomingEventToState(event);
  }

  Stream<MusicSearchState> mapIncomingEventToState(MusicSearchEvent event) async* {
    yield SearchStateLoading();
    if (event is InitAppSearch){
      Database db = await getDatabaseConnection();
      var dataStore = await getStore(db);
      var musicList = await getMusic(dataStore, db);
      // closeConnection(db);
      if (musicList.isEmpty){
        yield SearchStateEmpty();
      }
      else{
        yield SearchStateSuccess(musicList);
      }
    }
    else if (event is SearchButtonPressed){
      Database db = await getDatabaseConnection();
      var itemList = await getRootDirectory();
      await findFiles(itemList);
      List<dynamic> list = getSongsPath();
      print(list.length);
      var dataStore = await getStore(db);
      await insertMusic(list, dataStore, db);
      var musicList = await getMusic(dataStore, db);
      print(musicList.length);
      // closeConnection(db);
      if (musicList.isEmpty){
        yield SearchStateEmpty();
      }
      else{
        yield SearchStateSuccess(musicList);
      }
    }
  }
}

