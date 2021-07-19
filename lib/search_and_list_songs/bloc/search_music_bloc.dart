import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/search_and_list_songs/bloc/music_search_event.dart';
import 'package:music_player/search_and_list_songs/bloc/music_search_state.dart';
import 'package:music_player/data/database.dart';
import 'package:sqflite/sqflite.dart';

class MusicSearchBloc extends Bloc<MusicSearchEvent, MusicSearchState>{
  MusicSearchBloc(MusicSearchState initialState) : super(initialState);

  MusicSearchState get initialState => initialState;

  @override
  void onTransition(Transition<MusicSearchEvent, MusicSearchState> transition) {
    print(transition);
    super.onTransition(transition);
  }

  @override
  Stream<MusicSearchState> mapEventToState(MusicSearchEvent event) async* {
    yield* mapIncomingEventToState(event);
  }

  Stream<MusicSearchState> mapIncomingEventToState(MusicSearchEvent event) async* {
    yield SearchStateLoading();
    if (event is InitAppSearch){
      Database db = await getDatabaseConnection();
      var musicList = await getMusic(db);
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
      await insertMusic(list, db);
      var musicList = await getMusic(db);
      print("Music found - ${musicList.length}");
      if (musicList.isEmpty){
        yield SearchStateEmpty();
      }
      else{
        yield SearchStateSuccess(musicList);
      }
    }
  }
}

