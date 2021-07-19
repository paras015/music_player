import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/search_and_list_songs/UI/songs_list.dart';
import 'package:music_player/search_and_list_songs/bloc/music_search_state.dart';
import 'package:music_player/search_and_list_songs/bloc/search_music_bloc.dart';
import 'package:music_player/song_player/UI/song_player_UI.dart';
import 'package:music_player/song_player/bloc/player_bloc.dart';
import 'package:music_player/song_player/bloc/player_state.dart';

void main() {
  runApp(MusicApp());
}

class MusicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _musicBloc = MusicSearchBloc(InitApp());
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) => _musicBloc,
        ),
        BlocProvider(
            create: (BuildContext context) => MusicPlayerBloc(InitPlayer())
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/' : (context) => HomePage(title: 'Home Page',),
          '/player' : (context) => SongPlayer(),
        },
      ),
    );
  }
}


