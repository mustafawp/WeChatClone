// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat/api/apis.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:wechat/main.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/screens/profile_screen.dart';
import 'package:wechat/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains("resume")) {
          APIs.updateActiveStatus(true, false);
        }
        if (message.toString().contains("pause")) {
          APIs.updateActiveStatus(false, false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          // app bar
          appBar: AppBar(
            leading: InkWell(
                onTap: () {
                  setState(() {
                    if (_isSearching) _isSearching = !_isSearching;
                  });
                },
                child: const Icon(CupertinoIcons.home)),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Sohbetlerde ara..."),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    controller: _searchController,
                    onChanged: (val) {
                      _searchList.clear();
                      if (val.isNotEmpty) {
                        // search login
                        for (var i in list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      }
                    },
                  )
                : const Text("WeChat"),
            actions: [
              // search user button
              if (_searchController.text.isNotEmpty || !_isSearching)
                IconButton(
                    onPressed: () {
                      setState(() {
                        if (_isSearching)
                          _searchController.clear();
                        else
                          _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(_isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search)),

              // more features button
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  user: APIs.me,
                                )));
                  },
                  icon: const Icon(Icons.more_vert)),
            ],
          ),

          // floating button to add new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton(
              onPressed: () async {
                _showAddUserPage();
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersID(),

            //get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    //get only those user, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                              child: CircularProgressIndicator());

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          list = data
                                  ?.map((e) => ChatUser.fromMap(e.data()))
                                  .toList() ??
                              [];

                          if (list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _isSearching
                                    ? _searchList.length
                                    : list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('Burada hiçkimse yok :/',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  void _showAddUserPage() {
    String email = "";

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding:
                  const EdgeInsets.only(left: 24, right: 24, top: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Text("Kullanıcı Ekle"),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                ],
              ),
              content: TextFormField(
                initialValue: "",
                minLines: 1,
                maxLength: 40,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                  hintText: "Eposta adresi..",
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Colors.blue,
                  ),
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
                    "Vazgeç",
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
                    if (email.isNotEmpty) {
                      Dialogs.showProgressbar(context);
                      bool state = await APIs.addChatUser(email);
                      Navigator.pop(context);
                      if (!state) {
                        Dialogs.showSnackBar(
                            context, "Böyle bir kullanıcı bulunamadı!");
                      }
                    } else {
                      Dialogs.showSnackBar(
                          context, "Lütfen eposta adresi girin.");
                    }
                  },
                  child: const Text(
                    "Ekle",
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
