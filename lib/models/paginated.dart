class Paginated<T> {
  final int total;
  final int page;
  final int perPage;
  final List<T> data;

  Paginated({
    required this.total,
    required this.page,
    required this.perPage,
    required this.data,
  });

  static Paginated<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return Paginated(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      data: (json['data'] as List).map((e) => fromJsonT(e)).toList(),
    );
  }
}