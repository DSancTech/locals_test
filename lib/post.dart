import 'package:flutter/material.dart';
import 'package:locals_test/styles.dart';

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
}

/// Calculates the '___ ago' text in the posts (under author name) based on timestamp.
String calculatedDate(DateTime createdDate) {
  DateTime currentDate = DateTime.now();
  var difference = currentDate.difference(createdDate);

  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
  }
  if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
  }
  if (difference.inDays > 7) {
    return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() == 1 ? '' : 's'} ago';
  }
  if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  }
  if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
  }
  if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
  }
  if (difference.inMinutes == 0) {
    return 'Posted just now';
  }
  return createdDate.toString();
}