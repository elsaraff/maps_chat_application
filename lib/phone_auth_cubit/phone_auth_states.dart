abstract class PhoneAuthStates {}

class PhoneAuthInitial extends PhoneAuthStates {}

class PhoneAuthLoading extends PhoneAuthStates {}

class PhoneAuthError extends PhoneAuthStates {
  final String error;

  PhoneAuthError(this.error);
}

class PhoneSubmitted extends PhoneAuthStates {}

class PhoneOTPAuthVerified extends PhoneAuthStates {
  final String uId;
  final String phoneNumber;
  final bool isNewUser;

  PhoneOTPAuthVerified(this.uId, this.phoneNumber, this.isNewUser);
}

class CreatUserSuccessState extends PhoneAuthStates {}

class CreatUserErrorState extends PhoneAuthStates {
  final String error;

  CreatUserErrorState(this.error);
}

class UpdateTokenSuccessState extends PhoneAuthStates {}

class UpdateTokenErrorState extends PhoneAuthStates {
  final String error;

  UpdateTokenErrorState(this.error);
}
