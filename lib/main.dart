import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

/// Locals Test API calls
class LocalsApi {
  static const baseURL = 'https://app-test.rr-qa.seasteaddigital.com';
  static const loginURL = baseURL + '/app_api/auth.php';
  static const feedURL = baseURL + '/api/v1/posts/feed/global.json';

  Future<LocalsUser> login(String email, String password, String id) async {
    final response = await http.post(
      Uri.parse(loginURL),
      body: <String, String>{
        'email': email,
        'password': password,
        'device_id': id,
      },
    );
    if (response.statusCode == 200) {
      return LocalsUser.fromJson(jsonDecode(response.body)['result']);
    } else {
      throw Exception('Login Failed.');
    }
  }

  Future<List<dynamic>> getFeed(String auth, String id, String order, int lastPageId) async {
    final response = await http.post(
      Uri.parse(feedURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-APP-AUTH-TOKEN': auth,
        'X-DEVICE-ID': id,
      },
      body: jsonEncode({
        'data': {
          'page_size': 10,
          'order': order.toLowerCase(),
          'lpid': lastPageId,
        }
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Error Loading Feed.');
    }
  }
}

/// Locals User containing basic user info.
class LocalsUser {
  const LocalsUser({
    required this.username,
    required this.email,
    required this.userID,
    required this.uniqueID,
    required this.authToken,
    required this.activeSubscriber,
    required this.unclaimedGift
  });

  final String username;
  final String email;
  final int userID;
  final String uniqueID;
  final String authToken;
  final int activeSubscriber;
  final int unclaimedGift;

  factory LocalsUser.fromJson(Map<String, dynamic> data) {
    return LocalsUser(
      username: data['username'],
      email: data['email'],
      userID: data['user_id'],
      uniqueID: data['unique_id'],
      authToken: data['ss_auth_token'],
      activeSubscriber: data['active_subscriber'],
      unclaimedGift: data['unclaimed_gift'],
    );
  }
}

/// Locals Posts containing data on each post that is seen in the feed.
class LocalsPost {
  const LocalsPost({
    required this.id,
    required this.authorID,
    required this.communityID,
    required this.text,
    required this.title,
    required this.isLiked,
    required this.isCommented,
    required this.isBookmarked,
    required this.timestamp,
    required this.views,
    required this.isBlurred,
    required this.authorName,
    required this.authorAvatarExt,
    required this.authorAvatarURL,
  });

  final int id;
  final int authorID;
  final int communityID;
  final String text;
  final String title;
  final bool isLiked;
  final bool isCommented;
  final bool isBookmarked;
  final int timestamp;
  final int views;
  final bool isBlurred;
  final String authorName;
  final String authorAvatarExt;
  final String authorAvatarURL;

  factory LocalsPost.fromJson(Map<String, dynamic> data) {
    return LocalsPost(
      id: data['id'],
      authorID: data['author_id'],
      communityID: data['community_id'],
      text: data['text'],
      title: data['title'],
      isLiked: data['liked_by_us'],
      isCommented: data['commented_by_us'],
      isBookmarked: data['bookmarked'],
      timestamp: data['timestamp'],
      views: data['total_post_views'],
      isBlurred: data['is_blured'],
      authorName: data['author_name'],
      authorAvatarExt: data['author_avatar_extension'],
      authorAvatarURL: data['author_avatar_url'],
    );
  }
}

/// Test Constants which were provided.
class LocalsTestConstants {
  final String email = 'testlocals0@gmail.com';
  final String password = 'jahubhsgvd23';
  final String deviceID = '7789e3ef-c87f-49c5-a2d3-5165927298f0';
  final List<String> feedOrder = ['Recent', 'Oldest'];
}

/// App colors and font sizes used throughout.
const appBarColor = Color(0xFF090909);
const backgroundColor = Color(0xFF111010);
const mainTextColor = Color(0xFFFFFFFF);
const lightGrayColor = Color(0xFF858282);
const darkGrayColor = Color(0xFF5b5757);
const lineColor = Color(0xFF292828);
const selectionColor = Color(0xFFB23634);
const verifiedColor = Color(0xFF4076BC);
const regularFontSize = 20.0;
const smallFontSize = 15.0;
const extraSmallFontSize = 12.0;

final mainNavigatorKey = GlobalKey<NavigatorState>();

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locals Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: selectionColor,
      ),
      home: const HomePage(),
      navigatorKey: mainNavigatorKey,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Future<LocalsUser> currentUserFuture;
  late LocalsUser currentUser;
  var api = LocalsApi();
  var constants = LocalsTestConstants();
  int feedOrderIndex = 0;
  List<LocalsPost> feedData = [];
  late ScrollController feedScrollController;
  bool hasNextPage = true;
  bool loadingNextPage = false;

