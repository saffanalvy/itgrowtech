import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_cubit.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_state.dart';
import 'package:itgrowtech/logic/cubits/profile_cubit/profile_cubit.dart';
import 'package:itgrowtech/logic/cubits/profile_cubit/profile_state.dart';
import 'package:itgrowtech/presentation/screens/auth/auth_screen.dart';
import 'package:itgrowtech/utils/const/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ProfileCubit>().getProfileData();
    });
  }

  void _logout(BuildContext context) {
    context.read<AuthCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LoggedOutState) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile", style: TextStyle(color: kPrimaryColor),),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: kPrimaryColor,),
                  onPressed: () => _logout(context),
                ),
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state is ProfileLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProfileErrorState) {
      return _ErrorView(message: state.message);
    }

    if (state is ReloginState) {
      Future.microtask(() => context.read<AuthCubit>().logout());
      return const _ErrorView(
        message: "Session expired. Redirecting to login...",
      );
    }

    if (state is ProfileLoadedState) {
      return _ProfileContent(profile: state.profile);
    }

    return const _ErrorView(message: "Something went wrong");
  }
}

//Profile screen widget
class _ProfileContent extends StatelessWidget {
  final dynamic profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(profile: profile),
                  const SizedBox(height: 16),

                  _ActionRow(),

                  const SizedBox(height: 16),

                  _InfoCard(profile: profile),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

//Header card
class _HeaderCard extends StatelessWidget {
  final dynamic profile;

  const _HeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name ?? "Unknown User",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Phone: ${profile.phone ?? '-'}"),
                  Text("City: ${profile.city ?? '-'}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Action buttons for other screens
class _ActionRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, "/signal"),
            icon: const Icon(Icons.show_chart),
            label: const Text("Signal"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, "/promo"),
            icon: const Icon(Icons.local_offer),
            label: const Text("Promo"),
          ),
        ),
      ],
    );
  }
}

//Profile details
class _InfoCard extends StatelessWidget {
  final dynamic profile;

  const _InfoCard({required this.profile});

  Widget _row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              "${value ?? '-'}",
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
            _row("Address", profile.address),
            _row("Balance", profile.balance),
            _row("Country", profile.country),
            _row("Currency", profile.currency),
            _row("Equity", profile.equity),
            _row("Free Margin", profile.freeMargin),
            _row("Leverage", profile.leverage),
            _row("Type", profile.type),
            _row("Verification", profile.verificationLevel),
            _row("Trades Count", profile.totalTradesCount),
            _row("Volume", profile.totalTradesVolume),
            _row("Swap Free", profile.isSwapFree),
            _row("Open Trades", profile.isAnyOpenTrades),
          ],
        ),
      ),
    );
  }
}

//Error view
class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: kErrorColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}