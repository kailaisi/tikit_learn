import 'package:flutter_tiktok/mock/video.dart';
import 'package:flutter_tiktok/pages/cameraPage.dart';
import 'package:flutter_tiktok/pages/followPage.dart';
import 'package:flutter_tiktok/pages/searchPage.dart';
import 'package:flutter_tiktok/pages/userPage.dart';
import 'package:flutter_tiktok/views/shareBottomSHeet.dart';
import 'package:flutter_tiktok/views/tikTokCommentBottomSheet.dart';
import 'package:flutter_tiktok/views/tikTokHeader.dart';
import 'package:flutter_tiktok/views/tikTokScaffold.dart';
import 'package:flutter_tiktok/views/tikTokVideo.dart';
import 'package:flutter_tiktok/views/tikTokVideoButtonColumn.dart';
import 'package:flutter_tiktok/views/tikTokVideoPlayer.dart';
import 'package:flutter_tiktok/views/tiktokTabBar.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safemap/safemap.dart';

import 'msgPage.dart';

/// 单独修改了bottomSheet组件的高度
import 'package:flutter_tiktok/other/bottomSheet.dart' as CustomBottomSheet;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  //当前显示的页面
  TikTokPageTag tabBarType = TikTokPageTag.home;

  TikTokScaffoldController tkController = TikTokScaffoldController();

  PageController _pageController = PageController();
  //视频控制器
  VideoListController _videoListController = VideoListController();

  /// 记录点赞。int是视频的id，boolean是点赞的状态
  Map<int, bool> favoriteMap = {};
// 视频列表
  List<UserVideo> videoDataList = [];

  ///生命周期变化时回调
//  resumed:应用可见并可响应用户操作
//  inactive:用户可见，但不可响应用户操作
//  paused:已经暂停了，用户不可见、不可操作
//  suspending：应用被挂起，此状态IOS永远不会回调
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) {
      _videoListController.currentPlayer.pause();
    }
  }

  @override
  void dispose() {
    //监听生命周期
    WidgetsBinding.instance.removeObserver(this);
    _videoListController.currentPlayer.pause();
    super.dispose();
  }

  @override
  void initState() {
    videoDataList = UserVideo.fetchVideo();
    WidgetsBinding.instance.addObserver(this);
    _videoListController.init(
      _pageController,
      videoDataList,
    );
    tkController.addListener(
      () {
        //监听当前页面是否是在显示
        if (tkController.value == TikTokPagePositon.middle) {
          _videoListController.currentPlayer.start();
        } else {
          _videoListController.currentPlayer.pause();
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (tabBarType) {
      case TikTokPageTag.home:
        break;
      case TikTokPageTag.follow:
        currentPage = FollowPage();
        break;
      case TikTokPageTag.msg:
        currentPage = MsgPage();
        break;
      case TikTokPageTag.me:
        currentPage = UserPage(isSelfPage: true);
        break;
    }
    //设备的屏幕的宽高比例
    double a = MediaQuery.of(context).size.aspectRatio;
    bool hasBottomPadding = a < 0.55;
    //根据屏幕的宽高比例，判断是否有背景色
    bool hasBackground = hasBottomPadding;
    hasBackground = tabBarType != TikTokPageTag.home;
    if (hasBottomPadding) {
      hasBackground = true;
    }
    //底部的导航栏
    Widget tikTokTabBar = TikTokTabBar(
      hasBackground: hasBackground,
      current: tabBarType,
      //底部切换的回调
      onTabSwitch: (type) async {
        setState(() {
          tabBarType = type;
          if (type == TikTokPageTag.home) {
            _videoListController.currentPlayer.start();
          } else {
            _videoListController.currentPlayer.pause();
          }
        });
      },
      //点击+按钮
      onAddButton: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => CameraPage(),
          ),
        );
      },
    );
    //右滑页面
    var userPage = UserPage(
      isSelfPage: false,
      canPop: true,
      onPop: () {
        tkController.animateToMiddle();
      },
    );
    //左划页面
    var searchPage = SearchPage(
      onPop: tkController.animateToMiddle,
    );
    //顶部的导航，根据显示的不同的页面，进行显示处理
    var header = tabBarType == TikTokPageTag.home
        ? TikTokHeader(
            onSearch: () {
              tkController.animateToLeft();
            },
          )
        : Container();

    // 组合
    return TikTokScaffold(
      controller: tkController,
      hasBottomPadding: hasBackground,
      tabBar: tikTokTabBar,
      header: header,
      leftPage: searchPage,
      rightPage: userPage,
      enableGesture: tabBarType == TikTokPageTag.home,
      // onPullDownRefresh: _fetchData,
      page: Stack(
        // index: currentPage == null ? 0 : 1,
        children: <Widget>[
          PageView.builder(
            //可以左右滑动的轮播图
            key: Key('home'),
            controller: _pageController,
            pageSnapping: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical, //方向，垂直滑动
            itemCount: _videoListController.videoCount, //数量
            itemBuilder: (context, i) {
              // 组装每一个视频组件出来
              var data = videoDataList[i];
              //是否点赞
              bool isF = SafeMap(favoriteMap)[i].boolean ?? false;
              var player = _videoListController.playerOfIndex(i);
              // 右侧按钮列
              Widget buttons = TikTokButtonColumn(
                isFavorite: isF,
                onAvatar: () {
                  tkController.animateToPage(TikTokPagePositon.right);
                },
                onFavorite: () {
                  setState(() {
                    favoriteMap[i] = !isF;
                  });
                  showAboutDialog(context: context);
                },
                onComment: () {
                  //评论
                  CustomBottomSheet.showModalBottomSheet(
                    backgroundColor: Colors.white.withOpacity(0),
                    context: context,
                    builder: (BuildContext context) =>
                        TikTokCommentBottomSheet(),
                  );
                },
                onShare: () {
                  CustomBottomSheet.showModalBottomSheet(
                    context: context,
                    builder: (context) => ShareedBottomSheet(),
                  );
                },
              );
              // video
              Widget currentVideo = Center(
                child: FijkView(
                  fit: FijkFit.fitHeight,
                  player: player,
                  color: Colors.black,
                  panelBuilder: (_, __, ___, ____, _____) => Container(),
                ),
              );

              currentVideo = TikTokVideoPage(
                hidePauseIcon: player.state != FijkState.paused,
                aspectRatio: 9 / 16.0,
                key: Key(data.url + '$i'),
                tag: data.url,
                bottomPadding: hasBottomPadding ? 16.0 : 16.0,
                //视频用户信息
                userInfoWidget: VideoUserInfo(
                  desc: data.desc,
                  bottomPadding: hasBottomPadding ? 16.0 : 50.0,
                  // onGoodGift: () => showDialog(
                  //   context: context,
                  //   builder: (_) => FreeGiftDialog(),
                  // ),
                ),
                onSingleTap: () async {
                  if (player.state == FijkState.started) {
                    await player.pause();
                  } else {
                    await player.start();
                  }
                  setState(() {});
                },
                onAddFavorite: () {
                  setState(() {
                    favoriteMap[i] = true;
                  });
                },
                rightButtonColumn: buttons,
                video: currentVideo,
              );
              return currentVideo;
            },
          ),
          Opacity(
            opacity: 1,
            child: currentPage ?? Container(),
          ),
          // Center(
          //   child: Text(_currentIndex.toString()),
          // )
        ],
      ),
    );
  }
}
