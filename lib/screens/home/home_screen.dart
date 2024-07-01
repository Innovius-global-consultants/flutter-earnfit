import 'dart:async';
import 'package:earnfit/commons/animated_card_widget.dart';
import 'package:earnfit/configs/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../commons/info_card.dart';
import '../../services/model/dashboard/advertisement.dart';
import '../../services/model/dashboard/steps_info.dart';
import '../../services/repository/home_repository.dart';
import 'home_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../commons/video_player_screen.dart'; // Adjust import as per your project structure

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {// Start with video player visible
  Timer? _countdownTimer;
  int _countdownSeconds = 10;
  bool _locationPermissionDenied = false;
  bool _showVideoPlayer = false;// To track permission denial

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: null,
      body: BlocProvider(
        create: (context) => HomeBloc(homeRepository: HomeRepository())
          ..add(FetchAdvertisements()),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return _buildLoadingState();
            } else if (state is HomeScreenLoaded) {
              return _buildUIForBoth(
                context,
                state.advertisements,
                state.stepsInfo,
              );
            } else if (state is HomeError) {
              return _buildErrorState(state.message);
            } else {
              return _buildErrorState('Unknown state occurred');
            }
          },
        ),
      ),
    );
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

  Widget _buildUIForBoth(
      BuildContext context,
      List<AdvertisementsInfo>? advertisements,
      StepsInfo? stepsInfo,
      ) {
    if (advertisements == null || stepsInfo == null || advertisements.isEmpty) {
      return const SizedBox.shrink();
    }

    // Assuming the first advertisement for simplicity
    final bannerImageUrl =
    advertisements.isNotEmpty ? advertisements[0].bannerFileUrl : '';
    final videoUrl =
    advertisements.isNotEmpty ? advertisements[0].videoFileUrl : '';
    _countdownSeconds = advertisements[0].videoPlayTime ?? 10;

    final addDetails = advertisements.isNotEmpty ? advertisements[0].sponsorName : '';

    return Stack(
      fit: StackFit.loose,
      children: <Widget>[
        if (bannerImageUrl!.isNotEmpty)
          Image.network(
            bannerImageUrl,
            width: double.infinity,
            height: 190, // Adjust height as per your design
            fit: BoxFit.cover,
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 190), // Space for banner image
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showVideoPlayer = true;
                  });
                },
                icon: const Icon(Icons.play_arrow, size: 30, color: Colors.black),
                label:  Text(
                  'Click to start your activity',
                  style: AppTextStyles.openSans.copyWith(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            _buildActivityHeader(),
            _buildInfoCardsForData(stepsInfo),
            _buildEarningsSection(stepsInfo,addDetails),
          ],
        ),
        if (_showVideoPlayer == true)
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: VideoPlayerWidget(
                key: UniqueKey(), // Use UniqueKey to force rebuild and dispose old widget
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
          ) else SizedBox.shrink(),
      ],
    );
  }


  Widget _buildActivityHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Text(
            'Today\'s Activities',
            style: AppTextStyles.openSans.copyWith(fontSize: 16, fontWeight: FontWeight.normal),
          ),
          Row(
            children: [
               Text(
                'Tell your friends',
                style: AppTextStyles.openSans.copyWith(fontSize: 12, color: Colors.blue),
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.blue),
                onPressed: () {
                  // Implement share functionality here
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardsForData(StepsInfo stepsInfo) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InfoCard(
            title: 'Steps',
            value: stepsInfo.data?.totalSteps.toString() ?? '0.0',
            iconAsset: 'assets/icons/steps.png',
          ),
          const SizedBox(width: 20),
          InfoCard(
            title: 'Distance(km)',
            value: stepsInfo.data?.totalDistance ?? '0.0',
            iconAsset: 'assets/icons/map.png',
          ),
          const SizedBox(width: 20),
          InfoCard(
            title: 'Calories',
            value: stepsInfo.data?.totalCalories.toString() ?? '00',
            iconAsset: 'assets/icons/burn.png',
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
                  Text(
                    '₹${stepsInfo.data?.totalMoney ?? '0'}',
                    style: AppTextStyles.openSans.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  children:  [
                    TextSpan(
                      text: 'Sponsored by ',
                    ),
                    TextSpan(
                      text: addDetails,
                      style: AppTextStyles.openSans.copyWith(fontWeight: FontWeight.bold),
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
