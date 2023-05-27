class OffsetPosition {
  double x, y;

  OffsetPosition({
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  static OffsetPosition fromJson(Map<String, dynamic> json) {
    return OffsetPosition(
      x: json['x'] * 1.0,
      y: json['y'] * 1.0,
    );
  }

  OffsetPosition copyWith({
    double? x,
    double? y,
  }) {
    return OffsetPosition(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}
