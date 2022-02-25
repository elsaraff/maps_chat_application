abstract class AppStates {}

class AppInitial extends AppStates {}

class GetUserLoadingState extends AppStates {}

class GetUserSuccessState extends AppStates {}

class GetUserErrorState extends AppStates {
  final String error;

  GetUserErrorState(this.error);
}

class LoggedOutSuccessful extends AppStates {}

class LoggedOutError extends AppStates {
  final String error;

  LoggedOutError(this.error);
}

/*_________________________________________________*/

class GetAllUsersSuccessState extends AppStates {}

class GetAllUsersErrorState extends AppStates {
  final String error;

  GetAllUsersErrorState(this.error);
}

/*_________________________________________________*/

class UserUpdateLoadingState extends AppStates {}

class UserUpdateSuccessState extends AppStates {}

class UserUpdateErrorState extends AppStates {
  final String error;

  UserUpdateErrorState(this.error);
}

class ProfileImagePickedSuccessState extends AppStates {}

class ProfileImagePickedErrorState extends AppStates {}

class UploadProfileImageErrorState extends AppStates {}

class RemoveProfileImageState extends AppStates {}

/*_________________________________________________*/

class SwitchState extends AppStates {}

/*_________________________________________________*/

class ShowNameEditorState extends AppStates {}

class ShowBioEditorState extends AppStates {}

/*_________________________________________________*/

class SendMessageSuccess extends AppStates {}

class SendMessageError extends AppStates {
  final String error;

  SendMessageError(this.error);
}

class GetMessageLoading extends AppStates {}

class GetMessageSuccess extends AppStates {}

/*_________________________________________________*/
