import 'package:demonhac/ui/discovery/discovery.dart';
import 'package:demonhac/ui/home/viewmodel.dart';
import 'package:demonhac/ui/setting/setting.dart';
import 'package:demonhac/ui/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../../data/model/song.dart';
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
      home: MusicHomePage(),
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
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Discovery'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Account'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Setting'),
          ],
        ),
        tabBuilder: (BuildContext contex, int index) {
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
  List<Song> songs =[];
  late MusicAppViewModel _viewModel;

  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSong();
    observeData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: getBody(),
    );
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    super.dispose();
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if(showLoading){
      return getProgressBar();
    }else{
      return getListView();
    }

  }
  Widget getProgressBar(){
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView getListView(){
    return ListView.separated(
        itemBuilder: (context, position){
          return getRow(position);
        },
        separatorBuilder: (context, index){
          return const Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 24,
            endIndent: 24,
          );
        },
        itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  Widget getRow(int index){
    return _songIteamSection(
      parent: this,
      song: songs[index],
    );
  }



  void observeData(){
    _viewModel.songStream.stream.listen((songList){
      setState(() {
        songs.addAll(songList);
      });
    });
  }
}

class _songIteamSection extends StatelessWidget{
  const _songIteamSection({
    required this.parent,
    required this.song,
});
  final _HomeTabPageState parent;
  final Song song;
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 24,
        right: 8,
      ),
      leading:ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/itunes.png',
          image: song.imagePath,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace){
            return Image.asset(
              'assets/itunes.png',
              width: 48,
              height: 48,
            );
          },
        ),
      ) ,
      title: Text(
        song.ten
      ),
      subtitle: Text(song.tacgia),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: (){},
      ),
    );
  }
}