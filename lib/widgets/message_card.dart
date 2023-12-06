// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:wechat/api/apis.dart';
import 'package:wechat/helper/date_util.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:wechat/main.dart';
import 'package:wechat/models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message, required this.state});

  final Message message;
  final bool state;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        messageDetailsBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty &&
        ModalRoute.of(context)?.isCurrent == true &&
        widget.state) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(widget.message.type == Type.image
                    ? mq.width * .03
                    : mq.width * .04),
                margin: EdgeInsets.symmetric(
                    horizontal: mq.width * .04, vertical: mq.height * .01),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 221, 245, 255),
                  border: Border.all(color: Colors.lightBlue),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                      )
                    : ClipRRect(
                        borderRadius:
                            BorderRadius.all(Radius.circular(mq.height * .03)),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image, size: 70),
                        ),
                      ),
              ),
              if (widget.message.edited.isNotEmpty)
                Positioned(
                  bottom: mq.width * .035,
                  left: mq.width * .055,
                  child: const Text(
                    "edited",
                    style: TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),

        // message time
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            DateUtil.getFormattedTime(context, widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // for adding some space
            SizedBox(
              width: mq.width * .04,
            ),

            if (widget.message.read.isNotEmpty)
              //double tick blue icon
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),

            if (widget.message.read.isEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.grey,
                size: 20,
              ),

            const SizedBox(
              width: 2,
            ),

            Padding(
              padding: EdgeInsets.only(left: mq.width * .04),
              child: Text(
                DateUtil.getFormattedTime(context, widget.message.sent),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ],
        ),

        // message box
        Flexible(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(widget.message.type == Type.image
                    ? mq.width * .03
                    : mq.width * .04),
                margin: EdgeInsets.symmetric(
                    horizontal: mq.width * .04, vertical: mq.height * .01),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 218, 255, 176),
                  border: Border.all(color: Colors.lightGreen),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                      )
                    : ClipRRect(
                        borderRadius:
                            BorderRadius.all(Radius.circular(mq.height * .03)),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(strokeWidth: 2),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image, size: 70),
                        ),
                      ),
              ),
              if (widget.message.edited.isNotEmpty)
                Positioned(
                  bottom: mq.width * .035,
                  right: mq.width * .055,
                  child: const Text(
                    "edited",
                    style: TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void messageDetailsBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              // black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              if (widget.message.type == Type.text)
                // Copy Item
                _OptionItem(
                    const Icon(
                      Icons.copy_all_rounded,
                      color: Colors.blue,
                      size: 20,
                    ),
                    "Copy Text", () async {
                  await Clipboard.setData(
                          ClipboardData(text: widget.message.msg))
                      .then((value) {
                    Navigator.pop(context);
                  });
                }),

              if (widget.message.type == Type.image)
                // Copy Item
                _OptionItem(
                    const Icon(
                      Icons.download_rounded,
                      color: Colors.blue,
                      size: 20,
                    ),
                    "Save Image", () async {
                  Navigator.pop(context);
                  Dialogs.showProgressbar(context);
                  await _saveImage(widget.message.msg, 100);
                  Navigator.pop(context);
                  Dialogs.showSnackBar(context, "Picture is saved!");
                }),

              // Divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

              if (widget.message.type == Type.text && isMe)
                // Edit option
                _OptionItem(
                    const Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 20,
                    ),
                    "Edit Message", () {
                  Navigator.pop(context);
                  _showMessageUpdateDialog();
                }),

              if (isMe)
                // Delete option
                _OptionItem(
                    const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                      size: 20,
                    ),
                    "Delete Message", () async {
                  await APIs.deleteMessage(widget.message);

                  Navigator.pop(context);
                }),

              if (isMe)
                // Divider
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

              // Sent Time Option
              _OptionItem(
                  const Icon(
                    Icons.remove_red_eye,
                    color: Colors.blue,
                    size: 20,
                  ),
                  "Sent At: ${DateUtil.getMessageTime(context: context, time: widget.message.sent)}",
                  () {}),

              // read time
              _OptionItem(
                  const Icon(
                    Icons.remove_red_eye,
                    color: Colors.green,
                    size: 20,
                  ),
                  "Seen At: ${widget.message.read == "" ? "Not seen yet" : DateUtil.getMessageTime(context: context, time: widget.message.read)}",
                  () {}),

              if (widget.message.edited.isNotEmpty)
                // edited time
                _OptionItem(
                    const Icon(
                      Icons.update,
                      color: Colors.blue,
                      size: 20,
                    ),
                    "Edited At: ${DateUtil.getMessageTime(context: context, time: widget.message.edited)}",
                    () {}),
            ],
          );
        });
  }

  Future<bool> _saveImage(String url, int quality) async {
    try {
      var response = await Dio()
          .get(url, options: Options(responseType: ResponseType.bytes));
      await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
          quality: quality, name: "WeChatImage");
      return true;
    } catch (e) {
      return false;
    }
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding:
                  const EdgeInsets.only(left: 24, right: 24, top: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Text("Update Message"),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                ],
              ),
              content: TextFormField(
                initialValue: updatedMsg,
                minLines: 1,
                maxLines: 4,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              actions: [
                // cancel button
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),

                // update button
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await APIs.updateMessage(widget.message, updatedMsg);
                  },
                  child: const Text(
                    "Update",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(this.icon, this.name, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.height * .015),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              "        $name",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            ))
          ],
        ),
      ),
    );
  }
}
