import 'package:equatable/equatable.dart';

abstract class MusicPlayerEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class PlaySong extends MusicPlayerEvent{
  final songsList;
  final index;
  PlaySong(this.songsList, this.index);
  @override
  List<Object> get props => [songsList, index];
  @override
  String toString() => "PlaySong";
}

class PauseSong extends MusicPlayerEvent{
  final songsList;
  final index;
  PauseSong(this.songsList, this.index);
  @override
  List<Object> get props => [songsList, index];
  @override
  String toString() => "PauseSong";
}

class ResumeSong extends MusicPlayerEvent{
  final songsList;
  final index;
  ResumeSong(this.songsList, this.index);
  @override
  List<Object> get props => [songsList, index];
  @override
  String toString() => "PauseSong";
}