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