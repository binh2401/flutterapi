
import 'package:demonhac/data/model/song.dart';
import 'package:demonhac/data/source/source.dart';

abstract interface class Reponsitory {
   Future<List<Song>?> loadData();
}

class DefaultReponsitory implements Reponsitory{
  final _localDataSource = localDataSource();
  final _remoteDataSource = RemoteDatasource();
  @override
  Future<List<Song>?> loadData() async {
    List<Song> songs = [];
    await _remoteDataSource.loadData().then((remoteSongs) {
      if (remoteSongs == null) {
        _localDataSource.loadData().then((locaSongs) {
          if (locaSongs != null) {
            songs.addAll(locaSongs);
          }
        });
      }else {
        songs.addAll(remoteSongs);
      }
    });
    return songs;
  }
}
