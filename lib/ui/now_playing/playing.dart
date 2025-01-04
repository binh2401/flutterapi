import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:demonhac/data/model/song.dart';
import 'package:demonhac/ui/now_playing/audioplayer_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
      songs: songs,
      playingSong: playingSong,
    );
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(
      {super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;
  bool _isShuffle = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _song = widget.playingSong;
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(microseconds: 12000),
    );
    String fullAudioUrl = 'http://10.0.2.2:8080${_song.audioPath}';
    _audioPlayerManager = AudioPlayerManager(songUrl: fullAudioUrl);
    _audioPlayerManager.init();
    
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    // Lấy đường dẫn hình ảnh đầy đủ
    String imageUrl = 'http://10.0.2.2:8080${_song.imagePath}';

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('now playing'),
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz),
        ),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_song.theloai),
              const SizedBox(height: 16),
              const Text('_ ___ _'),
              const SizedBox(height: 48),
              RotationTransition(
                turns:
                    Tween(begin: 0.0, end: 1.0).animate(_imageAnimController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/itunes.png',
                    image: imageUrl,
                    // Sử dụng imageUrl đã ghép
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/itunes.png',
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 64, bottom: 16),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.share_outlined),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Column(
                        children: [
                          Text(
                            _song.ten,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            _song.tacgia,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                          )
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_outline),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 32, left: 24, right: 24, bottom: 16),
                child: _progressbar(),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 0, left: 24, right: 24, bottom: 16),
                child: _mediaButtons(),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose(){
    _audioPlayerManager.dispose();
  }

  Widget _mediaButtons() {
    return  SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
              function: _setShuffle,
              icon: Icons.shuffle,
              color: _getShuffleColor(),
              size: 24),
          MediaButtonControl(
              function: _setPrevSong,
              icon: Icons.skip_previous,
              color: Colors.deepPurple,
              size: 36),
          _playButton(),
          MediaButtonControl(
              function: _setNextSong,
              icon: Icons.skip_next,
              color: Colors.deepPurple,
              size: 26),
          MediaButtonControl(
              function: null,
              icon: Icons.repeat,
              color: Colors.deepPurple,
              size: 24),
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressbar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationSate = snapshot.data;
          final progress = durationSate?.progress ?? Duration.zero;
          final buffered = durationSate?.buffered ?? Duration.zero;
          final total = durationSate?.total ?? Duration.zero;
          return ProgressBar(
            progress: progress,
            total: total,
            buffered: buffered,
            onSeek: _audioPlayerManager.player.seek,
            barHeight: 5.0,
            barCapShape: BarCapShape.round,
            baseBarColor: Colors.grey.withOpacity(0.3),
            progressBarColor: Colors.green,
            bufferedBarColor: Colors.green.withOpacity(0.3),
            thumbColor: Colors.deepPurple,
            thumbGlowColor: Colors.green.withOpacity(0.3),
            thumbRadius: 10.0,

          );
        });
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playsate = snapshot.data;
        final processingSate = playsate?.playing;
        final playing = playsate?.playing;
        if (processingSate == ProcessingState.loading ||
            processingSate == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.play();
              },
              icon: Icons.play_arrow,
              color: null,
              size: 48);
        } else if (processingSate != ProcessingState.completed) {
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.pause();
              },
              icon: Icons.pause,
              color: null,
              size: 48);
        } else {
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.seek(Duration.zero);
              },
              icon: Icons.replay,
              color: null,
              size: 48);
        }
      },
    );
  }

  void _setNextSong(){
   if(_isShuffle){
     var random =Random();
     _selectedItemIndex = random.nextInt(widget.songs.length );
   } else{
     ++_selectedItemIndex;
   }
   if(_selectedItemIndex >=  widget.songs.length){
     _selectedItemIndex =_selectedItemIndex  % widget.songs.length;
   }
    final nextSong= widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl('http://10.0.2.2:8080${nextSong.audioPath}');
    setState(() {
      _song = nextSong;
    });
  }

  void _setPrevSong(){
    if(_isShuffle){
      var random =Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else{
      --_selectedItemIndex;
    }
    if(_selectedItemIndex <  0){
      _selectedItemIndex = (-1 * _selectedItemIndex)  % widget.songs.length;
    }
    final nextSong= widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl('http://10.0.2.2:8080${nextSong.audioPath}');
    setState(() {
      _song = nextSong;
    });
  }

  void _setShuffle(){
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  Color? _getShuffleColor(){
    return _isShuffle ? Colors.deepPurple : Colors.grey;
  }
}



class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<MediaButtonControl> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon,
          size: widget.size,
          color: widget.color ?? Theme.of(context).colorScheme.primary),
    );
  }
}
