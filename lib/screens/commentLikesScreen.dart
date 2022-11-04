import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/miniProfile.dart';
import '../providers/commentProvider.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/common/linkObject.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';

class CommentLikesScreen extends StatefulWidget {
  final dynamic instance;
  final dynamic postID;
  final dynamic commentID;
  final dynamic isClubPost;
  final dynamic clubName;
  const CommentLikesScreen({
    required this.instance,
    required this.postID,
    required this.commentID,
    required this.isClubPost,
    required this.clubName,
  });

  @override
  _CommentLikesScreenState createState() => _CommentLikesScreenState();
}

class _CommentLikesScreenState extends State<CommentLikesScreen> {
  final _scrollController = ScrollController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getReplies;
  bool isLoading = false;
  bool isLastPage = false;
  List<MiniProfile> replies = [];
  List<MiniProfile> cacheReplies = [];
  Future<void> getReplies(String myUsername, String myIMG) async {
    List<MiniProfile> tempReplies = [];
    final _myLike = firestore
        .collection('Posts')
        .doc(widget.postID)
        .collection('comments')
        .doc(widget.commentID)
        .collection('likes')
        .doc(myUsername);
    final _myDoc = await _myLike.get();
    if (_myDoc.exists) {
      final MiniProfile replier = MiniProfile(username: myUsername);
      tempReplies.add(replier);
    }
    final _currentPostAndComment = firestore
        .collection('Posts')
        .doc(widget.postID)
        .collection('comments')
        .doc(widget.commentID)
        .collection('likes')
        .limit(20);
    final repliesCollection = await _currentPostAndComment.get();
    final theReplies = repliesCollection.docs;
    if (theReplies.isNotEmpty) {
      for (var reply in theReplies) {
        final replierName = reply.id;
        final MiniProfile replier = MiniProfile(username: replierName);
        if (replierName != myUsername) {
          tempReplies.add(replier);
          cacheReplies.add(replier);
        }
      }
    }
    if (theReplies.length < 20) {
      isLastPage = true;
    }
    replies = [...tempReplies];
    setState(() {});
  }

