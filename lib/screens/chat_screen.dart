// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat/api/apis.dart';
import 'package:wechat/helper/date_util.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:wechat/main.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/models/message.dart';
import 'package:wechat/screens/view_profile.dart';
import 'package:wechat/widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];

  final _textController = TextEditingController();

  bool _showEmoji = false, _isUpLoading = false, appLifeStyle = true;

  @override
  void initState() {
    super.initState();

    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message == "AppLifecycleState.resumed") {
        setState(() {
          appLifeStyle = true;
        });
      }
      if (message == "AppLifecycleState.paused") {
        setState(() {
          appLifeStyle = false;
        });
      }
      if (message == "AppLifecycleState.inactive") {
        setState(() {
          appLifeStyle = false;
        });
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            body: Column(children: [
              // messages design
              _chatMessages(),

              // loading
              if (_isUpLoading)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),

              // chat input design
              _chatInput(),

              if (_showEmoji) _emojiPicker(),
            ]),
          ),
        ),
      ),
    );
  }

  // App bar Design Codes
  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list = data
                  ?.map(
                    (e) => ChatUser.fromMap(e.data()),
                  )
                  .toList() ??
              [];

          return Row(
            children: [
              // back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black54,
                ),
              ),

              // profile photo
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(mq.height * .3)),
                child: CachedNetworkImage(
                  width: mq.height * .055,
                  height: mq.height * .055,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, size: 50),
                ),
              ),

              // sizedbox.
              const SizedBox(
                width: 10,
              ),

              // isim
              Column(
                // dikey ortalama
                mainAxisAlignment: MainAxisAlignment.center,

                // yatay hizalama
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // boşluk..
                  const SizedBox(
                    height: 2,
                  ),

                  // kullanıcı adı
                  Text(
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 19,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                  ),

                  // boşluk 2..
                  const SizedBox(
                    height: 1,
                  ),

                  // alt bilgi
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                            ? "Online"
                            : DateUtil.getLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive)
                        : DateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  // Chat Input Design Codes
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .001, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  // emoji button
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                      size: 25,
                    ),
                  ),

                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: "Type Something..",
                      hintStyle: TextStyle(color: Colors.blueAccent),
                      border: InputBorder.none,
                    ),
                    maxLines: 4,
                    minLines: 1,
                    onTap: () {
                      setState(() {
                        if (_showEmoji) {
                          setState(() {
                            _showEmoji = !_showEmoji;
                          });
                        }
                      });
                    },
                  )),

                  // image button
                  IconButton(
                    onPressed: () async {
                      if (_isUpLoading) {
                        Dialogs.showSnackBar(
                            context, "uploading another photo at the moment.");
                        return;
                      }
                      final picker = ImagePicker();
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);
                      setState(() {
                        _isUpLoading = true;
                      });
                      for (XFile i in images) {
                        await APIs.sendChatImage(widget.user, File(i.path));
                      }
                      setState(() {
                        _isUpLoading = false;
                      });
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.blueAccent,
                      size: 26,
                    ),
                  ),

                  // camera button
                  IconButton(
                    onPressed: () async {
                      if (_isUpLoading) {
                        Dialogs.showSnackBar(
                            context, "uploading another photo at the moment.");
                        return;
                      }
                      final picker = ImagePicker();
                      var pickedFile = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (pickedFile != null) {
                        setState(() {
                          _isUpLoading = true;
                        });
                        await APIs.sendChatImage(
                            widget.user, File(pickedFile.path));
                        setState(() {
                          _isUpLoading = false;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.blueAccent,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text, Type.text);
                _textController.text = "";
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // Chat Messages Design and Backend Codes
  Widget _chatMessages() {
    return Expanded(
      child: StreamBuilder(
        stream: APIs.getAllMessages(widget.user),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const SizedBox();

            case ConnectionState.active:
            case ConnectionState.done:

              // docs
              final data = snapshot.data?.docs;

              // message list
              _list = data!.map((e) => Message.fromJson(e.data())).toList();

              // realistic
              if (_list.isNotEmpty) {
                return ListView.builder(
                  itemCount: _list.length,
                  reverse: true,
                  padding: EdgeInsets.only(top: mq.height * .01),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return MessageCard(
                      message: _list[index],
                      state: appLifeStyle,
                    );
                  },
                );
              } else {
                return Center(
                  child: InkWell(
                    onTap: () {
                      APIs.sendMessage(widget.user, "Hi 👋", Type.text);
                    },
                    child: const Text(
                      "Do you wanna say 'Hi 👋'",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                );
              }
          }
        },
      ),
    );
  }

  Widget _emojiPicker() {
    return SizedBox(
      height: mq.height * .35,
      child: EmojiPicker(
        textEditingController: _textController,
        config: Config(
          bgColor: const Color.fromARGB(255, 234, 248, 255),
          columns: 8,
          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
        ),
      ),
    );
  }
}
