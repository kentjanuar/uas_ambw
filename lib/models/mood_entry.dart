class MoodEntry {
  final int? id;
  final String userId;
  final String mood;
  final String date;
  final String? note;
  final String createdAt;

  MoodEntry({
    this.id,
    required this.userId,
    required this.mood,
    required this.date,
    this.note,
    required this.createdAt,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    print('Received ID from Supabase: $id (Type: ${id.runtimeType})');
    
    return MoodEntry(
      id: id,
      userId: json['user_id'],
      mood: json['mood'],
      date: json['date'],
      note: json['note'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mood': mood,
      'date': date,
      'note': note,
      'created_at': createdAt,
    };
  }
}
