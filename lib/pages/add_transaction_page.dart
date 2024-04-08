import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager_app/controllers/db_helper.dart/db_helper.dart';
import 'package:money_manager_app/main.dart';
import 'package:intl/intl.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _HomePageState();
}

class _HomePageState extends State<AddTransaction> {
  // data

  int? amount;
  String note = "Monthly Bills";
  String type = "Income";
  DateTime selectedDate = DateTime.now();

  //

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2022, 12),
        lastDate: DateTime(2101, 01));

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      appBar: AppBar(
        toolbarHeight: 0.0,
      ),

      //
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          //
          const SizedBox(
            height: 20,
          ),

          //
          const Image(
            image: AssetImage('assets/images/moneyverse_money.png'),
            height: 100,
            width: 100,
          ),

          //
          const SizedBox(
            height: 20,
          ),

          const Text(
            'Add Transaction',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia'),
          ),

          //
          const SizedBox(
            height: 20,
          ),

          // expense or income
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.attach_money,
                  size: 24,
                  color: Colors.white,
                ),
              ),

              //
              const SizedBox(
                width: 12,
              ),

              //
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '0',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                  onChanged: (value) {
                    try {
                      amount = int.parse(value);
                    } catch (e) {
                      amount = 0;
                    }
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          //
          const SizedBox(
            height: 20,
          ),

          // description
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: globalColor.primary,
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.description,
                  size: 24,
                  color: Colors.white,
                ),
              ),

              //
              const SizedBox(
                width: 12,
              ),

              //
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Note on Transaction',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  onChanged: (value) => note = value,
                ),
              ),
            ],
          ),

          //
          const SizedBox(
            height: 20,
          ),

          //
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: globalColor.primary,
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.money_sharp,
                  size: 24,
                  color: Colors.white,
                ),
              ),

              //
              const SizedBox(
                width: 12,
              ),

              //
              ChoiceChip(
                  checkmarkColor: Colors.white,
                  label: Text('Income',
                      style: TextStyle(
                          fontSize: 16,
                          color:
                              type == 'Income' ? Colors.white : Colors.black)),
                  selectedColor: globalColor.primary,
                  selected: type == 'Income' ? true : false,
                  onSelected: (value) {
                    if (value) {
                      setState(() {
                        type = 'Income';
                      });
                    }
                  }),

              //
              const SizedBox(
                width: 12,
              ),

              //
              ChoiceChip(
                  checkmarkColor: Colors.white,
                  label: Text('Expense',
                      style: TextStyle(
                          fontSize: 16,
                          color:
                              type == 'Expense' ? Colors.white : Colors.black)),
                  selectedColor: globalColor.primary,
                  selected: type == 'Expense' ? true : false,
                  onSelected: (value) {
                    if (value) {
                      setState(() {
                        type = 'Expense';
                      });
                    }
                  }),
            ],
          ),

          //
          const SizedBox(
            height: 20,
          ),

          //
          SizedBox(
            height: 50,
            child: TextButton(
              onPressed: () {
                _selectDate(context);
              },
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero)),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: globalColor.primary,
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.date_range,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),

                  //
                  const SizedBox(
                    width: 12,
                  ),

                  Text(
                    DateFormat('dd MMMM yyyy').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //
          const SizedBox(
            height: 20,
          ),

          //
          SizedBox(
            height: 50,
            child: ElevatedButton(
                onPressed: () async {
                  if (amount != null && note.isNotEmpty) {
                    //
                    DbHelper dbHelper = DbHelper();

                    //
                    await dbHelper.addData(amount!, selectedDate, type, note);

                    // show snackbar
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Transaction Added'),
                        duration: Duration(seconds: 2),
                      ));
                    }

                    // nav to home after 2 seconds
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.pushNamed(context, '/home');
                    });
                  } else {
                    // show snackbar
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: globalColor.error,
                        content: const Text('Please Fill All the Fields'),
                        duration: const Duration(seconds: 2),
                      ));
                    }
                  }
                },
                child: const Text(
                  "Add",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          )
        ],
      ),
    );
  }
}
