import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../Pages/MyCart.dart';
import '../Pages/activation_screen.dart' as activate;

class ItemModel {
  bool expanded;
  String headerItem;
  String discription;
  Color colorsItem;
  String img;

  ItemModel(
      {this.expanded: false,
      required this.headerItem,
      required this.discription,
      required this.colorsItem,
      required this.img});
}

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  bool uploadingIMG = false;
  bool isProfilePicture = false;
  late File image;
  final imagePicker = ImagePicker();
  var pickedImage;
  bool expanded = false;
  check() {
    if (activate.auth.profilePicture != "") {
      File image = File(activate.auth.profilePicture);
      return FileImage(image);
    } else {
      return AssetImage('images/person.png');
    }
  }

  chooseImageSource() {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: Text('Camera'),
              onPressed: () async {
                Navigator.pop(context);
                await TakeImageFromCamera();
              },
            ),
            CupertinoActionSheetAction(
              child: Text('Gallery'),
              onPressed: () async {
                Navigator.pop(context);
                await chooseImageFromGallery();
              },
            ),
            CupertinoActionSheetAction(
              child: Text('Default Image'),
              onPressed: () async {
                Navigator.pop(context);
                deleteImageConfirmationAlert(
                    "إنتبه..!", "هل انت متأكد انك تريد حذف الصوره");
              },
            ),
          ],
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('الكاميرا'),
            onTap: () async {
              Navigator.pop(context);
              await TakeImageFromCamera();
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_album),
            title: Text('الصور'),
            onTap: () async {
              Navigator.pop(context);
              await chooseImageFromGallery();
            },
          ),
          ListTile(
            leading: Icon(Icons.broken_image_outlined),
            title: Text('الصوره الأصليه'),
            onTap: () async {
              Navigator.pop(context);
              deleteImageConfirmationAlert(
                  "إنتبه..!", "هل انت متأكد انك تريد حذف الصوره");
            },
          ),
        ]),
      );
    }
  }

  deleteFireBaseStorageItem(String Url) {
    try {
      Navigator.of(context).pop();
      FirebaseStorage.instance.refFromURL(Url).delete();
      setState(() {
        isProfilePicture
            ? activate.auth.profilePicture = ""
            : activate.auth.drawerBGimage = "";
      });
    } catch (e) {}
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
                            isProfilePicture
                                ? await deleteFireBaseStorageItem(
                                    activate.auth.profilePicture)
                                : await deleteFireBaseStorageItem(
                                    activate.auth.drawerBGimage);
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
    if (isProfilePicture) {
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
    } else {
      Reference ref = storageReference.ref().child(
          'drawerBGimages/${activate.auth.userName}:${activate.auth.userID}');
      UploadTask uploadTask = ref.putFile(newImage);
      uploadTask.then((res) {
        res.ref.getDownloadURL().then((fileURL) {
          setState(() {
            activate.auth.drawerBGimage = fileURL;
            uploadingIMG = false;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new Container(
        child: new Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  child: CachedNetworkImage(
                    key: UniqueKey(),
                    imageUrl: activate.auth.drawerBGimage,
                    imageBuilder: (context, imageProvider) =>
                        uploadingIMG == true && !isProfilePicture
                            ? Container(
                                alignment: Alignment.center,
                                height: 220,
                                // width: 50,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  shape: BoxShape.rectangle,
                                ),
                              )
                            : Container(
                                height: 220,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                    placeholder: (context, url) {
                      return Container(
                        height: 220,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return Container(
                        height: 220,
                        child: Image(
                          image: AssetImage('images/DrawerBackground.jpg'),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  height: 220,
                  child: UserAccountsDrawerHeader(
                    accountName: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black12.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        activate.auth.userName,
                        style: TextStyle(
                            fontSize: 26.0,
                            // fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    accountEmail: null,
                    currentAccountPicture: GestureDetector(
                      child: CachedNetworkImage(
                        key: UniqueKey(),
                        imageUrl: activate.auth.profilePicture,
                        imageBuilder: (context, imageProvider) =>
                            uploadingIMG == true && isProfilePicture
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
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Container(
                            decoration: BoxDecoration(),
                            child: Image(
                              image: AssetImage('images/person.png'),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        setState(() {
                          isProfilePicture = true;
                        });
                        chooseImageSource();
                      },
                    ),
                    currentAccountPictureSize: Size.square(90),
                    decoration: BoxDecoration(color: Colors.transparent),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 12.0, right: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.black12.withOpacity(0.4),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        isProfilePicture = false;
                      });
                      chooseImageSource();
                    },
                    icon: Icon(
                      Icons.camera_alt,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            ListTile(
              title: Text(
                "الصفحة الرئيسية",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              leading: Icon(
                Icons.home_rounded,
                size: 30,
                color: Colors.grey,
              ),
              onTap: () {
                Navigator.of(context).pushNamed('HomePage');
              },
            ),
            Divider(indent: 20, endIndent: 70),
            ListTile(
              title: Text(
                "بياناتي",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              leading: Icon(
                Icons.person,
                size: 30,
                color: Colors.grey,
              ),
              onTap: () {
                Navigator.of(context).pushNamed('MyProfile');
              },
            ),
            Divider(indent: 20, endIndent: 70),
            ExpansionTile(
              childrenPadding: EdgeInsets.only(left: 20),
              textColor: Colors.black,
              leading: Icon(
                Icons.shopping_cart_rounded,
                size: 30,
                color: Colors.grey,
              ),
              title: Text(
                "طلباتي",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              children: <Widget>[
                ListTile(
                  title: Text(
                    "طلبات الشهر الحالي",
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('CurrentMonthOrders');
                  },
                ),
                // Divider(color: Colors.black, indent: 20, endIndent: 100),
                ListTile(
                  title: Text(
                    "طلبات الشهر السابق",
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('PreviousMonthOrders');
                  },
                ),
              ],
            ),
            Divider(indent: 20, endIndent: 70),
            ListTile(
              title: Text(
                "حول التطبيق",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              leading: Icon(
                Icons.info_rounded,
                size: 30,
                color: Colors.grey,
              ),
              onTap: () {
                Navigator.of(context).pushNamed('About');
              },
            ),
            SizedBox(
              height: 40.0,
            ),
            new ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.lightBlue),
              onPressed: () async {
                try {
                  late Directory dir;
                  String fileName = "Auth.json";
                  dir = await getApplicationDocumentsDirectory();
                  final file = File(dir.path + "/" + fileName);
                  final contents = await file.readAsString();
                  final data = await json.decode(contents);
                  final cart = Provider.of<MyCart>(context, listen: false);
                  cart.ResetItems();
                  data["Authentication"][0]["RememberMe"] = "false";
                  file.writeAsStringSync(json.encode(data));
                  activate.auth.rememberMe = false;
                  activate.auth.profilePicture = "";
                  activate.auth.drawerBGimage = "";
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      'LoginScreen', (Route<dynamic> route) => false);
                } catch (e) {
                  print(
                      "========================================================= Sign out error =========================================================  $e}");
                }
              },
              child: new Text(
                'تسجيل خروج',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
