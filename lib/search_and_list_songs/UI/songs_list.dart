import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/search_and_list_songs/UI/collapsed_player.dart';
import 'package:music_player/search_and_list_songs/bloc/search_music_bloc.dart';
import 'package:music_player/search_and_list_songs/bloc/music_search_event.dart';
import 'package:music_player/search_and_list_songs/bloc/music_search_state.dart';
import 'package:music_player/song_player/UI/song_player_UI.dart';
import 'package:music_player/song_player/bloc/player_bloc.dart';
import 'package:music_player/song_player/bloc/player_events.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _controller = ScrollController(keepScrollOffset: false);
  PanelController _pc = PanelController();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white30,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: BlocBuilder(
              bloc: BlocProvider.of<MusicSearchBloc>(context),
              builder: (context, MusicSearchState state){
                if (state is InitApp){
                  BlocProvider.of<MusicSearchBloc>(context).add(InitAppSearch());
                  return CircularProgressIndicator();
                }
                else if (state is SearchStateSuccess) {
                  bool isPlayerOpen = false;
                  return WillPopScope(
                    onWillPop: () async {
                      if (isPlayerOpen){
                        await _pc.close();
                        return false;
                      }
                      else{
                        return true;
                      }
                    },
                    child: SlidingUpPanel(
                      controller: _pc,
                      onPanelOpened: (){
                        isPlayerOpen = true;
                      },
                      onPanelClosed: (){
                        isPlayerOpen = false;
                      },
                      minHeight: MediaQuery.of(context).size.height / 12,
                      maxHeight: MediaQuery.of(context).size.height,
                      backdropEnabled: true,
                      collapsed: CollapsedPlayer(controller: _pc,),
                      panel: SongPlayer(),
                      body: RefreshIndicator(
                        onRefresh: (){
                          return Future.delayed(
                              Duration(seconds: 1),
                                  (){
                                    BlocProvider.of<MusicSearchBloc>(context).add(SearchButtonPressed());
                              }
                          );
                        },
                        child: DraggableScrollbar.semicircle(
                          labelTextBuilder: (offset) {
                            final int currentItem = _controller.hasClients
                                ? (_controller.offset / _controller.position.maxScrollExtent * state.songs.length).floor()
                                : 0;

                            return Text("$currentItem");
                          },
                          controller: _controller,
                          child: ListView.builder(
                            controller: _controller,
                            itemCount: state.songs.length,
                            itemBuilder: (context, index){
                              Widget cover;
                              if (state.songs[index].albumArt == null){
                                cover = Image.asset(
                                    'images/default.png',
                                    fit: BoxFit.contain,
                                );
                              }
                              else{
                                cover = Image.memory(
                                    state.songs[index].albumArt,
                                    fit: BoxFit.cover,
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(1, 5, 1, 5),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                    padding: EdgeInsets.all(0),
                                  ),
                                  onPressed: () async {
                                    BlocProvider.of<MusicPlayerBloc>(context).add(PlaySong(state.songs, index));
                                    await _pc.open();
                                  },
                                  onLongPress: (){
                                    BlocProvider.of<MusicPlayerBloc>(context).add(PauseSong(state.songs, index));
                                  },
                                  child: ListTile(
                                    leading: cover,
                                    title: Text(
                                      state.songs[index].musicTitle,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                }
                else if (state is SearchStateLoading){
                  return CircularProgressIndicator();
                }
                else if (state is SearchStateEmpty){
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children : [
                      Text(("Empty. Try searching for songs")),
                      ElevatedButton(
                        onPressed: () {BlocProvider.of<MusicSearchBloc>(context).add(SearchButtonPressed());},
                        child: Text(("Search")),
                      )
                    ],
                  );
                }
                else {
                  return Center(child: Text(("Error")));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}