import 'package:bank_app/Screens/transferMoney.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../SQFLite/dbHandler.dart';
import '../SQFLite/db_model.dart';
import '../Utils/constants.dart';
import '../Utils/global.dart';

class Home extends StatefulWidget {
  final int? id;

  const Home({super.key, this.id});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DBHelper? dbHelper;
  late Future<List<DBModel>> notesList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper = DBHelper();
    loadData();
    const DataList();
  }

  loadData() async {
    notesList = dbHelper!.getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.white, // <-- SEE HERE
        ),

        backgroundColor: AppColor.backgroundColor,
        // elevation: 0,
        title: Text(
          'Basic Banking App',
          style: TextStyle(color: AppColor.textColorWhite),
        ),
        centerTitle: true,
      ),
      body: const Column(children: [
        Expanded(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: DataList(),
        ))
      ]),
      floatingActionButton: FloatingActionButton(
       child: const Icon(Icons.add),
       onPressed: () {
        dbHelper!
              .insert(DBModel(
               name: 'ahmed amgad',
                 currentBalance: 32000,
                  email: 'ahmed123@gmail.com'))
             .then((value) {
        setState(() {
            notesList = dbHelper!.getList();
           });

            if (kDebugMode) {
              print('Data Added');
            }
        }).onError((error, stackTrace) {
            if (kDebugMode) {
              print(error.toString());
            }
          });
         },),
    );
  }
}

class DataList extends StatefulWidget {
  const DataList({super.key});

  @override
  State<DataList> createState() => _DataListState();
}

class _DataListState extends State<DataList> {
  DBHelper? dbHelper;
  late Future<List<DBModel>> notesList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper = DBHelper();
    loadData();
  }

  loadData() async {
    setState(() {
      notesList = dbHelper!.getList();
    });
  }

  double fontSize = 16;

  int? expandedIndex;

  void toggleDetail(int index) {
    if (expandedIndex == index) {
      setState(() {
        expandedIndex = null;
      });
    } else {
      setState(() {
        expandedIndex = index;
      });
    }
  }

  Future<void> onRefresh() async {
    return loadData();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return loadData() != null
        ? RefreshIndicator(
            onRefresh: onRefresh,
            color: AppColor.backgroundColor,
            child: FutureBuilder(
                future: notesList,
                builder: (context, AsyncSnapshot<List<DBModel>> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext ctx, index) {
                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 13),
                              child: GestureDetector(
                                onLongPress: () {
                                  deletePopup(context, () {
                                    setState(() {
                                      dbHelper!
                                          .deleteUser(snapshot.data![index].id!)
                                          .then((value) {
                                        Navigator.pop(context);
                                      }).onError((error, stackTrace) {
                                        if (kDebugMode) {
                                          print(error.toString());
                                        }
                                      });
                                      notesList = dbHelper!.getList();
                                      snapshot.data!
                                          .remove(snapshot.data![index]);
                                    });
                                  });
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  elevation: 10,
                                  shadowColor: Colors.grey,
                                  color: AppColor.backgroundContainer,
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: expandedIndex == index
                                        ? height * 0.63
                                        : height * 0.36,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 20),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                AppColor.backgroundColor,
                                            radius: height * 0.071,
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  AppColor.backgroundColor,
                                              backgroundImage: const AssetImage(
                                                'assets/place.png',
                                              ),
                                              radius: height * 0.07,
                                            ),
                                          ),
                                          SizedBox(height: height * 0.02),
                                          Flexible(
                                            child: Text(
                                              snapshot.data![index].name
                                                  .toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 20,
                                                color: AppColor.backgroundColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: width * 0.33,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                toggleDetail(index);
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        AppColor
                                                            .backgroundColor),
                                              ),
                                              child: Center(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.touch_app,
                                                      color: AppColor
                                                          .iconColorWhite,
                                                    ),
                                                    Text(
                                                      'Details',
                                                      style: TextStyle(
                                                          color: AppColor
                                                              .textColorWhite),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          if (expandedIndex == index)
                                            Container(
                                              height: height * 0.27,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(
                                                              0.5), // shadow color
                                                      spreadRadius:
                                                          2, // how spread out the shadow is
                                                      blurRadius:
                                                          5, // how blurry the shadow is
                                                      offset: const Offset(0,
                                                          1), // offset of the shadow
                                                    ),
                                                  ],
                                                  color: AppColor
                                                      .backgroundContainerSmall,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        text: 'Name: ',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: fontSize,
                                                            color:
                                                                Colors.black),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: snapshot
                                                                  .data![index]
                                                                  .name
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    RichText(
                                                      text: TextSpan(
                                                        text: 'Email: ',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: fontSize,
                                                            color:
                                                                Colors.black),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: snapshot
                                                                  .data![index]
                                                                  .email
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 15,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    RichText(
                                                      text: TextSpan(
                                                        text:
                                                            'Current Balance: ',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: fontSize,
                                                            color:
                                                                Colors.black),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: snapshot
                                                                  .data![index]
                                                                  .currentBalance
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    Center(
                                                      child: SizedBox(
                                                        width: width * 0.49,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            GlobalVariables()
                                                                    .email =
                                                                snapshot
                                                                    .data![
                                                                        index]
                                                                    .name!;
                                                            GlobalVariables()
                                                                    .id =
                                                                snapshot
                                                                    .data![
                                                                        index]
                                                                    .id!;
                                                            GlobalVariables()
                                                                    .name =
                                                                snapshot
                                                                    .data![
                                                                        index]
                                                                    .name!;
                                                            GlobalVariables()
                                                                    .currentBalance =
                                                                snapshot
                                                                    .data![
                                                                        index]
                                                                    .currentBalance!;
                                                            if (kDebugMode) {
                                                              print(GlobalVariables()
                                                                      .id =
                                                                  snapshot
                                                                      .data![
                                                                          index]
                                                                      .id!);
                                                            }

                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        TransferMoney()));

                                                            // dbHelper!
                                                            //     .updateUser(DBModel(
                                                            //         id: snapshot
                                                            //             .data![
                                                            //                 index]
                                                            //             .id,
                                                            //         name:
                                                            //             "Rakesh Kumar",
                                                            //         currentBalance:
                                                            //             5000,
                                                            //         email:
                                                            //             'dummy@gmail.com'))
                                                            //     .then((value) {
                                                            //   setState(() {
                                                            //     notesList =
                                                            //         dbHelper!
                                                            //             .getList();
                                                            //   });
                                                            // }).onError((error,
                                                            //         stackTrace) {
                                                            //   print(error
                                                            //       .toString());
                                                            // });
                                                            // //  toggleDetail(index);
                                                          },
                                                          style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(AppColor
                                                                        .backgroundColor),
                                                          ),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .attach_money,
                                                                color: AppColor
                                                                    .iconColorWhite,
                                                              ),
                                                              Text(
                                                                'Transfer Money',
                                                                style: TextStyle(
                                                                    color: AppColor
                                                                        .textColorWhite),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 13,
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColor.backgroundColor,
                        strokeWidth: 3,
                      ),
                    );
                  }
                }))
        : Container();
  }
}

Future<bool> deletePopup(context, VoidCallback onPress) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Do you want to delete this user?"),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onPress,
                        child: Text("Yes"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.iconColorWhite),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        print('no selected');
                        Navigator.of(context).pop();
                      },
                      child: Text("No", style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.iconColorWhite),
                    ))
                  ],
                )
              ],
            ),
          ),
        );
      });
}
