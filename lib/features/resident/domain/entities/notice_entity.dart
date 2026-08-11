class NoticeEntity {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String societyId;
  final String postedBy;

  NoticeEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.societyId,
    required this.postedBy,
  });
}
