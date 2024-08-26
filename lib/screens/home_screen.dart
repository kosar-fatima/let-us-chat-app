import 'package:chat_app/APIs/apis.dart';
import 'package:chat_app/helper/dialog.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/size_config.dart';
import 'package:chat_app/widgets/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    APIs.getSelfInfo();
    super.initState();

    // for updating use active time according to the life cycle events
    //resume -- active or online
    //pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
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
          appBar: AppBar(
            leading: Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email, ...',
                    ),
                    autofocus: true,
                    style: TextStyle(fontSize: 18, letterSpacing: 0.5),
                    onChanged: (value) {
                      _searchList.clear();
                      for (var i in list) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Text(
                    'Let us Chat',
                  ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(Icons.search),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ProfileScreen(
                          user: APIs.me,
                        );
                      },
                    ),
                  );
                },
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color.fromARGB(255, 83, 168, 109),
            onPressed: () {
              _AddchatUserDialog();
            },
            child: Icon(Icons.add_comment_outlined),
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            builder: (context, snapshot) {
              return StreamBuilder(
                stream: APIs.getAllUsers(
                    snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                builder: (context, snapshot) {
                  try {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Center(child: CircularProgressIndicator());
                      case ConnectionState.none:
                        return const Text('No data found');
                      case ConnectionState.active:
                      case ConnectionState.done:
                        return StreamBuilder(
                          builder: (context, snapshot) {
                            try {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                case ConnectionState.none:
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                case ConnectionState.active:
                                case ConnectionState.done:
                                  final data = snapshot.data?.docs;
                                  list = data
                                          ?.map((e) =>
                                              ChatUser.fromJson(e.data()))
                                          .toList() ??
                                      [];
                                  if (list.isNotEmpty) {
                                    return ListView.builder(
                                      padding: EdgeInsets.only(
                                          top:
                                              getProportionateScreenHeight(10)),
                                      physics: BouncingScrollPhysics(),
                                      itemCount: _isSearching
                                          ? _searchList.length
                                          : list.length,
                                      itemBuilder: (context, index) {
                                        return ChattingUser(
                                          user: _isSearching
                                              ? _searchList[index]
                                              : list[index],
                                        );
                                      },
                                    );
                                  } else {
                                    return const Center(
                                        child: Text('No Data found!'));
                                  }
                              }
                            } catch (error) {
                              // Handle any errors that occur inside the StreamBuilder's builder callback.
                              print("Error in inner StreamBuilder: $error");
                              return const Center(
                                child: Text('An error occurred.'),
                              );
                            }
                          },
                          stream: APIs.getAllUsers(
                              snapshot.data?.docs.map((e) => e.id).toList() ??
                                  []),
                        );
                    }
                  } catch (error) {
                    // Handle any errors that occur in the outer StreamBuilder.
                    print("Error in outer StreamBuilder: $error");
                    return const Center(
                      child: Text('An error occurred.'),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _AddchatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding:
                const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.person_add,
                  color: Color.fromARGB(255, 0, 42, 49),
                  size: 28,
                ),
                Text(' Add Contact'),
              ],
            ),
            content: TextFormField(
              maxLines: null,
              onChanged: (value) => email = value,
              decoration: InputDecoration(
                hintText: 'Email Id',
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.green,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 42, 49), fontSize: 16),
                ),
              ),
              MaterialButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (email.isNotEmpty) {
                    await APIs.addChatContact(email).then((value) {
                      if (!value) {
                        Dialogs.showSnackBar(context, 'User does not Exists!');
                      }
                    });
                  }
                },
                child: Text(
                  'Add',
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 42, 49), fontSize: 16),
                ),
              ),
            ],
          );
        });
  }
}
