class Series {
  String seriesId;
  int capacity;
  int repetition;

  Series({
    required this.seriesId,
    required this.capacity,
    required this.repetition,
  });

  Map<String, dynamic> toMap() {
    return {
      'series_id': seriesId,
      'capacity': capacity,
      'repetition': repetition,
    };
  }

  factory Series.fromMap(Map<String, dynamic> map) {
    return Series(
      seriesId: map['series_id'],
      capacity: map['capacity'],
      repetition: map['repetition'],
    );
  }
}
