import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';

import 'package:itgrowtech/logic/cubits/auth_cubit/auth_cubit.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_state.dart';
import 'package:itgrowtech/logic/cubits/signal_cubit/signal_cubit.dart';
import 'package:itgrowtech/logic/cubits/signal_cubit/signal_state.dart';
import 'package:itgrowtech/presentation/screens/auth/auth_screen.dart';
import 'package:itgrowtech/utils/const/colors.dart';

class SignalScreen extends StatefulWidget {
  const SignalScreen({super.key});

  @override
  State<SignalScreen> createState() => _SignalScreenState();
}

class _SignalScreenState extends State<SignalScreen> {
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  List<String> _selectedPairs = [];

  bool _isSheetOpen = false;

  Future<void> _pickDate({
    required bool isFrom,
  }) async {
    final initial = isFrom ? _fromDate : _toDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (picked == null) return;

    setState(() {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  void _fetchSignals(BuildContext context) {
    if (_selectedPairs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one currency pair")),
      );
      return;
    }

    final currencyPairs = _selectedPairs.join(",");

    final from = (_fromDate.millisecondsSinceEpoch / 1000).round();
    final to = (_toDate.millisecondsSinceEpoch / 1000).round();

    context.read<SignalCubit>().getSignals(currencyPairs, from, to);

    _openBottomSheet(context);
  }

  void _openBottomSheet(BuildContext context) {
    if (_isSheetOpen) return;

    _isSheetOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<SignalCubit>(),
          child: BlocBuilder<SignalCubit, SignalState>(
            builder: (context, stateB) {
              return _SignalResultSheet(state: stateB);
            },
          ),
        );
      },
    ).whenComplete(() => _isSheetOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is LoadingState) {
          return const _LoadingScaffold();
        }

        if (authState is ErrorState) {
          return _MessageScaffold(
            title: "Signal",
            message: authState.message,
          );
        }

        if (authState is LoggedOutState) {
          return const AuthScreen();
        }

        if (authState is! LoggedInState) {
          return const _MessageScaffold(
            message: "Unexpected authentication",
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Signals", style: TextStyle(color: kPrimaryColor)),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: kPrimaryColor,),
                onPressed: () {
                  context.read<AuthCubit>().logout();
                },
              )
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _DateCard(
                            fromDate: _fromDate,
                            toDate: _toDate,
                            onPickFrom: () => _pickDate(isFrom: true),
                            onPickTo: () => _pickDate(isFrom: false),
                          ),
                          const SizedBox(height: 16),

                          _PairSelector(
                            selected: _selectedPairs,
                            onChanged: (values) {
                              setState(() => _selectedPairs = values);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () => _fetchSignals(context),
            child: const Icon(Icons.search),
          ),
        );
      },
    );
  }
}

//Date card
class _DateCard extends StatelessWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;

  const _DateCard({
    required this.fromDate,
    required this.toDate,
    required this.onPickFrom,
    required this.onPickTo,
  });

  Widget _row(String label, DateTime date, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$label: ${date.year}-${date.month}-${date.day}"),
        ElevatedButton(
          onPressed: onTap,
          child: const Text("Choose"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row("From", fromDate, onPickFrom),
            const SizedBox(height: 12),
            _row("To", toDate, onPickTo),
          ],
        ),
      ),
    );
  }
}

//Currency pairs
class _PairSelector extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const _PairSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: MultiSelectContainer(
          items: [
            MultiSelectCard(value: 'EURUSD', label: 'EURUSD'),
            MultiSelectCard(value: 'GBPUSD', label: 'GBPUSD'),
            MultiSelectCard(value: 'USDJPY', label: 'USDJPY'),
            MultiSelectCard(value: 'USDCHF', label: 'USDCHF'),
            MultiSelectCard(value: 'USDCAD', label: 'USDCAD'),
            MultiSelectCard(value: 'AUDUSD', label: 'AUDUSD'),
            MultiSelectCard(value: 'NZDUSD', label: 'NZDUSD'),
          ],
          onChange: (allSelected, _) {
            onChanged(allSelected);
          },
        ),
      ),
    );
  }
}

//Modal bottom sheet
class _SignalResultSheet extends StatelessWidget {
  final SignalState state;

  const _SignalResultSheet({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is SignalLoadingState) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is SignalErrorState) {

      final errorState = state as SignalErrorState;

      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(errorState.message, style: TextStyle(color: kErrorColor),),
      );
    }

    if (state is SignalReloginState) {
      Future.microtask(() {
        context.read<AuthCubit>().logout();
      });

      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("Session expired. Redirecting to login..."),
      );
    }

    if (state is SignalLoadedState) {

      final loadedState = state as SignalLoadedState;

      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: loadedState.signals.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final s = loadedState.signals[i];

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pair: ${s.pair}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s.cmd.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Details
                  Text("Price: ${s.price}"),
                  Text("SL: ${s.sl}  |  TP: ${s.tp}"),
                  const SizedBox(height: 4),
                  Text(
                    "Time: ${s.actualTime}",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return const Padding(
      padding: EdgeInsets.all(20),
      child: Text("No data available"),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _MessageScaffold extends StatelessWidget {
  final String message;
  final String? title;

  const _MessageScaffold({
    required this.message,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null ? AppBar(title: Text(title!)) : null,
      body: Center(child: Text(message)),
    );
  }
}