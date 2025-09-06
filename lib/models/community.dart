class PostItem {
  final int postId;
  final int userId;
  final String nickname;
  final String title;
  final String content;
  final String category;
  final String status;
  final int? commentCount;
  final String createdAt;

  PostItem({
    required this.postId,
    required this.userId,
    required this.nickname,
    required this.title,
    required this.content,
    required this.category,
    required this.status,
    this.commentCount,
    required this.createdAt,
  });

  factory PostItem.fromJson(Map<String, dynamic> json) => PostItem(
        postId: json['post_id'],
        userId: json['user_id'],
        nickname: json['nickname'] ?? '',
        title: json['title'],
        content: json['content'],
        category: json['category'],
        status: json['status'],
        commentCount: json['comment_count'],
        createdAt: json['created_at'],
      );
}

class CommentItem {
  final int commentId;
  final int postId;
  final int userId;
  final String nickname;
  final String content;
  final String createdAt;

  CommentItem({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.nickname,
    required this.content,
    required this.createdAt,
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) => CommentItem(
        commentId: json['comment_id'],
        postId: json['post_id'],
        userId: json['user_id'],
        nickname: json['nickname'] ?? '',
        content: json['content'],
        createdAt: json['created_at'],
      );
}