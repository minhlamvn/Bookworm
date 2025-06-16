class Book {
  String name;
  String author;
  String image;
  Duration readingTime;

  // Adjusted constructor to accept all fields
  Book(this.name, this.author, this.image, this.readingTime);

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'];
    final String title = volumeInfo['title'];
    final List<String> authors = (volumeInfo['authors'] ?? []).cast<String>();
    final String thumbnailUrl = volumeInfo['imageLinks'] != null ? volumeInfo['imageLinks']['thumbnail'] : '';
    final int readingTimeSeconds = json['readingTime'] ?? 0; // Default to 0 if not provided
    final Duration readingTime = Duration(seconds: readingTimeSeconds);

    return Book(title, authors.isNotEmpty ? authors.first : 'Unknown Author', thumbnailUrl, readingTime);
  }

  // If you need to serialize to JSON, include this method
  Map<String, dynamic> toJson() {
    return {
      'volumeInfo': {
        'title': name,
        'authors': [author],
        'imageLinks': {
          'thumbnail': image,
        },
      },
      'readingTime': readingTime.inSeconds,
    };
  }
}