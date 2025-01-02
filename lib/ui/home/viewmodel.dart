import 'dart:async';

import 'package:demonhac/data/model/song.dart';
import 'package:demonhac/data/reponsitory/reponsitory.dart';

class MusicAppViewModel {
  StreamController<List<Song>> songStream = StreamController();

  void loadSong(){
    final reponsitory = DefaultReponsitory();
    reponsitory.loadData().then((value) =>songStream.add(value!));
  }
}