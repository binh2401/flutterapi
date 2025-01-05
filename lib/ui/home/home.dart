import 'package:demonhac/ui/discovery/discovery.dart';
import 'package:demonhac/ui/home/viewmodel.dart';
import 'package:demonhac/ui/now_playing/audioplayer_manager.dart';
import 'package:demonhac/ui/setting/setting.dart';
import 'package:demonhac/ui/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/song.dart';
import '../now_playing/playing.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Music'),
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.find_in_page), label: 'Discovery'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  List<Song> filteredSongs = [];
  late MusicAppViewModel _viewModel;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSong();
    observeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Tìm bài hát...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            filterSongs(value);
          },
        ),
      ),
      body: getBody(),
    );
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    AudioPlayerManager().dispose();
    searchController.dispose();
    super.dispose();
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: filteredSongs.length,
      shrinkWrap: true,
    );
  }

  Widget getRow(int index) {
    return _songItemSection(
      parent: this,
      song: filteredSongs[index],
    );
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs = songList;
        filteredSongs = songList;
      });
    });
  }

  void filterSongs(String query) {
    setState(() {
      filteredSongs = songs
          .where((song) =>
      song.ten.toLowerCase().contains(query.toLowerCase()) ||
          song.tacgia.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 400,
              color: Colors.grey,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('Modal Bottom Sheet'),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close Bottom Sheet'),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void navigate(Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(
        songs: songs,
        playingSong: song,
      );
    }));
  }
}

class _songItemSection extends StatelessWidget {
  const _songItemSection({
    required this.parent,
    required this.song,
  });

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    String imageUrl = 'http://10.0.2.2:8080${song.imagePath}';

    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 24,
        right: 8,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/itunes.png',
              width: 48,
              height: 48,
            );
          },
        ),
      ),
      title: Text(song.ten),
      subtitle: Text(song.tacgia),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {
          parent.showBottomSheet();
        },
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }
}
