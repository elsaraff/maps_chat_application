import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/shared/functions.dart';
import 'package:flutter_maps/phone_auth_cubit/phone_auth_cubit.dart';
import 'package:flutter_maps/phone_auth_cubit/phone_auth_states.dart';
import 'package:flutter_maps/screens/otp_screen.dart';

// https://receivesms.cc/      to Receive SMS online

final TextEditingController phoneNumberController = TextEditingController();

class LoginScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhoneAuthCubit, PhoneAuthStates>(
      listener: (context, state) {
        if (state is PhoneSubmitted) {
          navigateTo(context, const OTPScreen());
        }
        if (state is PhoneAuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              state.error.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.deepPurple,
            duration: const Duration(seconds: 5),
          ));
        }
      },
      builder: (context, state) {
        var cubit = PhoneAuthCubit.get(context);
        return Scaffold(
          body: SafeArea(
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What is your phone number?',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15.0),
                    const Text(
                      'Please enter your phone number to verify your account',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 50.0),
                    TextFormField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      onChanged: (c) {
                        finalPhoneNumber = c;
                      },
                    ),
                    const SizedBox(height: 30.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(10)),
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            //https://stackoverflow.com/questions/64952016/firebase-phone-authentication-is-not-working-on-android-real-device
                            debugPrint(finalPhoneNumber.toString());
                            cubit.submitPhoneNumber(finalPhoneNumber!);
                          }
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    if (state is PhoneAuthLoading)
                      const LinearProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