  @override
  void initState() {
    super.initState();
    feedScrollController = ScrollController()..addListener(loadMoreFeed);
    initialSetup();
  }

  @override
  void dispose() {
    feedScrollController.removeListener(loadMoreFeed);
    super.dispose();
  }

  ///
  Future<bool> checkForConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    else {
      return true;
    }
  }

  showAlert() {
    showDialog(
      context: mainNavigatorKey.currentState!.overlay!.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appBarColor,
          title: const Text(
            "Connection Error",
            style: TextStyle(
              color: mainTextColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          content: const Text(
              "It looks like you are not connected to the internet. Please check if you are on airplane mode and try again.",
            style: TextStyle(
              color: mainTextColor,
              fontWeight: FontWeight.w200,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Retry",
                style: TextStyle(
                  color: selectionColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (feedData.isEmpty) {
                  initialSetup();
                }
                else {
                  getFeed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Initial setup when app starts, logs in user and then loads feed.
  initialSetup() async {
    currentUserFuture = api.login(constants.email, constants.password, constants.deviceID);
    if (await checkForConnection()) {
      currentUser = await currentUserFuture.whenComplete(() => setState(() {}));
      getFeed();
    }
    else {
      showAlert();
    }
  }

  /// Requests feed, either initially or adds to it if scrolling to next page.
  getFeed() async {
    if (await checkForConnection()) {
      List<dynamic> result = await api.getFeed(currentUser.authToken, constants.deviceID, constants.feedOrder[feedOrderIndex], feedData.isEmpty ? 0 : feedData.last.id);
      if (result.isNotEmpty) {
        if (result.length < 10) {
          hasNextPage = false;
        }
        for (var post in result) {
          feedData.add(LocalsPost.fromJson(Map<String, dynamic>.from(post)));
        }
      }
      else {
        hasNextPage = false;
      }
      setState(() {});
    }
    else {
      feedScrollController.jumpTo(0.0);
      showAlert();
    }
  }

  /// Detects when to load the next page of the feed.
  loadMoreFeed() async {
    if (hasNextPage && !loadingNextPage && (feedScrollController.position.extentAfter < 100)) {
      setState(() {
        loadingNextPage = true;
      });
      await getFeed();
      setState(() {
        loadingNextPage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final double topSafeArea = MediaQuery.of(context).padding.top;
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    var appBarContainer = Container(
      decoration: const BoxDecoration(
        color: appBarColor,
        border: Border(bottom: BorderSide(width: 0.5, color: lineColor)),
      ),
      child: Row(
        children: [
          const Text(
            'Sort by:',
            style: TextStyle(
              color: darkGrayColor,
              fontSize: smallFontSize,
              fontWeight: FontWeight.normal,
            ),
          ),
          PopupMenuButton(
            color: lineColor,
            child: Container(
              child: Row(
                children: [
                  Text(
                    constants.feedOrder[feedOrderIndex],
                    style: const TextStyle(
                      color: lightGrayColor,
                      fontSize: smallFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 25.0,
                    color: lightGrayColor,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8.0),
            ),
            itemBuilder: (context) {
              return List.generate(constants.feedOrder.length, (index) {
                return PopupMenuItem(
                  value: index,
                  child: Text(
                    constants.feedOrder[index],
                    style: const TextStyle(
                      color: lightGrayColor,
                      fontSize: smallFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              });
            },
            onSelected: (int index) {
              if (feedOrderIndex != index) {
                setState(() {
                  feedOrderIndex = index;
                  feedData.clear();
                  hasNextPage = true;
                });
                getFeed();
              }
            },
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      height: topSafeArea + 60.0,
      padding: EdgeInsets.fromLTRB(0.0, topSafeArea, 0.0, 0.0),
    );

    var feedContainer = RefreshIndicator(
      onRefresh: () async {
        setState(() {
          feedData.clear();
          hasNextPage = true;
        });
        getFeed();
      },
      backgroundColor: appBarColor,
      color: selectionColor,
      child: Scrollbar(
        controller: feedScrollController,
        child: ListView.builder(
          controller: feedScrollController,
          itemCount: feedData.length + (loadingNextPage ? 1 : 0),
          padding: EdgeInsets.only(bottom: bottomSafeArea),
          itemBuilder: (BuildContext context, int index) {
            return (index == feedData.length) ? Container(
              child: const Center(
                child: CircularProgressIndicator(color: selectionColor),
              ),
              margin: const EdgeInsets.all(24.0),
            ) : LocalsFeedPost(postData: feedData[index]);
          },
        ),
      ),
    );

    var mainContainer = Expanded(
      child: Container(
        child: FutureBuilder<LocalsUser>(
          future: currentUserFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return feedData.isEmpty ? const CircularProgressIndicator(color: selectionColor) : feedContainer;
            }
            return const CircularProgressIndicator(color: selectionColor);
          },
        ),
        alignment: Alignment.center,
      ),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          appBarContainer,
          mainContainer,
        ],
      ),
    );
  }
}

/// Widget that displays the posts
class LocalsFeedPost extends StatefulWidget {
  const LocalsFeedPost({Key? key, required this.postData}) : super(key: key);

  final LocalsPost postData;

  @override
  State<LocalsFeedPost> createState() => _LocalsFeedPostState();
}

class _LocalsFeedPostState extends State<LocalsFeedPost> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    var avatarContainer = Container(
      child: Stack(
        children: [
          Positioned(
            child: Container(
              decoration: widget.postData.authorAvatarURL.isEmpty ? const BoxDecoration(color: appBarColor, shape: BoxShape.circle): BoxDecoration(
                color: appBarColor,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(widget.postData.authorAvatarURL),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            left: 0.0,
            right: 0.0,
            top: 0.0,
            bottom: 0.0,
          ),
          Positioned(
            child: widget.postData.authorAvatarURL.isEmpty ? const SizedBox() : Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(color: backgroundColor, width: 1.0),
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: verifiedColor,
                size: 20.0,
              ),
            ),
            bottom: 0.0,
            right: 0.0,
          ),
        ],
        alignment: Alignment.center,
      ),
      height: 60.0,
      width: 60.0,
      margin: const EdgeInsets.only(right: 12.0, top: 12.0),
    );

    var authorTextContainer = Expanded(
      child: Column(
        children: [
          Row(
            children: [
              Text(
                widget.postData.authorName,
                style: const TextStyle(
                  color: selectionColor,
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(width: 4.0),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  '@${widget.postData.authorName}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: lightGrayColor,
                    fontSize: smallFontSize,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            calculatedDate(DateTime.fromMillisecondsSinceEpoch(widget.postData.timestamp)),
            style: const TextStyle(
              color: darkGrayColor,
              fontSize: extraSmallFontSize,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );

    var bookmarkedContainer = SizedBox(
      child: Icon(
        Icons.push_pin_rounded,
        size: 20.0,
        color: widget.postData.isBookmarked ? selectionColor : darkGrayColor,
      ),
    );

    var topContent = Container(
      child: Row(
        children: [
          avatarContainer,
          authorTextContainer,
          bookmarkedContainer,
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12.0),
    );

    var postTitle = Text(
      widget.postData.title.isEmpty ? 'This is a test post' : widget.postData.title,
      textAlign: TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: regularFontSize,
        color: mainTextColor,
        fontWeight: FontWeight.bold,
      ),
    );

    var postText = Text(
      widget.postData.text.isEmpty ? 'This post is used just for Locals test' : widget.postData.text,
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontSize: regularFontSize,
        color: mainTextColor,
        fontWeight: FontWeight.normal,
      ),
    );

    var likedContainer = Container(
      child: Row(
        children: [
          Icon(
            Icons.thumb_up,
            size: 17.0,
            color: widget.postData.isLiked ? selectionColor : darkGrayColor,
          ),
          const SizedBox(width: 4.0),
          Text(
            widget.postData.isLiked ? '1' : '0',
            style: TextStyle(
              fontSize: smallFontSize,
              color: widget.postData.isLiked ? selectionColor : darkGrayColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      margin: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
    );

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0, color: lineColor)),
      ),
      child: Column(
        children: [
          topContent,
          postTitle,
          postText,
          likedContainer,
        ],
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      padding: EdgeInsets.fromLTRB(isLandscape ? 48.0 : 24.0, 12.0, isLandscape ? 48.0 : 24.0, 12.0),
    );
  }

  /// Calculates the "___ ago" based on timestamp.
  String calculatedDate(DateTime createdDate) {
    DateTime currentDate = DateTime.now();
    var difference = currentDate.difference(createdDate);

    if (difference.inDays > 365) {
      return "${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? "" : "s"} ago";
    }
    if (difference.inDays > 30) {
      return "${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? "" : "s"} ago";
    }
    if (difference.inDays > 7) {
      return "${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() == 1 ? "" : "s"} ago";
    }
    if (difference.inDays > 0) {
      return "${difference.inDays} day${difference.inDays == 1 ? "" : "s"} ago";
    }
    if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours == 1 ? "" : "s"} ago";
    }
    if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minute${difference.inMinutes == 1 ? "" : "s"} ago";
    }
    if (difference.inMinutes == 0) {
      return 'Posted just now';
    }
    return createdDate.toString();
  }

}