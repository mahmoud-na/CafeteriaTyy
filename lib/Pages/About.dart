import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '/Components/MyDrawer.dart';
import 'video.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

late VideoPlayerController VideoController = VideoPlayerController.network(
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4');
videoPlayerController() {
  return VideoController;
}

class _AboutState extends State<About> {
  List<Widget> videosList = [
    Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          color: Colors.amber,
          child: AspectRatio(
            aspectRatio: VideoController.value.aspectRatio,
            child: VideoItems(
              videoPlayerController: VideoPlayerController.network(
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
              looping: false,
              autoplay: false,
            ),
          ),
        ),
      ],
    ),
    Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          color: Colors.amber,
          child: AspectRatio(
            aspectRatio: VideoController.value.aspectRatio,
            child: VideoItems(
              videoPlayerController: VideoPlayerController.network(
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
              looping: false,
              autoplay: false,
            ),
          ),
        ),
      ],
    ),
    Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          color: Colors.amber,
          child: AspectRatio(
            aspectRatio: VideoController.value.aspectRatio,
            child: VideoItems(
              videoPlayerController: VideoPlayerController.network(
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
              looping: false,
              autoplay: false,
            ),
          ),
        ),
      ],
    ),
    Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          color: Colors.amber,
          child: AspectRatio(
            aspectRatio: VideoController.value.aspectRatio,
            child: VideoItems(
              videoPlayerController: VideoPlayerController.network(
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
              looping: false,
              autoplay: false,
            ),
          ),
        ),
      ],
    ),
    Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          color: Colors.amber,
          child: AspectRatio(
            aspectRatio: VideoController.value.aspectRatio,
            child: VideoItems(
              videoPlayerController: VideoPlayerController.network(
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
              looping: false,
              autoplay: false,
            ),
          ),
        ),
      ],
    ),
  ];
  int _current = 0;
  final CarouselController _controller = CarouselController();
  List<ExpantionState> cars = [
    // ExpantionState(
    //     headerName: 'فيديو',
    //     index: 1,
    //     isExpanded: false,
    //     leading: Icon(
    //       Icons.video_library_outlined,
    //       size: 30,
    //       color: Colors.grey,
    //     )),
    ExpantionState(
        headerName: 'شرح',
        index: 2,
        isExpanded: false,
        leading: Icon(
          Icons.assignment_outlined,
          size: 30,
          color: Colors.grey,
        )),
    ExpantionState(
        headerName: 'نبذة عن التطبيق',
        index: 3,
        isExpanded: false,
        leading: Icon(
          Icons.message_outlined,
          size: 30,
          color: Colors.grey,
        )),
  ];
  bool state = false;
  setHeaderWidget(var widget) {
    return widget.leading;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          'حول التطبيق',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        toolbarHeight: 50.0,
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15.0,
            ),
            Container(
              child: CarouselSlider(
                items: videosList,
                carouselController: _controller,
                options: CarouselOptions(
                  viewportFraction: 0.76,
                  height: 300,
                  aspectRatio: 2,
                  // autoPlay: true,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(
                      () {
                        _current = index;
                      },
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: videosList.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                            .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                  ),
                );
              }).toList(),
            ),
            SizedBox(
              height: 10.0,
            ),
            // Divider(
            //   thickness: 1.5,
            // ),
            ExpansionPanelList.radio(
              dividerColor: Colors.transparent,
              elevation: 1,
              expansionCallback: (panelIndex, isExpand) {
                setState(
                  () {
                    cars[panelIndex].isExpanded = !isExpand;
                  },
                );
              },
              animationDuration: Duration(milliseconds: 600),
              children: cars.map(
                (widget) {
                  return ExpansionPanelRadio(
                    canTapOnHeader: true,
                    backgroundColor: Colors.grey[50],
                    value: widget.index,
                    headerBuilder: (context, isExpanded) {
                      return Container(
                        padding: EdgeInsets.only(
                          left: 16,
                        ),
                        child: Row(
                          children: [
                            setHeaderWidget(widget),
                            SizedBox(
                              width: 26,
                            ),
                            Expanded(
                              child: Text(
                                widget.headerName,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontSize: 23.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    body: Container(
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          // Container(
                          //   height: 400,
                          //   child: CarouselSlider(
                          //     items: videosList,
                          //     carouselController: _controller,
                          //     options: CarouselOptions(
                          //       height: 380,
                          //       autoPlay: true,
                          //       enlargeCenterPage: true,
                          //       onPageChanged: (index, reason) {
                          //         setState(() {
                          //           _current = index;
                          //         });
                          //       },
                          //     ),
                          //   ),
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: videosList.asMap().entries.map((entry) {
                          //     return GestureDetector(
                          //       onTap: () =>
                          //           _controller.animateToPage(entry.key),
                          //       child: Container(
                          //         width: 8.0,
                          //         height: 8.0,
                          //         margin: EdgeInsets.symmetric(horizontal: 4.0),
                          //         decoration: BoxDecoration(
                          //             shape: BoxShape.circle,
                          //             color: (Theme.of(context).brightness ==
                          //                         Brightness.dark
                          //                     ? Colors.white
                          //                     : Colors.black)
                          //                 .withOpacity(_current == entry.key
                          //                     ? 0.9
                          //                     : 0.4)),
                          //       ),
                          //     );
                          //   }).toList(),
                          // ),
                          SizedBox(
                            height: 20.0,
                          )
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}

class ExpantionState {
  int index;
  String headerName;
  Widget? leading = Container();
  bool isExpanded;
  ExpantionState(
      {required this.index,
      required this.headerName,
      this.leading,
      required this.isExpanded});
}
