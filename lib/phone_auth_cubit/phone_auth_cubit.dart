import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/shared/functions.dart';
import 'package:flutter_maps/phone_auth_cubit/phone_auth_states.dart';
import 'package:flutter_maps/screens/edit_profile.dart';
import 'package:flutter_maps/models/user_model.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthStates> {
  PhoneAuthCubit() : super(PhoneAuthInitial());

  late String verificationId;

  static PhoneAuthCubit get(context) => BlocProvider.of(context);

  Future<void> submitPhoneNumber(String phoneNumber) async {
    emit(PhoneAuthLoading());
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 15),
      codeSent: (String verificationId, int? resendToken) {
        debugPrint('codeSent');
        this.verificationId = verificationId;
        emit(PhoneSubmitted());
      },
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint('verificationCompleted');
        await signIn(credential);
      },
      verificationFailed: (FirebaseAuthException error) {
        debugPrint('verificationFailed');
        debugPrint(error.toString());
        emit(PhoneAuthError(error.toString()));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('codeAutoRetrievalTimeout');
      },
    );
  }

  Future<void> submitOTP(String otpCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );
    await signIn(credential);
  }

  Future<void> signIn(PhoneAuthCredential credential) async {
    await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      emit(PhoneOTPAuthVerified(
          value.user!.uid.toString(),
          value.user!.phoneNumber.toString(),
          value.additionalUserInfo!.isNewUser));
    }).catchError((error) {
      debugPrint(error.toString());
      emit(PhoneAuthError(error.toString()));
    });
  }

  User getLoggedInUser() {
    User firebaseUser = FirebaseAuth.instance.currentUser!;
    return firebaseUser;
  }

  void userCreat(
    BuildContext context, {
    required finalPhoneNumber,
    required uId,
  }) {
    UserModel model = UserModel(
      phone: finalPhoneNumber,
      uId: uId,
      name: 'user',
      bio: 'write your bio ..',
      announcement: false,
      image:
          'https://www.minervastrategies.com/wp-content/uploads/2016/03/default-avatar.jpg',
    );

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set(model.toMap())
        .then((value) {
      emit(CreatUserSuccessState());
      navigateAndFinish(context, const EditProfileScreen());
      FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .collection('token')
          .doc(uId)
          .set({'token': token});
    }).catchError((error) {
      emit(CreatUserErrorState(error.toString()));
    });
  }

  void updateToken(String token) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('token')
        .doc(uId)
        .update({'token': token}).then((value) {
      emit(UpdateTokenSuccessState());
    }).catchError((error) {
      emit(UpdateTokenErrorState(error.toString()));
    });
  }
}