  Future<void> getMoreReplies(String myUsername) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      List<MiniProfile> tempReplies = [];
      if (cacheReplies.isNotEmpty) {
        final lastReply = cacheReplies.last.username;
        final getLastReply = await firestore
            .collection('Posts')
            .doc(widget.postID)
            .collection('comments')
            .doc(widget.commentID)
            .collection('likes')
            .doc(lastReply)
            .get();
        final _currentPostAndComment = firestore
            .collection('Posts')
            .doc(widget.postID)
            .collection('comments')
            .doc(widget.commentID)
            .collection('likes')
            .startAfterDocument(getLastReply)
            .limit(20);
        final repliesCollection = await _currentPostAndComment.get();
        final theReplies = repliesCollection.docs;
        if (theReplies.isNotEmpty) {
          for (var reply in theReplies) {
            final replierName = reply.id;
            final MiniProfile replier = MiniProfile(username: replierName);
            if (replierName == myUsername) {
              cacheReplies.add(replier);
            } else {
              if (!cacheReplies
                  .any((element) => element.username == replierName)) {
                cacheReplies.add(replier);
                tempReplies.add(replier);
              }
            }
          }
        }
        replies.addAll(tempReplies);
        if (theReplies.length < 20) {
          isLastPage = true;
        }
        isLoading = false;
        setState(() {});
      } else {
        final _currentPostAndComment = firestore
            .collection('Posts')
            .doc(widget.postID)
            .collection('comments')
            .doc(widget.commentID)
            .collection('likes')
            .limit(20);
        final repliesCollection = await _currentPostAndComment.get();
        final theReplies = repliesCollection.docs.reversed;
        if (theReplies.isNotEmpty) {
          for (var reply in theReplies) {
            final replierName = reply.id;
            final MiniProfile replier = MiniProfile(username: replierName);
            if (replierName == myUsername) {
              cacheReplies.add(replier);
            } else {
              if (!cacheReplies
                  .any((element) => element.username == replierName)) {
                cacheReplies.add(replier);
                tempReplies.add(replier);
              }
            }
          }
        }
        if (theReplies.length < 20) {
          isLastPage = true;
        }
        replies.addAll(tempReplies);
        isLoading = false;
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    _getReplies = getReplies(myUsername, myIMG);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreReplies(myUsername);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String myIMG =
        Provider.of<MyProfile>(context, listen: false).getProfileImage;
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = General.widthQuery(context);
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    return FutureBuilder(
        future: _getReplies,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                      const SettingsBar('Likes'),
                      const Spacer(),
                      const CircularProgressIndicator(strokeWidth: 1.50),
                      const Spacer()
                    ])));

          if (snapshot.hasError)
            return Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                      const SettingsBar('Likes'),
                      const Spacer(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text('An error has occured, please try again',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15.0)),
                            const SizedBox(width: 10.0),
                            TextButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color?>(
                                        _primaryColor),
                                    padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                        const EdgeInsets.all(0.0)),
                                    shape: MaterialStateProperty.all<OutlinedBorder?>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0)))),
                                onPressed: () => setState(() {
                                      _getReplies =
                                          getReplies(myUsername, myIMG);
                                    }),
                                child: Center(
                                    child: Text('Retry',
                                        style: TextStyle(
                                            color: _accentColor,
                                            fontWeight: FontWeight.bold))))
                          ]),
                      const Spacer()
                    ])));

          return Builder(
              builder: (context) =>
                  ChangeNotifierProvider<FullCommentHelper>.value(
                      value: widget.instance,
                      child: Builder(builder: (context) {
                        Provider.of<FullCommentHelper>(context, listen: false)
                            .setLikes(replies);
                        return Builder(builder: (context) {
                          final List<MiniProfile> _replies =
                              Provider.of<FullCommentHelper>(context).likes;
                          final int _numOfReplies = _replies.length;
                          return Scaffold(
                              appBar: null,
                              backgroundColor: Colors.white,
                              body: SafeArea(
                                  child: Container(
                                      color: Colors.white,
                                      child: SizedBox(
                                          height: _deviceHeight,
                                          width: _deviceWidth,
                                          child: Column(children: [
                                            const SettingsBar('Likes'),
                                            if (_numOfReplies == 0)
                                              Expanded(
                                                  child:
                                                      Column(children: <Widget>[
                                                const Text(
                                                    'Be the first to like',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 21.0))
                                              ])),
                                            if (_numOfReplies != 0)
                                              Expanded(
                                                  child: Noglow(
                                                      child: ListView.builder(
                                                          controller:
                                                              _scrollController,
                                                          itemCount:
                                                              _replies.length +
                                                                  1,
                                                          itemBuilder:
                                                              (_, index) {
                                                            if (index ==
                                                                _replies
                                                                    .length) {
                                                              if (isLoading) {
                                                                return Center(
                                                                    child: Container(
                                                                        margin: const EdgeInsets.all(
                                                                            10.0),
                                                                        height:
                                                                            35.0,
                                                                        width:
                                                                            35.0,
                                                                        child: Center(
                                                                            child:
                                                                                const CircularProgressIndicator(strokeWidth: 1.50))));
                                                              }
                                                              if (isLastPage) {
                                                                return emptyBox;
                                                              }
                                                            } else {
                                                              final MiniProfile
                                                                  _currentReply =
                                                                  _replies[
                                                                      index];
                                                              final String
                                                                  replierUsername =
                                                                  _currentReply
                                                                      .username;
                                                              final Widget
                                                                  _replyTile =
                                                                  LinkObject(
                                                                      username:
                                                                          replierUsername);
                                                              return _replyTile;
                                                            }
                                                            return emptyBox;
                                                          })))
                                          ])))));
                        });
                      })));
        });
  }
}
