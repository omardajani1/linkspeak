import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/common/chatProfileImage.dart';

class NewFlareLikes extends StatefulWidget {
  final String userName;
  final String collectionID;
  final String flareID;
  final DateTime date;
  const NewFlareLikes(
      {required this.userName,
      required this.collectionID,
      required this.date,
      required this.flareID});

  @override
  _NewFlareLikesState createState() => _NewFlareLikesState();
}

class _NewFlareLikesState extends State<NewFlareLikes> {
  final TapGestureRecognizer _recognizer = TapGestureRecognizer();

  @override
  void dispose() {
    super.dispose();
    _recognizer.dispose();
  }

  void _goToFlare(String myUsername) {
    final args = SingleFlareScreenArgs(
        flarePoster: myUsername,
        collectionID: widget.collectionID,
        flareID: widget.flareID,
        isComment: true,
        isLike: true,
        section: Section.multiple,
        singleCommentID: '');
    Navigator.pushNamed(context, RouteGenerator.singleFlareScreen,
        arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    final myUsername = context.read<MyProfile>().getUsername;
    void _visitProfile({required final String username}) {
      if ((username == myUsername)) {
      } else {
        final OtherProfileScreenArguments args =
            OtherProfileScreenArguments(otherProfileId: username);
        Navigator.pushNamed(
          context,
          (username == myUsername)
              ? RouteGenerator.myProfileScreen
              : RouteGenerator.posterProfileScreen,
          arguments: args,
        );
      }
    }

    _recognizer.onTap = () => _visitProfile(username: widget.userName);
    return ListTile(
      onTap: () {
        _goToFlare(myUsername);
      },
      enabled: true,
      key: UniqueKey(),
      leading: GestureDetector(
        onTap: () => _visitProfile(username: widget.userName),
        child: ChatProfileImage(
          username: '${widget.userName}',
          factor: 0.05,
          inEdit: false,
          asset: null,
          editUrl: '',
        ),
      ),
      title: RichText(
        softWrap: true,
        text: TextSpan(
          children: [
            TextSpan(
              recognizer: _recognizer,
              text: '${widget.userName} ',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: 'liked your flare',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      trailing: Text(
        General.timeStamp(widget.date),
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
