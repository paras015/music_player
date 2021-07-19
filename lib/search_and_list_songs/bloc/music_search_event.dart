import 'package:equatable/equatable.dart';

abstract class MusicSearchEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class InitAppSearch extends MusicSearchEvent{
  @override
  String toString() => "InitAppSearch";
}

class SearchButtonPressed extends MusicSearchEvent{
  @override
  String toString() => "SearchButtonPressed";
}
