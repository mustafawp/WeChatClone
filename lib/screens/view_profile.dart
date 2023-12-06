import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wechat/helper/date_util.dart';
import 'package:wechat/main.dart';
import 'package:wechat/models/chat_user.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          // app bar
          appBar: AppBar(
            title: Text(widget.user.name),
          ),
          floatingActionButton: // user about
              Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Katılım Tarihi: ",
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
              Text(
                DateUtil.getLastMessageTime(
                    context: context,
                    time: widget.user.createdAt,
                    showYear: true),
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ],
          ),

          //body
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // üstten ve yanlardan biraz boşluk
                  SizedBox(width: mq.width, height: mq.height * .03),

                  // profil fotoğrafı gösterme ve düzenleme
                  ClipRRect(
                    borderRadius:
                        BorderRadius.all(Radius.circular(mq.height * .1)),
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

                  // dikeyden boşluk
                  SizedBox(height: mq.height * .03),

                  // kullanıcı maili
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),

                  // dikeyden boşluk
                  SizedBox(height: mq.height * .04),

                  // user about
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Hakkında",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(
                          height:
                              8), // İsteğe bağlı: Biraz boşluk ekleyebilirsiniz.
                      Text(
                        widget.user.about,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
