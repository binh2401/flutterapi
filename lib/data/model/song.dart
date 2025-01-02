class Song {
  String id;
  String ten;
  String tacgia;
  String theloai;
  String imagePath;
  String audioPath;

  // Constructor khởi tạo giá trị cho các trường non-nullable
  Song({
    required this.id,
    required this.ten,
    required this.tacgia,
    required this.theloai,
    required this.imagePath,
    required this.audioPath,
  });
  factory Song.fromJson(Map<String ,dynamic>map){
    return Song(
        id: map[ 'id'],
        ten: map[ 'ten'] ,
        tacgia: map[ 'tacgia'] ,
        theloai: map[ 'theloai'] ,
        imagePath: map[ 'imagePath'] ,
        audioPath: map[ 'audioPath'] ,
    );

  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song{id: $id, ten: $ten, tacgia: $tacgia, theloai: $theloai, imagePath: $imagePath, audioPath: $audioPath}';
  }
}