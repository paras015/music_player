import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/search_songs/search_music_bloc.dart';
import 'search_songs/music_search_event.dart';
import 'search_songs/music_search_state.dart';

void main() {
  runApp(MusicApp());
}

class MusicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _musicBloc = MusicSearchBloc(InitApp());
  @override
  Widget build(BuildContext context) {
    ScrollController _controller = ScrollController(keepScrollOffset: false);
    return Scaffold(
      backgroundColor: Colors.white30,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: BlocBuilder(
          bloc: _musicBloc,
          builder: (context, MusicSearchState state){
            if (state is InitApp){
              _musicBloc.add(InitAppSearch());
              return CircularProgressIndicator();
            }
            else if (state is SearchStateSuccess) {
              return RefreshIndicator(
                onRefresh: (){
                  return Future.delayed(
                    Duration(seconds: 1),
                    (){
                      _musicBloc.add(SearchButtonPressed());
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
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: MediaQuery.of(context).size.width * 0.1
                        );
                      }
                      else{
                        cover = Image.memory(
                          state.songs[index].albumArt,
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: MediaQuery.of(context).size.width * 0.1
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            padding: EdgeInsets.all(0),
                          ),
                          onPressed: () {print(state.songs[index].musicTitle);},
                          child: ListTile(
                            leading: cover,
                            title: Text(
                              state.songs[index].musicTitle,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
                    onPressed: () {_musicBloc.add(SearchButtonPressed());},
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
    );
  }
}
