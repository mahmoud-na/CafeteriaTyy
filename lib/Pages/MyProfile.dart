import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../Components/MyDrawer.dart';
import 'activation_screen.dart' as activate;

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  bool uploadingIMG = false;
  late File image;
  final imagePicker = ImagePicker();
  var pickedImage;
  Future<bool> _onBackPressed() async {
    return Navigator.of(context).pushNamed('HomePage') as Future<bool>;
  }

  chooseImageSource() {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: Text('الكاميرا'),
              onPressed: () async {
                Navigator.pop(context);
                await TakeImageFromCamera();
              },
            ),
            CupertinoActionSheetAction(
              child: Text('الصور'),
              onPressed: () async {
                Navigator.pop(context);
                await chooseImageFromGallery();
              },
            )
          ],
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Camera'),
            onTap: () async {
              Navigator.pop(context);
              await TakeImageFromCamera();
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_album),
            title: Text('Gallery'),
            onTap: () async {
              Navigator.pop(context);
              await chooseImageFromGallery();
            },
          ),
        ]),
      );
    }
  }

  deleteFireBaseStorageItem(String Url) {
    Navigator.of(context).pop();
    FirebaseStorage.instance.refFromURL(Url).delete();
    setState(() {
      activate.auth.profilePicture = "";
    });
  }

  showDeleteImageIcon() {
    if (activate.auth.profilePicture != "") {
      return Container(
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: () async {
              deleteImageConfirmationAlert(
                  "إنتبه..!", "هل انت متأكد انك تريد حذف الصوره");
            },
            icon: ImageIcon(
              AssetImage("images/iconX.png"),
              size: 25,
              color: Colors.red,
            ),
          ));
    } else
      return Container();
  }

  deleteImageConfirmationAlert(String title, String content) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                title,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: new Text(
                content,
                style: TextStyle(
                  fontSize: 18.0,
                ),
                textDirection: TextDirection.rtl,
              ),
              buttonPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(25.0),
                ),
              ),
              actions: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 1.5,
                              color: Colors.grey.shade200,
                            ),
                            right: BorderSide(
                              width: 1.5,
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        child: TextButton(
                          child: Text(
                            'تأكيد',
                            style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          onPressed: () async {
                            await deleteFireBaseStorageItem(
                                activate.auth.profilePicture);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 1.5,
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        child: TextButton(
                          child: Text(
                            'إلغاء',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ));
  }

  TakeImageFromCamera() async {
    try {
      pickedImage = await imagePicker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front);
      image = File(pickedImage.path);
      setState(() {
        uploadingIMG = true;
      });
      await uploadFileToFirebase(image);
    } catch (e) {}
  }

  chooseImageFromGallery() async {
    try {
      pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
      image = File(pickedImage.path);
      setState(() {
        uploadingIMG = true;
      });
      await uploadFileToFirebase(image);
    } catch (e) {}
  }

  Future uploadFileToFirebase(File newImage) async {
    FirebaseStorage storageReference = FirebaseStorage.instance;
    Reference ref = storageReference.ref().child(
        'ProfilesPics/${activate.auth.userName}:${activate.auth.userID}');
    UploadTask uploadTask = ref.putFile(newImage);
    uploadTask.then((res) {
      res.ref.getDownloadURL().then((fileURL) {
        setState(() {
          activate.auth.profilePicture = fileURL;
          uploadingIMG = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> asciiArray =
        "Name is:${activate.auth.userName} \nUserID is:${activate.auth.userID}"
            .codeUnits;
    List<int> asciiArrayAfterMod = [];
    asciiArray.forEach((value) {
      asciiArrayAfterMod.add(((value + 5) * 5) - 55);
    });
    final String qrData = new String.fromCharCodes(asciiArrayAfterMod);
    return WillPopScope(
        child: Scaffold(
          appBar: new AppBar(
            title: new Text('بياناتي',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            toolbarHeight: 50.0,
          ),
          drawer: MyDrawer(),
          body: Container(
            height: double.infinity,
            width: double.infinity,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 150,
                    width: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          child: GestureDetector(
                            child: CachedNetworkImage(
                              key: UniqueKey(),
                              imageUrl: activate.auth.profilePicture,
                              imageBuilder: (context, imageProvider) =>
                                  uploadingIMG == true
                                      ? Container(
                                          height: 150,
                                          width: 150,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black12,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                              placeholder: (context, url) {
                                return Container(
                                  height: 150,
                                  width: 150,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    shape: BoxShape.circle,
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) {
                                return Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(),
                                  child: Image(
                                    image: AssetImage('images/person.png'),
                                  ),
                                );
                              },
                            ),
                            onTap: () {
                              chooseImageSource();
                            },
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                        ),
                        showDeleteImageIcon(),
                      ],
                    ),
                  ),
                  Text(
                    '${activate.auth.userName}',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'OpenSans',
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 10.0,
                        ),
                        borderRadius: BorderRadius.circular(20)),
                    child: QrImage(
                      data: qrData,
                      errorCorrectionLevel: 3,
                      version: QrVersions.auto,
                      size: 350,
                      embeddedImage: AssetImage('images/Aio_Logo_original.png'),
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: Size(80, 80),
                      ),
                    ),
                  ),
                  Text(
                    'قم بمسح هذا الكود للإستلام.',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'OpenSans',
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onWillPop: _onBackPressed);
  }
}
