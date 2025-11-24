class Post {
  final int? id;
  final int? userId;
  final String title;
  final String body;

  Post({ this.id,  this.userId, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json){
    return Post(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      title: json['title'] ?? '',
      body: json['body'] ?? ''
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'userId': userId,
      'title': title,
      'body': body
    };
  }

  Post copyWith({
    int? id,
    int? userId,
    String? title,
    String? body
  }){
    return Post(
      id: id ?? this.id,
      userId: userId?? this.userId,
      title: title?? this.title,
      body: body?? this.body
    );
  }
  
}


// final updated = post.copyWith(title: '');
// provider.UpdatePostWhitPatch(updated);