import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itgrowtech/utils/const/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:itgrowtech/logic/cubits/auth_cubit/auth_cubit.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_state.dart';
import 'package:itgrowtech/logic/cubits/promo_cubit/promo_cubit.dart';
import 'package:itgrowtech/logic/cubits/promo_cubit/promo_state.dart';
import 'package:itgrowtech/presentation/screens/auth/auth_screen.dart';

class PromoScreen extends StatefulWidget {
  const PromoScreen({super.key});

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PromoCubit>().getPromoData();
    });
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid URL")),
      );
      return;
    }

    final canLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!canLaunch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  void _logout(BuildContext context) {
    context.read<AuthCubit>().logout();
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
            title: "Promo",
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
            title: const Text("Promo", style: TextStyle(color: kPrimaryColor),),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: kPrimaryColor,),
                onPressed: () => _logout(context),
              ),
            ],
          ),
          body: BlocBuilder<PromoCubit, PromoState>(
            builder: (context, promoState) {
              return _buildBody(context, promoState);
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PromoState state) {
    if (state is PromoLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PromoErrorState) {
      return Center(child: Text(state.message, style: TextStyle(color: kErrorColor)));
    }

    if (state is PromoLoadedState) {
      return _PromoList(
        items: state.promoItems,
        onTap: (url) => _openUrl(context, url),
      );
    }

    return const Center(child: Text("Something went wrong"));
  }
}

//Promo list
class _PromoList extends StatelessWidget {
  final List<dynamic> items;
  final Function(String url) onTap;

  const _PromoList({
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];

                final title = item[0]?.toString() ?? "No Title";
                final url = item[1]?.toString() ?? "";
                final image = item[2]?.toString();

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onTap(url),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          if (image != null && image.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                            )
                          else
                            const Icon(Icons.campaign, size: 40),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

//Loading view
class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

//Message view
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}