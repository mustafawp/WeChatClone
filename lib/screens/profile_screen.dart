import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat/api/apis.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:wechat/main.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          // app bar
          appBar: AppBar(
            title: const Text("Your Profile"),
          ),

          // floating button to logout
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              onPressed: () async {
                Dialogs.showProgressbar(context);

                await APIs.updateActiveStatus(false);

                //sign out from app
                await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    //for hiding progress dialog
                    Navigator.pop(context);

                    //for moving to home screen
                    Navigator.pop(context);

                    APIs.auth = FirebaseAuth.instance;

                    //replacing home screen with login screen
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  });
                });
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
            ),
          ),

          //body
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // üstten ve yanlardan biraz boşluk
                    SizedBox(width: mq.width, height: mq.height * .03),

                    // profil fotoğrafı gösterme ve düzenleme
                    Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(mq.height * .1)),
                                child: Image.file(
                                  File(_image!),
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(mq.height * .1)),
                                child: CachedNetworkImage(
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.cover,
                                  imageUrl: widget.user.image,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error, size: 50),
                                ),
                              ),

                        // kalem
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              PhotoBottomSheet(context);
                            },
                            color: Colors.white,
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // dikeyden boşluk
                    SizedBox(height: mq.height * .03),

                    // kullanıcı maili
                    Text(
                      widget.user.email,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 16),
                    ),

                    // dikeyden boşluk
                    SizedBox(height: mq.height * .03),

                    // isim girişi
                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (newValue) => APIs.me.name = newValue ?? "",
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : "Required Field",
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: "eg. mustafawiped",
                          label: const Text("Name")),
                    ),

                    // dikey boşluk
                    SizedBox(height: mq.height * .02),

                    // hakkında girişi
                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (newValue) => APIs.me.about = newValue ?? "",
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : "Required Field",
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: "eg. Hello! I'm using We Chat!",
                          label: const Text("About")),
                    ),

                    // dikey boşluk
                    SizedBox(height: mq.height * .05),

                    // güncelle butonu
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            minimumSize: Size(mq.width * .5, mq.height * .06)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Dialogs.showProgressbar(context);
                            _formKey.currentState!.save();
                            APIs.updateUserInfo().then((value) {
                              Navigator.pop(context);
                              Dialogs.showSnackBar(
                                  context, "Profile Updated Successfully!");
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 30,
                        ),
                        label: const Text(
                          "Update",
                          style: TextStyle(fontSize: 18),
                        ))
                  ],
                ),
              ),
            ),
          )),
    );
  }

  // photo select from profile edit
  void PhotoBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .02, bottom: mq.height * .05),
            children: [
              // header
              const Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),

              // header and items between's empty
              SizedBox(
                height: mq.height * .02,
              ),

              // items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: Size(mq.width * .3, mq.height * .15),
                      ),
                      onPressed: () async {
                        // Pick an image.
                        final picker = ImagePicker();
                        var pickedFile = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (pickedFile != null) {
                          _image = pickedFile.path;
                          setState(() {
                            _image;
                          });
                          APIs.updateProfilePicture(File(_image!));
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset("images/gallery.png")),

                  // pick from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: Size(mq.width * .3, mq.height * .15),
                      ),
                      onPressed: () async {
                        // Pick an image.
                        final picker = ImagePicker();
                        var pickedFile = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (pickedFile != null) {
                          _image = pickedFile.path;
                          setState(() {
                            _image;
                          });

                          APIs.updateProfilePicture(File(_image!));
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset("images/photo.png")),
                ],
              )
            ],
          );
        });
  }
}
