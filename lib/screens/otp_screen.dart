import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/app_cubit/app_cubit.dart';
import 'package:flutter_maps/shared/cache_helper.dart';
import 'package:flutter_maps/shared/functions.dart';
import 'package:flutter_maps/phone_auth_cubit/phone_auth_cubit.dart';
import 'package:flutter_maps/phone_auth_cubit/phone_auth_states.dart';
import 'package:flutter_maps/screens/home_screen.dart';
import 'package:flutter_maps/screens/login_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

late String otp;

class OTPScreen extends StatelessWidget {
  const OTPScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhoneAuthCubit, PhoneAuthStates>(
      listener: (context, state) {
        if (state is PhoneOTPAuthVerified) {
          CacheHelper.saveData(key: 'uId', value: state.uId).then((_) {
            phoneNumberController.clear();
            uId = state.uId;
            finalPhoneNumber = state.phoneNumber;
            bool isNewUser = state.isNewUser;
            debugPrint('State User ID ' + uId.toString());
            debugPrint('State User PhoneNumber ' + finalPhoneNumber.toString());
            debugPrint('State User isNewUser ' + isNewUser.toString());
            AppCubit.get(context).getUserData();

            if (isNewUser) {
              PhoneAuthCubit.get(context).userCreat(context,
                  finalPhoneNumber: finalPhoneNumber, uId: uId);
            } else {
              //old
              PhoneAuthCubit.get(context).updateToken(token!);
              navigateAndFinish(context, const HomeScreen());
            }
          });
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
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verify your phone number',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15.0),
                RichText(
                  text: TextSpan(
                      text: 'Enter your 6 digit code number sent to ',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        height: 1.6,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: finalPhoneNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.deepPurple,
                            height: 1.6,
                          ),
                        )
                      ]),
                ),
                const SizedBox(height: 50.0),
                PinCodeTextField(
                  appContext: context,
                  autoFocus: true,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.deepPurple,
                  length: 6,
                  obscureText: false,
                  animationType: AnimationType.scale,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    borderWidth: 1,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    activeColor: Colors.deepPurpleAccent,
                    inactiveColor: Colors.deepOrangeAccent,
                    selectedColor: Colors.deepOrangeAccent,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                  onCompleted: (code) {
                    otp = code;
                    cubit.submitOTP(otp);
                  },
                  onChanged: (_) {},
                ),
                const SizedBox(height: 30.0),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(10)),
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      cubit.submitOTP(otp);
                    },
                    child: const Text(
                      'Verify',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
