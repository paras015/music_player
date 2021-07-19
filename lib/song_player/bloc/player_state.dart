import 'package:equatable/equatable.dart';
import 'package:music_player/data/music.dart';

abstract class MusicPlayerState extends Equatable{
  @override
  List<Object> get props => [];
}

class InitPlayer extends MusicPlayerState{
  @override
  String toString() => 'InitPlayer';
}

class SongPlaying extends MusicPlayerState{
  final Music currentSong;
  final songsList;
  final int index;
  final songStatus;
  SongPlaying(this.currentSong, this.songsList, this.index, this.songStatus);
  @override
  List<Object> get props => [currentSong, songsList, index, songStatus];
  @override
  String toString() => 'SongPlaying - ${currentSong.musicTitle}';
}