import 'package:equatable/equatable.dart';

abstract class MusicSearchState extends Equatable{
  @override
  List<Object> get props => [];
}

class InitApp extends MusicSearchState{
  @override
  String toString() => 'InitApp';
}

class SearchStateEmpty extends MusicSearchState{
  @override
  String toString() => 'SearchStateEmpty';
}

class SearchStateLoading extends MusicSearchState{
  @override
  String toString() => 'SearchStateLoading';
}

class SearchStateSuccess extends MusicSearchState{
  final List<dynamic> songs;
  SearchStateSuccess(this.songs);
  @override
  List<Object> get props => [songs];
  @override
  String toString() => 'SearchStateSuccess { songs: ${songs.length} }';
}