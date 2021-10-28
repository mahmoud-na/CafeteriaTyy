import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoItems extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool looping;
  final bool autoplay;

  VideoItems({
    required this.videoPlayerController,
    required this.looping,
    required this.autoplay,
    Key? key,
  }) : super(key: key);

  @override
  _VideoItemsState createState() => _VideoItemsState();
}

class _VideoItemsState extends State<VideoItems> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      allowedScreenSleep: true,
      showOptions: false,
      overlay: Container(
        // width: 284,
        color: Colors.grey.withOpacity(0.5),
        // padding: EdgeInsets.only(left: 20,),
        // margin: EdgeInsets.only(bottom: 8.0,left: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'Video 1 Name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
            ),
          ],
        ),
      ),
      aspectRatio: 1,
      allowFullScreen: true,
      allowMuting: true,
      autoInitialize: true,
      autoPlay: widget.autoplay,
      looping: widget.looping,
      deviceOrientationsOnEnterFullScreen: DeviceOrientation.values,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Chewie(
        controller: _chewieController,
      ),
    );
  }
}
