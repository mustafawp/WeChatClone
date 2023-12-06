import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat/api/apis.dart';
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

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains("resume")) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains("pause")) {
          APIs.updateActiveStatus(false);
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
                child: Icon(CupertinoIcons.home)),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search by name or mail.."),
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
                : const Text("We Chat"),
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
              onPressed: () async {},
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),

          body: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );

                case ConnectionState.active:
                case ConnectionState.done:
              }

              if (snapshot.hasData) {
                final data = snapshot.data?.docs;
                list = data!.map((e) => ChatUser.fromMap(e.data())).toList();
              }

              if (list.isNotEmpty) {
                return ListView.builder(
                  itemCount: _isSearching ? _searchList.length : list.length,
                  padding: EdgeInsets.only(top: mq.height * .01),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChatUserCard(
                        user: _isSearching ? _searchList[index] : list[index]);
                  },
                );
              } else {
                return const Center(
                  child: Text(
                    "No Connections Found!",
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
