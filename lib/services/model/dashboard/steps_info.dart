class StepsInfo {
  final int? code;
  final String? status;
  final String? message;
  final Data? data;

  StepsInfo({
    this.code,
    this.status,
    this.message,
    this.data,
  });

  factory StepsInfo.fromJson(Map<String, dynamic> json) {
    return StepsInfo(
      code: json['code'],
      status: json['status'],
      message: json['message'],
      data: Data.fromJson(json['data']),
    );
  }
}



class Data {
  final int? totalSteps;
  final String? totalDistance;
  final int? totalCalories;
  final int? totalPoints;
  final int? totalMoney;
  final List<AdvertisementsInfo>? advertisementsInfo;

  Data({
    this.totalSteps,
    this.totalDistance,
    this.totalCalories,
    this.totalPoints,
    this.totalMoney,
    this.advertisementsInfo,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    var adsList = json['advertisements_info'] as List?;
    List<AdvertisementsInfo>? advertisements;
    if (adsList != null) {
      advertisements = adsList.map((e) => AdvertisementsInfo.fromJson(e)).toList();
    }

    return Data(
      totalSteps: json['total_steps'],
      totalDistance: json['total_distance'],
      totalCalories: json['total_calories'],
      totalPoints: json['total_points'],
      totalMoney: json['total_money'],
      advertisementsInfo: advertisements,
    );
  }
}



class AdvertisementsInfo {
  final int? id;
  final int? sponsorId;
  final String? bannerFileUrl;
  final String? videoFileUrl;
  final int? videoPlayTime;
  final String? sponsorName;
  final String? description;

  AdvertisementsInfo({
    this.id,
    this.sponsorId,
    this.bannerFileUrl,
    this.videoFileUrl,
    this.videoPlayTime,
    this.sponsorName,
    this.description,
  });

  factory AdvertisementsInfo.fromJson(Map<String, dynamic> json) {
    return AdvertisementsInfo(
      id: json['id'],
      sponsorId: json['sponsor_id'],
      bannerFileUrl: json['banner_file_url'],
      videoFileUrl: json['video_file_url'],
      videoPlayTime: json['video_play_time'],
      sponsorName: json['sponsor_name'],
      description: json['description'],
    );
  }
}



