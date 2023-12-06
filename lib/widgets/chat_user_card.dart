import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wechat/api/apis.dart';
import 'package:wechat/helper/date_util.dart';
import 'package:wechat/main.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/models/message.dart';
import 'package:wechat/screens/chat_screen.dart';
import 'package:wechat/widgets/dialogs/profile_dialog.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: mq.width * .02, vertical: mq.height * .002),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      // isteğe bağlı arkaplan rengi değişme color: Colors.blue.shade100,
      elevation: 1,
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const SizedBox();

                case ConnectionState.active:
                case ConnectionState.done:
                  // docs
                  final data = snapshot.data?.docs;
                  if (data == null) {
                    return const ListTile();
                  }
                  final list = data
                      .map((e) =>
                          Message.fromJson(e.data() as Map<String, dynamic>))
                      .toList();
                  if (list.isNotEmpty) {
                    _message = list[0];
                  }

                  return ListTile(
                    // kullanıcı profil fotoğrafı
                    leading: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ProfileDialog(
                                  user: widget.user,
                                ));
                      },
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.all(Radius.circular(mq.height * .3)),
                        child: CachedNetworkImage(
                          width: mq.height * .055,
                          height: mq.height * .055,
                          imageUrl: widget.user.image,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error, size: 50),
                        ),
                      ),
                    ),

                    // kullanıcı adı
                    title: Text(widget.user.name),

                    // son mesaj
                    subtitle: _message?.fromId != APIs.user.uid
                        ? _message?.type == Type.image
                            ? const Row(
                                children: [
                                  Icon(
                                    Icons.photo,
                                    size: 15,
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text("Photo"),
                                ],
                              )
                            : Text(
                                _message != null
                                    ? _message!.msg
                                    : widget.user.about,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                        : _message?.type == Type.image
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.done_all_rounded,
                                    size: 17,
                                    color: _message!.read.isEmpty
                                        ? Colors.grey
                                        : Colors.blue,
                                  ),
                                  const Icon(
                                    Icons.photo,
                                    size: 15,
                                  ),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  const Text("Photo"),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(
                                    Icons.done_all_rounded,
                                    size: 17,
                                    color: _message!.read.isEmpty
                                        ? Colors.grey
                                        : Colors.blue,
                                  ),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(_message!.msg),
                                ],
                              ),

                    // son mesaj zamanı
                    trailing: _message == null
                        ? null
                        : _message!.read.isEmpty &&
                                _message?.fromId != APIs.user.uid
                            ? Container(
                                height: 15,
                                width: 15,
                                decoration: BoxDecoration(
                                    color: Colors.greenAccent.shade400,
                                    borderRadius: BorderRadius.circular(10)),
                              )
                            : Text(
                                DateUtil.getLastMessageTime(
                                    context: context, time: _message!.sent),
                                style: const TextStyle(color: Colors.black54),
                              ),
                  );
              }
            },
          )),
    );
  }
}
