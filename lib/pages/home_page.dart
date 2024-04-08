import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:money_manager_app/controllers/db_helper.dart/db_helper.dart';
import 'package:money_manager_app/main.dart';
import 'package:money_manager_app/modals/transaction_modal.dart';
import 'package:money_manager_app/pages/widgets/confirm_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //

  DbHelper dbHelper = DbHelper();

  // data need to compute entireData
  int totalBalance = 0;
  int totalIncome = 0;
  int totalExpense = 0;

  getTotalBalance(List<TransactionModal> entireData) {
    totalBalance = 0;
    totalIncome = 0;
    totalExpense = 0;

    for (TransactionModal data in entireData) {
      if (data.type == "Income") {
        totalBalance += data.amount!;
        totalIncome += data.amount!;
      } else {
        totalExpense += data.amount!;
        totalBalance -= data.amount!;
      }
    }
  }

  // get plot points
  DateTime today = DateTime.now();
  List<FlSpot> dataSetExpense = [];
  List<FlSpot> dataSetIncome = [];

  // get plot points for expense
  List<FlSpot> getPlotPointsExpense(List<TransactionModal> entireData) {
    dataSetExpense = [];

    List tempDataSetExpense = [];

    // only get the data for the current month
    for (TransactionModal data in entireData) {
      if (data.date!.month == today.month && data.type == 'Expense') {
        tempDataSetExpense.add(data);
      }
    }

    //
    tempDataSetExpense.sort((a, b) => a.date.day.compareTo(b.date.day));

    // Populate dataSetExpense with FlSpot objects
    for (var i = 0; i < tempDataSetExpense.length; i++) {
      dataSetExpense.add(
        FlSpot(
          tempDataSetExpense[i].date.day.toDouble(),
          tempDataSetExpense[i].amount.toDouble(),
        ),
      );
    }

    return dataSetExpense;
  }

  // get plot points for income
  List<FlSpot> getPlotPointsIncome(List<TransactionModal> entireData) {
    dataSetIncome = [];

    List tempdataSetIncome = [];

    // only get the data for the current month
    for (TransactionModal data in entireData) {
      if (data.date!.month == today.month && data.type == 'Income') {
        tempdataSetIncome.add(data);
      }
    }

    //
    tempdataSetIncome.sort((a, b) => a.date.day.compareTo(b.date.day));

    // Populate dataSetIncome with FlSpot objects
    for (var i = 0; i < tempdataSetIncome.length; i++) {
      dataSetIncome.add(
        FlSpot(
          tempdataSetIncome[i].date.day.toDouble(),
          tempdataSetIncome[i].amount.toDouble(),
        ),
      );
    }

    return dataSetIncome;
  }

  @override
  void initState() {
    super.initState();
    getUserName();
    box = Hive.box('money');
    fetchData();
  }

  // get user name
  String? userName;

  void getUserName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userName = preferences.getString('name');
    });
  }

  //
  late Box box;

  //
  Future<List<TransactionModal>> fetchData() async {
    if (box.values.isEmpty) {
      return Future.value([]);
    } else {
      List<TransactionModal> data = [];

      box.toMap().values.forEach((element) {
        data.add(TransactionModal(
            amount: element['amount'] as int,
            date: element['date'] as DateTime,
            note: element['note'],
            type: element['type']));
      });

      return data;
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      appBar: AppBar(
        surfaceTintColor: globalColor.tertiaryContainer,
        toolbarHeight: 50,
        leading: const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Image(
            image: AssetImage('assets/images/logo_v1.png'),
            width: 80,
          ),
        ),
        leadingWidth: 90,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.settings,
              size: 35,
              color: globalColor.onSecondaryContainer,
            ),
          ),
        ],
      ),

      //
      body: Column(
        children: [
          //
          const SizedBox(
            height: 6,
          ),

          //
          Container(
            margin: const EdgeInsets.all(6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.person,
                  color: globalColor.primary,
                  size: 50,
                ),

                //
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome,  ',
                        style: TextStyle(
                          color: globalColor.onSecondaryContainer,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '$userName',
                        style: TextStyle(
                          color: globalColor.primary,
                          fontSize: 20,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                //
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add_transaction')
                        .whenComplete(() {
                      setState(() {});
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                    backgroundColor: globalColor.primaryContainer,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 25,
                  ),
                )
              ],
            ),
          ),

          //
          Expanded(
            child: FutureBuilder<List<TransactionModal>>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Unexpected Error!'),
                  );
                }

                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No Values Found'),
                    );
                  } else {
                    //
                    getTotalBalance(snapshot.data!);
                    getPlotPointsExpense(snapshot.data!);
                    getPlotPointsIncome(snapshot.data!);
                    return ListView(
                      shrinkWrap: true,
                      children: [
                        //
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          margin: const EdgeInsets.all(12),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  globalColor.onPrimaryContainer,
                                  globalColor.primary
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: globalColor.outline.withOpacity(0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 8),
                            child: Column(
                              children: [
                                const Text(
                                  'Total Balance (Php)',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                ),

                                //
                                const SizedBox(
                                  height: 8,
                                ),

                                //
                                Text(
                                  textAlign: TextAlign.center,
                                  NumberFormat('#,###').format(totalBalance),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontFamily: 'Georgia',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),

                                //
                                const SizedBox(
                                  height: 12,
                                ),

                                //
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          incomeCard(totalIncome),
                                          expenseCard(totalExpense),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                        //
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'Transactions',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Georgia',
                              color: globalColor.onSecondaryContainer,
                            ),
                          ),
                        ),

                        //
                        dataSetExpense.isEmpty && dataSetIncome.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  color: globalColor.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          globalColor.outline.withOpacity(0.5),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.all(12),
                                height: 300,
                                child: Center(
                                  child: Text(
                                    'Not enough data to plot graph',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: globalColor.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: globalColor.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          globalColor.outline.withOpacity(0.5),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.only(
                                    top: 20, right: 20, bottom: 10),
                                margin: const EdgeInsets.all(12),
                                height: 300,
                                child: Center(
                                  child: LineChart(
                                    LineChartData(
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                            spots: getPlotPointsExpense(
                                                snapshot.data!),
                                            isCurved: false,
                                            barWidth: 2.5,
                                            color: globalColor.primary),

                                        // second line
                                        LineChartBarData(
                                            spots: getPlotPointsIncome(
                                                snapshot.data!),
                                            isCurved: false,
                                            barWidth: 2.5,
                                            color: globalColor.secondary),
                                      ],
                                      titlesData: const FlTitlesData(
                                        show: true,
                                        topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                        //
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Georgia',
                              color: globalColor.onSecondaryContainer,
                            ),
                          ),
                        ),

                        //
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            TransactionModal dataAtIndex =
                                snapshot.data![index];

                            // create a table that has 2 columns 1 row
                            if (dataAtIndex.type! == 'Income') {
                              return incomeTile(dataAtIndex.amount!,
                                  dataAtIndex.note!, dataAtIndex.date!, index);
                            } else {
                              return expenseTile(dataAtIndex.amount!,
                                  dataAtIndex.note!, dataAtIndex.date!, index);
                            }
                          },
                        ),

                        //
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    );
                  }
                } else {
                  return const Center(
                    child: Text("Unexpected Error!"),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  //
  Widget incomeCard(int value) {
    return Expanded(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: globalColor.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.wallet,
                size: 28,
                color: globalColor.secondary,
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Income (Php)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),

                  //
                  Column(
                    children: [
                      Text(
                        NumberFormat('#,###').format(value),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia',
                          color: Colors.white,
                        ),
                      ),

                      //
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget expenseCard(int value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: globalColor.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(6),
          margin: const EdgeInsets.only(right: 12),
          child: Icon(
            Icons.money_off,
            size: 28,
            color: globalColor.primary,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense (Php)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),

            //
            Text(
              NumberFormat('#,###').format(value),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
                color: Colors.white,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget expenseTile(int value, String note, DateTime date, int index) {
    return InkWell(
      onLongPress: () async {
        bool? answer = await showConfirmDialog(
            context, "WARNING!!!", "Do you want to DELETE this record?");

        if (answer != null && answer) {
          dbHelper.deleteData(index);
          setState(() {});
        }
      },
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: globalColor.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.wallet,
                      size: 28,
                      color: globalColor.primary,
                    ),

                    //
                    const SizedBox(
                      width: 12,
                    ),

                    //
                    Text("Expense",
                        style:
                            TextStyle(color: globalColor.onSecondaryContainer)),
                  ],
                ),

                //
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    DateFormat('MMM dd yyyy').format(date),
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      color: globalColor.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),

            //
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ' - Php ${NumberFormat('#,###').format(value)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                    color: globalColor.primary,
                  ),
                ),

                //
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    "Note: $note",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      color: globalColor.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget incomeTile(int value, String note, DateTime date, int index) {
    return InkWell(
      onLongPress: () async {
        bool? answer = await showConfirmDialog(
            context, "WARNING!!!", "Do you want to DELETE this record?");

        if (answer! && answer) {
          dbHelper.deleteData(index);
          setState(() {});
        }
      },
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: globalColor.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.wallet,
                      size: 28,
                      color: globalColor.secondary,
                    ),

                    //
                    const SizedBox(
                      width: 12,
                    ),

                    //
                    Text("Income",
                        style:
                            TextStyle(color: globalColor.onSecondaryContainer)),
                  ],
                ),

                //
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    DateFormat('MMM dd yyyy').format(date),
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      color: globalColor.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),

            //
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ' + Php ${NumberFormat('#,###').format(value)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                    color: globalColor.secondary,
                  ),
                ),

                //
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    "Note: $note",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      color: globalColor.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
