import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/song_player/bloc/player_bloc.dart';
import 'package:music_player/song_player/bloc/player_events.dart';
import 'package:music_player/song_player/bloc/player_state.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:music_player/song_player/UI/Marquee.dart';

class SongPlayer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SongPlayer();
}

class _SongPlayer extends State<SongPlayer>{
  Widget playPauseButtonIcon = Icon(Icons.pause);
  PaletteGenerator paletteGenerator;

  Future<PaletteGenerator> getDominantColor(Uint8List albumArt) async {
    if (albumArt == null){
      paletteGenerator = await PaletteGenerator.fromImageProvider(Image.asset('images/default.png').image);
    }
    else {
      paletteGenerator = await PaletteGenerator.fromImageProvider(MemoryImage(albumArt));
    }
    return paletteGenerator;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder(
        bloc: BlocProvider.of<MusicPlayerBloc>(context),
        builder: (context, state){
          if (state is SongPlaying){
            if (state.songStatus == 1){
              playPauseButtonIcon = Icon(Icons.pause);
            }
            else{
              playPauseButtonIcon = Icon(Icons.play_arrow);
            }
            Widget coverImage;
            if (state.currentSong.albumArt == null){
              coverImage = Image.asset(
                'images/default.png',
                fit: BoxFit.fitHeight,
              );
            }
            else{
              coverImage = Image.memory(
                state.currentSong.albumArt,
                fit: BoxFit.fitHeight,
              );
            }
            return FutureBuilder(
              future: getDominantColor(state.currentSong.albumArt),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                var dominant, light;
                try{
                  dominant = snapshot.data.dominantColor.color;
                  light = snapshot.data.lightMutedColor.color;
                }
                catch (e){
                  dominant = Colors.white;
                  light = Colors.black;
                }
                return Container(
                  color: dominant,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 1.75,
                          child: coverImage,
                        ),
                        SizedBox(height: 20,),
                        MarqueeWidget(
                          direction: Axis.horizontal,
                          child: Text(
                            state.currentSong.musicTitle,
                              style: TextStyle(
                                fontSize: 20,
                                color: light,
                              ),
                          )
                        ),
                        SizedBox(height: 20,),
                        MusicPlayTime(
                          playerTheme: light,
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              iconSize: MediaQuery.of(context).size.width / 5,
                              color: light,
                              icon: Icon(Icons.skip_previous),
                              onPressed: () {
                                if (state.index != 0) {
                                  BlocProvider.of<MusicPlayerBloc>(context).add(PlaySong(state.songsList, state.index - 1));
                                  playPauseButtonIcon = Icon(Icons.pause);
                                }
                                else{
                                  BlocProvider.of<MusicPlayerBloc>(context).add(PlaySong(state.songsList, state.index));
                                  setState(() {
                                    playPauseButtonIcon = Icon(Icons.pause);
                                  });
                                }
                              },
                            ),
                            IconButton(
                              iconSize: MediaQuery.of(context).size.width / 5,
                              color: light,
                              icon: playPauseButtonIcon,
                              onPressed: () {
                                if (state.songStatus == 1){
                                  BlocProvider.of<MusicPlayerBloc>(context).add(PauseSong(state.songsList, state.index));
                                }
                                else if (state.songStatus == 2){
                                  BlocProvider.of<MusicPlayerBloc>(context).add(ResumeSong(state.songsList, state.index));
                                }
                              },
                            ),
                            IconButton(
                              iconSize: MediaQuery.of(context).size.width / 5,
                              color: light,
                              icon: Icon(Icons.skip_next),
                              onPressed: () {
                                BlocProvider.of<MusicPlayerBloc>(context).add(PlaySong(state.songsList, state.index + 1));
                                playPauseButtonIcon = Icon(Icons.pause);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          else{
            return Center(
              child: Text(
                "Play any song to see the player",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            );
          }
        }
      ),
    );
  }
}

