import 'package:flutter/material.dart';

class ShareedBottomSheet extends StatelessWidget {
  const ShareedBottomSheet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        ListTile(
          title: Text("分享到朋友圈"),
          leading: Icon(Icons.share),
        ),
        ListTile(
          title: Text("分享给朋友"),
          leading: Icon(Icons.share),
        ),
        ListTile(
          title: Text("生成海报"),
          leading: Icon(Icons.share),
        ),
      ],
    ));
  }
}
