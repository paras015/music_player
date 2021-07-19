import 'dart:typed_data';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/song_player/bloc/player_bloc.dart';
import 'package:music_player/song_player/bloc/player_events.dart';
import 'package:music_player/song_player/bloc/player_state.dart';
import 'package:music_player/song_player/UI/Marquee.dart';

class CollapsedPlayer extends StatefulWidget{
  final controller;

  CollapsedPlayer({@required this.controller});

  @override
  State<StatefulWidget> createState() => _CollapsedPlayer();
}

class _CollapsedPlayer extends State<CollapsedPlayer>{
  Widget playPauseButton;
  PaletteGenerator paletteGenerator;

  Future<PaletteGenerator> getDominantColor(Uint8List albumArt) async {
    if (albumArt == null){
      paletteGenerator = await PaletteGenerator.fromImageProvider(Image.asset('images/default.png').image);
    }
    else {
      try{
        paletteGenerator = await PaletteGenerator.fromImageProvider(MemoryImage(albumArt));
      }
      catch(e) {
        print("No Palette");
      }
    }
    return paletteGenerator;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<MusicPlayerBloc>(context),
        builder: (context, songState){
          if (songState is SongPlaying){
            if (songState.songStatus == 1){
              playPauseButton = Icon(Icons.pause);
            }
            else{
              playPauseButton = Icon(Icons.play_arrow);
            }
            return GestureDetector(
              onTap: () async {
                await widget.controller.open();
              },
              onHorizontalDragEnd: (DragEndDetails details){
                if (details.primaryVelocity < 100){
                  BlocProvider.of<MusicPlayerBloc>(context).add(PlaySong(songState.songsList, songState.index + 1));
                }
                if (details.primaryVelocity > -100){
                  if (songState.index != 0){
                    BlocProvider.of<MusicPlayerBloc>(context).add(PlaySong(songState.songsList, songState.index - 1));
                  }
                  else{
                    BlocProvider.of<MusicPlayerBloc>(context).add(PlaySong(songState.songsList, songState.index));
                  }
                }
              },
              child: FutureBuilder(
                future: getDominantColor(songState.currentSong.albumArt),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  var dominant, light, coverImage;
                  try{
                    dominant = snapshot.data.dominantColor.color;
                    light = snapshot.data.lightMutedColor.color;
                  }
                  catch (e){
                    dominant = Colors.white;
                    light = Colors.black;
                  }
                  if (songState.currentSong.albumArt == null){
                    coverImage = Image.asset(
                    'images/default.png',
                    fit: BoxFit.fitHeight,
                    );
                  }
                  else {
                    coverImage = Image.memory(
                      songState.currentSong.albumArt,
                      fit: BoxFit.fitHeight,
                    );
                  }
                  return Container(
                    color: dominant,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: coverImage,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: MarqueeWidget(
                                direction: Axis.horizontal,
                                child: Text(
                                  songState.currentSong.musicTitle,
                                  style: TextStyle(
                                    color: light,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            iconSize: MediaQuery.of(context).size.width / 10,
                            icon: playPauseButton,
                            color: light,
                            onPressed: (){
                              if (songState.songStatus == 1){
                                BlocProvider.of<MusicPlayerBloc>(context).add(PauseSong(songState.songsList, songState.index));
                              }
                              else if (songState.songStatus == 2){
                                BlocProvider.of<MusicPlayerBloc>(context).add(ResumeSong(songState.songsList, songState.index));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          else{
            return Center(
              child: Text(
                "Play any song to see the player",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            );
          }
        }
    );
  }
}