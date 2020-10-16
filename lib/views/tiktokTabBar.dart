import 'package:flutter_tiktok/style/style.dart';
import 'package:flutter_tiktok/views/selectText.dart';
import 'package:flutter/material.dart';

enum TikTokPageTag {
  home,
  follow,
  msg,
  me,
}

//底部的导航栏
class TikTokTabBar extends StatelessWidget {
  //底部切换
  final Function(TikTokPageTag) onTabSwitch;
  //点击+
  final Function() onAddButton;

  final bool hasBackground;
  //当前选中的数据
  final TikTokPageTag current;

  const TikTokTabBar({
    Key key,
    this.onTabSwitch,
    this.current,
    this.onAddButton,
    this.hasBackground: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //padding 为屏幕内边距，一般是刘海儿屏或异形屏中被系统遮挡部分边距；
    final EdgeInsets padding = MediaQuery.of(context).padding;
    print(padding.bottom);
    Widget row = Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            child: SelectText(
              isSelect: current == TikTokPageTag.home,
              title: '首页',
            ),
            onTap: () => onTabSwitch?.call(TikTokPageTag.home),
          ),
        ),
        Expanded(
          child: GestureDetector(
            child: SelectText(
              isSelect: current == TikTokPageTag.follow,
              title: '关注',
            ),
            onTap: () => onTabSwitch?.call(TikTokPageTag.follow),
          ),
        ),
        Expanded(
          child: GestureDetector(
            child: Icon(
              Icons.add_box,
              size: 32,
            ),
            onTap: () => onAddButton?.call(),
          ),
        ),
        Expanded(
          child: GestureDetector(
            child: SelectText(
              isSelect: current == TikTokPageTag.msg,
              title: '消息',
            ),
            onTap: () => onTabSwitch?.call(TikTokPageTag.msg),
          ),
        ),
        Expanded(
          child: GestureDetector(
            child: SelectText(
              isSelect: current == TikTokPageTag.me,
              title: '我',
            ),
            onTap: () => onTabSwitch?.call(TikTokPageTag.me),
          ),
        ),
      ],
    );
    return Container(
      //设置透明度
      color: hasBackground ? ColorPlate.back2 : ColorPlate.white,
      child: Container(
        padding: EdgeInsets.only(bottom: padding.bottom),
        height: 50 + padding.bottom,
        child: row,
      ),
    );
  }
}
