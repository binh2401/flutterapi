import 'dart:convert';
import 'package:demonhac/data/model/song.dart';
import 'package:http/http.dart' as http;
abstract interface class Datasource{
  Future<List<Song>?> loadData();
}

class RemoteDatasource implements Datasource {
  @override
  Future<List<Song>?> loadData() async {
    final url = 'http://10.0.2.2:8080/api/nhac';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final bodyContent = utf8.decode(response.bodyBytes);
        var songList = jsonDecode(bodyContent);

        // Kiểm tra nếu API trả về một đối tượng duy nhất hoặc một danh sách
        if (songList is List) {
          List<Song> songs = songList.map((song) => Song.fromJson(song)).toList();
          return songs;
        } else if (songList is Map) {
          // Ép kiểu Map<dynamic, dynamic> thành Map<String, dynamic>
          Map<String, dynamic> songMap = songList.cast<String, dynamic>();
          List<Song> songs = [Song.fromJson(songMap)];
          return songs;
        } else {
          throw Exception('Dữ liệu không đúng định dạng');
        }
      } catch (e) {
        print('Lỗi khi phân tích cú pháp JSON: $e');
        return null;
      }
    } else {
      print('Lỗi API: ${response.statusCode}');
      return null;
    }
  }
}



class localDataSource implements Datasource {
  @override
  Future<List<Song>?> loadData(){
    throw throw UnimplementedError();
  }
}