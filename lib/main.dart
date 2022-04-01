import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:locals_test/api.dart';
import 'package:locals_test/post.dart';
import 'package:locals_test/styles.dart';
import 'package:locals_test/user.dart';

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

  late Future<LocalsUser> currentUser;
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

    /// Add listener to the feed's scroll controller, used for pagination.
    feedScrollController = ScrollController()..addListener(loadMoreFeed);

    /// Call initial setup (log in and then get page one of feed.
    initialSetup();
  }

  @override
  void dispose() {
    feedScrollController.removeListener(loadMoreFeed);
    super.dispose();
  }

  /// Check if there is network connection.
  Future<bool> checkForConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    else {
      return true;
    }
  }

  /// Initial setup when app starts, logs in user and then loads feed.
  initialSetup() async {
    currentUser = api.login(constants.email, constants.password, constants.deviceID).whenComplete(() => setState(() {}));
    if (await checkForConnection()) {
      getFeed();
    }
    else {
      showAlert();
    }
  }

  /// Requests feed, either initially or adds to it if scrolling to next page.
  getFeed() async {
    if (await checkForConnection()) {
      LocalsUser user = await currentUser;
      List<dynamic> result = await api.getFeed(user.authToken, constants.deviceID, constants.feedOrder[feedOrderIndex], feedData.isEmpty ? 0 : feedData.last.id);
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

    var feedOrderMenuContainer = PopupMenuButton(
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
    );

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
          feedOrderMenuContainer,
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
          future: currentUser,
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

  /// Alert Dialog if there is no network connection.
  showAlert() {
    showDialog(
      context: mainNavigatorKey.currentState!.overlay!.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appBarColor,
          title: const Text(
            'Connection Error',
            style: TextStyle(
              color: mainTextColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          content: const Text(
            'It looks like you are not connected to the internet. Please check if you are on airplane mode and try again.',
            style: TextStyle(
              color: mainTextColor,
              fontWeight: FontWeight.w200,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Retry',
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
}