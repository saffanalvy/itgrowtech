import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_cubit.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_state.dart';
import 'package:itgrowtech/presentation/screens/profile/profile_screen.dart';
import 'package:itgrowtech/utils/const/colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  final _loginFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _loginFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final loginText = _loginController.text.trim();
    final password = _passwordController.text.trim();

    final loginId = int.tryParse(loginText);

    if (loginId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login must be a valid number")),
      );
      return;
    }

    context.read<AuthCubit>().newLogIn(loginId, password);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is LoggedInState) {
                return const ProfileScreen();
              }

              if (state is LoadingState) {
                return const _LoadingView();
              }

              if (state is ErrorState) {
                return _ErrorView(message: state.message);
              }

              if (state is LoggedOutState) {
                return _AuthForm(
                  formKey: _formKey,
                  loginController: _loginController,
                  passwordController: _passwordController,
                  loginFocus: _loginFocus,
                  passwordFocus: _passwordFocus,
                  obscurePassword: _obscurePassword,
                  onTogglePassword: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  onSubmit: () => _submit(context),
                );
              }

              return const _ErrorView(message: "Unexpected state occurred");
            },
          ),
        ),
      ),
    );
  }
}

//Authentication form widget
class _AuthForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController loginController;
  final TextEditingController passwordController;

  final FocusNode loginFocus;
  final FocusNode passwordFocus;

  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  const _AuthForm({
    required this.formKey,
    required this.loginController,
    required this.passwordController,
    required this.loginFocus,
    required this.passwordFocus,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade50,
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 60,),
                  const SizedBox(height: 12),
                  const Text(
                    "Welcome",
                    style: TextStyle(color: kPrimaryColor, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Login to continue",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  SizedBox(height: isSmall ? 16 : 28),

                  //Login form field
                  TextFormField(
                    controller: loginController,
                    focusNode: loginFocus,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: "Login",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? "Enter login" : null,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(passwordFocus);
                    },
                  ),

                  const SizedBox(height: 16),

                  //Password form field
                  TextFormField(
                    controller: passwordController,
                    focusNode: passwordFocus,
                    obscureText: obscurePassword,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: onTogglePassword,
                      ),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty)
                            ? "Enter password"
                            : null,
                    onFieldSubmitted: (_) => onSubmit(),
                  ),

                  SizedBox(height: isSmall ? 16 : 24),

                  //Login button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onSubmit,
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


//Loading view
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}