import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../SQFLite/dbHandler.dart';
import '../SQFLite/db_model.dart';
import '../Utils/constants.dart';
import '../Utils/flutterToast.dart';
import '../Utils/global.dart';


class TransferMoney extends StatefulWidget {
  const TransferMoney({Key? key}) : super(key: key);

  @override
  State<TransferMoney> createState() => _TransferMoneyState();
}

class _TransferMoneyState extends State<TransferMoney> {
  DBHelper? dbHelper;
  late Future<List<DBModel>> transferList;
  TextEditingController searchController = TextEditingController();
  TextEditingController controlTransfer = TextEditingController();

  List<DBModel> filteredList = [];

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    transferList = dbHelper!.getList();
  }

  void filterSearchResults(String query) {
    List<DBModel> searchResults = [];
    if (query.isNotEmpty) {
      transferList.then((list) {
        for (var item in list) {
          if (item.name!.toLowerCase().contains(query.toLowerCase())) {
            searchResults.add(item);
          }
        }
        setState(() {
          filteredList = searchResults;
        });
      });
    } else {
      transferList.then((list) {
        setState(() {
          filteredList = list;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: searchController,
                onChanged: filterSearchResults,
                decoration: InputDecoration(
                  labelText: 'Search',
                  hintText: 'e.g. ahmed',
                  labelStyle: TextStyle(color: AppColor.backgroundColor),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              filterSearchResults('');
                            });
                          },
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColor.backgroundColor, width: 1.0),
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColor.backgroundColor, width: 2.0),
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<DBModel>>(
                future: transferList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No data found.');
                  } else {
                    return filteredList.isNotEmpty
                        ? ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showTransferDialog(context, () {
                                      double amount = double.tryParse(
                                              controlTransfer.text) ??
                                          0.0;

                                      if (amountChecker(
                                          GlobalVariables().currentBalance,
                                          amount)) {
                                        dbHelper!
                                            .updateUser(DBModel(
                                                id: GlobalVariables().id,
                                                name: GlobalVariables().name,
                                                currentBalance:
                                                    GlobalVariables()
                                                            .currentBalance -
                                                        amount,
                                                email: GlobalVariables().email))
                                            .then((value) {
                                          dbHelper!
                                              .updateUser(
                                            DBModel(
                                                id: filteredList[index].id,
                                                name: filteredList[index].name,
                                                currentBalance:
                                                    filteredList[index]
                                                            .currentBalance! +
                                                        amount,
                                                email:
                                                    filteredList[index].email),
                                          )
                                              .then((value) {
                                                     CustomToast.showToast(
                                              message:
                                                  'Rs.$amount has been added to the account of ${filteredList[index].name}');
                                         
                                          }).onError((error, stackTrace) {
                                            CustomToast.showToast(
                                                message: error.toString());
                                          });
                                             CustomToast.showToast(
                                                message:
                                                    'Rs.$amount has been deducted from the account of ${GlobalVariables().name}');

                                     
                                        }).onError((error, stackTrace) {
                                          if (kDebugMode) {
                                            print(error.toString());
                                          }
                                          CustomToast.showToast(
                                              message: error.toString());
                                          if (kDebugMode) {
                                            print(error.toString());
                                          }
                                        });
                                      } else {
                                        CustomToast.showToast(
                                            message: 'Invalid Amount Entered');
                                      }
                                      Navigator.pop(context);
                                    }, controlTransfer);
                                  });
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                        filteredList[index].name.toString()),
                                    subtitle: Text(
                                      (filteredList[index].email.toString()),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Image.asset('assets/empty.png'),
                          );
                    // ): ListView.builder(
                    //   physics: BouncingScrollPhysics(),
                    //   itemCount: snapshot.data!.length,
                    //   itemBuilder: (context, index) {
                    //     return GestureDetector(
                    //       onTap: (){
                    //       },
                    //       child: Card(
                    //         shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(8.0),

                    //               ),

                    //         child: ListTile(
                    //           title: Text(snapshot.data![index]
                    //               .name
                    //               .toString()), // Replace with the property you want to display
                    //          subtitle: Text(snapshot.data![index].email.toString()),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool amountChecker(double currentBalance, double transferAmount) {
  if (currentBalance >= transferAmount) {
    return true;
  }
  return false;
}

void _showTransferDialog(
  BuildContext context,
  VoidCallback onPress,
  TextEditingController controllerTransfer,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Enter Amount to Transfer',
          style: TextStyle(fontSize: 17),
        ),
        content: TextField(
          controller: controllerTransfer,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(onPressed: onPress, child: const Text('Transfer')),
        ],
      );
    },
  );
}
