import 'package:earnfit/commons/invite_your_friends_widget.dart';
import 'package:earnfit/configs/app_colors.dart';
import 'package:earnfit/configs/app_text_styles.dart';
import 'package:earnfit/configs/bloc_state_builder.dart';
import 'package:earnfit/configs/bloc_state_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import '../../commons/info_card.dart';
import '../../services/model/dashboard/steps_info.dart';
import 'home_bloc.dart';
import '../../commons/video_player_screen.dart'; // Adjust import as per your project structure

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeBloc _homeBloc;
  late int _countdownSeconds;
  late bool _showVideoPlayer = false;

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc();
    _homeBloc.fetchTodayStepsInfo();
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          BlocProvider.value(
            value: _homeBloc,
            child: _buildBody(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
                'assets/icons/waves.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (!_showVideoPlayer)
            Positioned(
            top: 90,
            left: 110,
            child: SizedBox(
              width: 160, // Adjust width as needed
              height: 40, // Adjust height to reduce button size
              child:
            FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _showVideoPlayer = true;
                });
              },
              icon: Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                'Start your activity',
                style: AppTextStyles.openSans
                    .copyWith(fontSize: 12, color: Colors.white),
              ),
              backgroundColor: AppColors.buttonColor,
            ),
          ),),
        ],
      ),
    );
  }



  Widget _buildBody() {
    return BlocStateListener(_homeBloc.fetchStepsInfoFuture).build(
        listener: (_, fetchStepsInfoFuture) {
          fetchStepsInfoFuture
            ..onSuccess((getViewBillActionResponse) {
              _homeBloc.listenToStepCountStream();
            })
            ..onFailure((failure) {});
        },
        child: DoubleBlocStateBuilder(
                _homeBloc.stepsInformation, _homeBloc.fetchStepsInfoFuture)
            .build((_, stepsInformation, fetchStepsInfoFuture) {
          if (fetchStepsInfoFuture.isLoading) {
            return _buildLoadingState();
          }

          if (stepsInformation?.data != null) {
            return _buildContent(context, stepsInformation);
          }

          return _buildErrorState('Something went wrong try after some time');
        }));
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Text(message),
    );
  }

  Widget _buildContent(
    BuildContext context,
    StepsInfo? stepsInfo,
  ) {
    List<AdvertisementsInfo>? advertisements =
        stepsInfo?.data?.advertisementsInfo;
    if (advertisements == null || stepsInfo == null || advertisements.isEmpty) {
      return const SizedBox.shrink();
    }

    // Assuming the first advertisement for simplicity
    // Extracting banner URLs from advertisements
    final List<String> bannerImageUrls = advertisements
        .map((advertisement) => advertisement.bannerFileUrl ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    final videoUrl =
        advertisements.isNotEmpty ? advertisements[0].videoFileUrl : '';
    _countdownSeconds = advertisements[0].videoPlayTime ?? 10;

    final addDetails =
        advertisements.isNotEmpty ? advertisements[0].sponsorName : '';

    return Stack(
      fit: StackFit.loose,
      children: <Widget>[
        if (bannerImageUrls.isNotEmpty)
          GFCarousel(
            viewportFraction: 1.0,
            autoPlay: true,
            reverse: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 1000),
            items: bannerImageUrls.map(
              (url) {
                return Container(
                  margin: EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      height: 190,
                      width: double.infinity,
                      // Adjust height as per your design
                    ),
                  ),
                );
              },
            ).toList(),
            onPageChanged: (index) {},
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 190),


            // Space for banner image
            // Padding(
            //   padding: const EdgeInsets.only(top: 20),
            //   child: Center(
            //     child: ElevatedButton.icon(
            //       onPressed: () {
            //         setState(() {
            //           _showVideoPlayer = true;
            //         });
            //       },
            //       icon: const Icon(Icons.play_arrow,
            //           size: 20, color: Colors.black),
            //       label: Text(
            //         'Click to start your activity',
            //         style: AppTextStyles.openSans.copyWith(
            //           fontSize: 12,
            //           color: Colors.black,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            _buildActivityHeader(),

            DoubleBlocStateBuilder(
                    _homeBloc.stepsInformation, _homeBloc.stepsInRealTime)
                .build((_, stepsInformation, stepsInRealTime) {
              final stepsBackend = stepsInformation?.data?.totalSteps ?? 0;
              final stepsInRealTimeAdd = stepsInRealTime?.steps ?? 0;
              final totalSteps = stepsBackend + stepsInRealTimeAdd;

              final distanceBackend = double.tryParse(
                      stepsInformation?.data?.totalDistance ?? '0') ??
                  0.0;
              final distanceInRealTimeAdd =
                  double.tryParse(stepsInRealTime?.distance ?? '0') ?? 0.0;

              final totalDistance = (distanceBackend + distanceInRealTimeAdd)
                  .toStringAsFixed(
                      2); // Converts result to string with 2 decimal places

              final caloriesBackend =
                  stepsInformation?.data?.totalCalories ?? 0;
              final caloriesInRealTimeAdd = stepsInRealTime?.calories ?? 0;

              final totalCalories = caloriesBackend + caloriesInRealTimeAdd;

              return _buildInfoCardsForData(
                steps: totalSteps,
                distance: totalDistance,
                calories: totalCalories,
              );
            }),

            _buildEarningsSection(stepsInfo, addDetails),
          ],
        ),
        if (_showVideoPlayer == true)
          Container(
            color: Colors.black,
            child: Center(
              child: SizedBox(
                height: 300,
                child: VideoPlayerWidget(
                  key: UniqueKey(),
                  // Use UniqueKey to force rebuild and dispose old widget
                  videoUrl: videoUrl!,
                  onClose: () {
                    setState(() {
                      _showVideoPlayer = false;
                    });
                  },
                  countdownSeconds: _countdownSeconds,
                  onSkip: () {
                    _handleSkipVideo();
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActivityHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0,top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Today\'s Activities',
            style: AppTextStyles.openSans
                .copyWith(fontSize: 16, fontWeight: FontWeight.normal),
          ),
          Row(
            children: [
              Text(
                'Tell your friends',
                style: AppTextStyles.openSans
                    .copyWith(fontSize: 12, color: Colors.blue),
              ),
              InviteYourFriendsWidget(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardsForData({
    required int steps,
    required String distance,
    required int calories,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InfoCard(
                title: 'Steps',
                value: steps.toString(),
                iconAsset: 'assets/icons/steps.png',
              ),
              InfoCard(
                title: 'Distance (km)',
                value: distance,
                iconAsset: 'assets/icons/map.png',
              ),
              InfoCard(
                title: 'Calories',
                value: calories.toStringAsFixed(2),
                iconAsset: 'assets/icons/burn.png',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSection(StepsInfo stepsInfo, String? addDetails) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Image.asset(
                      'assets/icons/money.png',
                      color: Colors.blue,
                      height: 30,
                      width: 30,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      '₹${stepsInfo.data?.totalMoney ?? '0'}',
                      style: AppTextStyles.openSans.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    'Earnings',
                    style: AppTextStyles.openSans.copyWith(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Sponsored by ',
                    ),
                    TextSpan(
                      text: addDetails,
                      style: AppTextStyles.openSans
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSkipVideo() {
    setState(() {
      _showVideoPlayer = false;
    });
  }
}
