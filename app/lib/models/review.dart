class Review {
  final int id;
  final String userName;
  final String comment;
  final String productName;

  Review({
    required this.id,
    required this.userName,
    required this.comment,
    required this.productName,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    userName: json['userName'],
    comment: json['comment'],
    productName: json['productName'],
  );
}
