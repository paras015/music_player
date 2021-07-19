import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/song_player/bloc/player_events.dart';
import 'package:music_player/song_player/bloc/player_state.dart';
import 'package:audioplayers/audioplayers.dart';

AudioPlayer audioPlayer = AudioPlayer(playerId: 'musicPlayer');
class MusicPlayerBloc extends Bloc<MusicPlayerEvent, MusicPlayerState>{
  MusicPlayerBloc(MusicPlayerState initialState) : super(initialState);

  MusicPlayerBloc get initialState => initialState;

  @override
  void onTransition(Transition<MusicPlayerEvent, MusicPlayerState> transition) {
    print(transition);
    super.onTransition(transition);
  }

  Stream<MusicPlayerState> mapEventToState(MusicPlayerEvent event) async* {
    if (event is PlaySong){
      playSelectedSong(event.songsList, event.index);
      yield SongPlaying(event.songsList[event.index], event.songsList, event.index, 1);
    }
    if (event is PauseSong){
      await pauseSelectedSong();
      yield SongPlaying(event.songsList[event.index], event.songsList, event.index, audioPlayer.state.index);
    }
    if (event is ResumeSong){
      await resumeSelectedSong();
      yield SongPlaying(event.songsList[event.index], event.songsList, event.index, audioPlayer.state.index);
    }
  }

  Future<void> playSelectedSong(List<dynamic> songsList, int index) async {
    await audioPlayer.stop();
    int result = await audioPlayer.play(songsList[index].musicPath);
    if (result == 1){
    }
    audioPlayer.onPlayerCompletion.listen((event) async {
      int result = await audioPlayer.play(songsList[index + 1].musicPath);
    });
  }

  Future<void> pauseSelectedSong() async {
    await audioPlayer.pause();
  }

  Future<void> resumeSelectedSong() async {
    await audioPlayer.resume();
  }
}

class MusicPlayTime extends StatefulWidget{
  final playerTheme;
  const MusicPlayTime({@required this.playerTheme});
  @override
  State<StatefulWidget> createState() => _MusicPlayTime();
}

class _MusicPlayTime extends State<MusicPlayTime>{
  Duration _duration = Duration(milliseconds: 0);
  Duration _position = Duration(milliseconds: 0);
  @override
  void initState(){
    audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        _duration = event;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((pos) {
      setState(() {
        _position = pos;
      });
    });
  }
  Duration length;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_position.inHours}:${_position.inMinutes.remainder(60)}:${(_position.inSeconds.remainder(60))}",
              style: TextStyle(
                color: widget.playerTheme,
              ),
            ),
            Text(
              "${_duration.inHours}:${_duration.inMinutes.remainder(60)}:${(_duration.inSeconds.remainder(60))}",
              style: TextStyle(
                color: widget.playerTheme,
              ),
            ),
          ],
        ),
        Slider(
          value: _position.inMilliseconds.toDouble(),
          min: 0,
          max: _duration.inMilliseconds.toDouble(),
          onChanged: (double a) async {
            await audioPlayer.seek(Duration(milliseconds: a.toInt()));
          },
        ),
      ],
    );
  }

}
