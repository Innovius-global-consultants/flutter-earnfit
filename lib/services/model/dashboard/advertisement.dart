class Advertisement {
  final int id;
  final int sponsorId;
  final String sponsoredAmount;
  final String bannerFileUrl;
  final String videoFileUrl;
  final int videoPlayTime;
  final String sponsorName;
  final String description;

  Advertisement({
    required this.id,
    required this.sponsorId,
    required this.sponsoredAmount,
    required this.bannerFileUrl,
    required this.videoFileUrl,
    required this.videoPlayTime,
    required this.sponsorName,
    required this.description,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'],
      sponsorId: json['sponsor_id'],
      sponsoredAmount: json['sponsored_amount'],
      bannerFileUrl: json['banner_file_url'],
      videoFileUrl: json['video_file_url'],
      videoPlayTime: json['video_play_time'],
      sponsorName: json['sponsor_name'],
      description: json['description'],
    );
  }
}
