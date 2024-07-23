class ConfigData {
  final String caloriesPerStep;
  final String earningPointPerStep;
  final String earningMoneyPerStep;
  final String appStoreLink;
  final String playStoreLink;
  final String invitationMsgText;

  ConfigData({
    required this.caloriesPerStep,
    required this.earningPointPerStep,
    required this.earningMoneyPerStep,
    required this.appStoreLink,
    required this.playStoreLink,
    required this.invitationMsgText,
  });

  factory ConfigData.fromJson(dynamic json) {
    print('ConfigDataxxxxx');
    print(json['calories_per_step']);
    return ConfigData(// Defaulting to 0 if null
      caloriesPerStep: json['calories_per_step'] ?? '',
      earningPointPerStep: json['earning_point_per_step'] ?? '',
      earningMoneyPerStep: json['earning_money_per_step'] ?? '',
      appStoreLink: json['app_store_link'] ?? '',
      playStoreLink: json['play_store_link'] ?? '',
      invitationMsgText: json['invitation_msg_text'] ?? '',
    );
  }
}
