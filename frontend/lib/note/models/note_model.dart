class Note {
  final String id;
  final String title;
  final String content;
  final String userId;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON'dan Note nesnesine dönüştürme
  factory Note.fromJson(Map<String, dynamic> json) {
    try {
      return Note(
        id: json['_id'] ?? json['id'] ?? '',
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        userId: json['user'] ?? '',
        completed: json['completed'] ?? false,
        createdAt:
            json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now(),
        updatedAt:
            json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'])
                : DateTime.now(),
      );
    } catch (e) {
      print('Note model parse error: $e');
      print('Problem JSON: $json');
      // Hata durumunda default bir Note nesnesi döndür
      return Note(
        id: '',
        title: 'Hata: Yüklenemedi',
        content: 'Bu notun yüklenmesi sırasında bir hata oluştu.',
        userId: '',
        completed: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // Note nesnesinden JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'user': userId,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
