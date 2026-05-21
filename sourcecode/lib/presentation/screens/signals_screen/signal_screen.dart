import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_cubit.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_state.dart';
import 'package:itgrowtech/logic/cubits/signal_cubit/signal_cubit.dart';
import 'package:itgrowtech/logic/cubits/signal_cubit/signal_state.dart';
import 'package:itgrowtech/presentation/screens/auth/auth_screen.dart';

class SignalScreen extends StatefulWidget {
  const SignalScreen({super.key});

  @override
  State<SignalScreen> createState() => _SignalScreenState();
}

class _SignalScreenState extends State<SignalScreen> {
  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  List<String> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: ((context, stateA) {
        //Show loading bar
        if (stateA is LoadingState) {
          return Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }

        //Show error message
        if (stateA is ErrorState) {
          return Scaffold(
            appBar: AppBar(title: Text("Signal")),
            body: SafeArea(child: Center(child: Text(stateA.message))),
          );
        }

        //Goto Profile screen if logged in
        if (stateA is LoggedInState) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Signal"),
              actions: [
                IconButton(
                  onPressed: () {
                    context.read<AuthCubit>().logout();
                  },
                  icon: Icon(Icons.logout),
                ),
              ],
            ),
            body: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "From: ${selectedFromDate.year}-${selectedFromDate.month}-${selectedFromDate.day}",
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? dateTime = await showDatePicker(
                          context: context,
                          initialDate: selectedFromDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        );

                        if (dateTime != null) {
                          setState(() {
                            selectedFromDate = dateTime;
                          });
                        }
                      },
                      child: Text("Choose"),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "To: ${selectedToDate.year}-${selectedToDate.month}-${selectedToDate.day}",
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? dateTime = await showDatePicker(
                          context: context,
                          initialDate: selectedToDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        );

                        if (dateTime != null) {
                          setState(() {
                            selectedToDate = dateTime;
                          });
                        }
                      },
                      child: Text("Choose"),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                MultiSelectContainer(
                  items: [
                    MultiSelectCard(value: 'EURUSD', label: 'EURUSD'),
                    MultiSelectCard(value: 'GBPUSD', label: 'GBPUSD'),
                    MultiSelectCard(value: 'USDJPY', label: 'USDJPY'),
                    MultiSelectCard(value: 'USDCHF', label: 'USDCHF'),
                    MultiSelectCard(value: 'USDCAD', label: 'USDCAD'),
                    MultiSelectCard(value: 'AUDUSD', label: 'AUDUSD'),
                    MultiSelectCard(value: 'NZDUSD', label: 'NZDUSD'),
                  ],
                  onChange: (allSelectedItems, selectedItem) {
                    setState(() {
                      selectedItems = allSelectedItems;
                    });
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                String currencyPairs = "";
                for (String item in selectedItems){
                  currencyPairs = "$currencyPairs$item,";
                }
                int dateFrom = (selectedFromDate.millisecondsSinceEpoch / 1000).round();
                int dateTo = (selectedToDate.millisecondsSinceEpoch / 1000).round();

                context.read<SignalCubit>().getSignals(currencyPairs, dateFrom, dateTo);

                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return BlocBuilder<SignalCubit, SignalState>(
                      builder: (context, stateB) {
                        if (stateB is SignalLoadingState) {
                          return Padding(
                              padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                              child: Center(child: CircularProgressIndicator()),
                            );
                        }

                        if (stateB is SignalErrorState) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: Center(child: Text(stateB.message)),
                          );
                        }

                        if (stateB is SignalReloginState) {
                          context.read<AuthCubit>().logout();
                        }

                        if (stateB is SignalLoadedState){
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: ListView.builder(
                              itemCount: stateB.signals.length,
                              itemBuilder: ((context, index) {
                                return ListTile(
                                  title: Text(
                                    "Id: ${stateB.signals[index].id}, ActualTime: ${stateB.signals[index].actualTime}, Comment: ${stateB.signals[index].comment}, Pair: ${stateB.signals[index].pair}, Cmd: ${stateB.signals[index].cmd}, TradingSystem: ${stateB.signals[index].tradingSystem}, Period: ${stateB.signals[index].period}, Price: ${stateB.signals[index].price}, Sl: ${stateB.signals[index].sl}, Tp: ${stateB.signals[index].tp}",
                                  ),
                                );
                              }),
                            ),
                          );
                        }

                        return Padding(
                              padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                              child: Center(child: Text("Some error occured!")),
                            );
                      },
                    );
                  },
                );
              },
              child: Icon(Icons.graphic_eq),
            ),
          );
        }

        //If not logged in then show Auth Screen
        if (stateA is LoggedOutState) {
          return AuthScreen();
        }

        //If any error occurs
        return Scaffold(
          body: SafeArea(child: Center(child: Text("Some error occured!"))),
        );
      }),
    );
  }
}
