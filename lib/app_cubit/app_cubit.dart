import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/app_cubit/app_states.dart';
import 'package:flutter_maps/shared/cache_helper.dart';
import 'package:flutter_maps/chats/dio_chat.dart';
import 'package:flutter_maps/shared/functions.dart';
import 'package:flutter_maps/models/message_model.dart';
import 'package:flutter_maps/models/user_model.dart';
import 'package:image_picker/image_picker.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitial());

  static AppCubit get(context) => BlocProvider.of(context);

  UserModel? userModel;

  void getUserData() {
    emit(GetUserLoadingState());
    FirebaseFirestore.instance.collection('users').doc(uId).get().then((value) {
      userModel = UserModel.fromJson(value.data()!);
      emit(GetUserSuccessState());
      getSwitchValue();
    }).catchError((error) {
      debugPrint(error.toString());
      emit(GetUserErrorState(error.toString()));
    });
  }

  List<UserModel> allUsers = [];

  void getAllUsers() {
    if (allUsers.isEmpty) {
      FirebaseFirestore.instance.collection('users').get().then((value) {
        for (var element in value.docs) {
          if (element.data()['uId'] != userModel!.uId) {
            allUsers.add(UserModel.fromJson(element.data()));
          }
        }
        emit(GetAllUsersSuccessState());
      }).catchError((error) {
        emit(GetAllUsersErrorState(error.toString()));
        debugPrint(error.toString());
      });
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut().then((value) {
      CacheHelper.removeData(key: 'uId');
      emit(LoggedOutSuccessful());
    }).catchError((error) {
      emit(LoggedOutError(error.toString()));
    });
  }

  /*_________________________________________________*/

  void updateUser({
    required String name,
    required String bio,
    bool? announcement,
    String? image,
  }) {
    UserModel model = UserModel(
      name: name,
      bio: bio,
      phone: userModel!.phone,
      uId: userModel!.uId,
      image: image ?? userModel!.image,
      announcement: announcement ?? userModel!.announcement,
    );
    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .update(model.toMap())
        .then((value) {
      emit(UserUpdateSuccessState());
      getUserData();
    }).catchError((error) {
      emit(UserUpdateErrorState(error.toString()));
    });
  }

  var picker = ImagePicker();

  Future<void> getProfileImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      emit(ProfileImagePickedSuccessState());
    } else {
      debugPrint('No image selected.');
      emit(ProfileImagePickedErrorState());
    }
  }

  void uploadProfileImage({
    required String name,
    required String bio,
  }) {
    emit(UserUpdateLoadingState());
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(profileImage!.path).pathSegments.last}')
        .putFile(profileImage!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        updateUser(name: name, bio: bio, image: value);
        removeProfileImage();
      }).catchError((error) {
        emit(UploadProfileImageErrorState());
      });
    }).catchError((error) {
      emit(UploadProfileImageErrorState());
    });
  }

  void removeProfileImage() {
    profileImage = null;
    emit(RemoveProfileImageState());
  }

  /*_________________________________________________*/

  bool announcement = false;

  void getSwitchValue() {
    FirebaseFirestore.instance.collection('users').doc(uId).get().then((value) {
      announcement = value.data()!['announcement'];
    });
  }

  void switchValue() {
    FirebaseFirestore.instance.collection('users').doc(uId).get().then((value) {
      announcement = value.data()!['announcement'];

      if (announcement == false) {
        FirebaseMessaging.instance
            .subscribeToTopic('announcement')
            .then((value) {
          updateUser(
            announcement: true,
            name: userModel!.name!,
            bio: userModel!.bio!,
          );
        });
      }
      if (announcement == true) {
        FirebaseMessaging.instance
            .unsubscribeFromTopic('announcement')
            .then((value) {
          updateUser(
            announcement: false,
            name: userModel!.name!,
            bio: userModel!.bio!,
          );
        });
      }
      announcement = !announcement;
      emit(SwitchState());
    });
  }

  /*_________________________________________________*/

  bool showNameEditor = false;
  bool showBioEditor = false;

  showNameBottomSheet() {
    showNameEditor = !showNameEditor;
    emit(ShowNameEditorState());
  }

  showBioBottomSheet() {
    showBioEditor = !showBioEditor;
    emit(ShowBioEditorState());
  }

  var nameController = TextEditingController();
  var bioController = TextEditingController();

  Widget? showBottomSheet() {
    nameController.text = userModel!.name!;
    bioController.text = userModel!.bio!;

    if (showNameEditor) {
      return BottomSheet(
        onClosing: () {},
        builder: (context) {
          return Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter your Name'),
                  const SizedBox(height: 25),
                  TextFormField(
                    autofocus: true,
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Name is empty ";
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: const Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          onPrimary: Colors.white,
                          primary: Colors.deepPurple,
                        ),
                        onPressed: () {
                          showNameBottomSheet();
                        },
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        child: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          onPrimary: Colors.white,
                          primary: Colors.deepPurple,
                        ),
                        onPressed: () {
                          if (nameController.text != '') {
                            updateUser(
                                name: nameController.text,
                                bio: bioController.text);
                            showNameBottomSheet();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    if (showBioEditor) {
      return BottomSheet(
        onClosing: () {
          HapticFeedback.vibrate();
        },
        builder: (context) {
          return Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter your Bio'),
                  const SizedBox(height: 25),
                  TextFormField(
                    autofocus: true,
                    controller: bioController,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info),
                      labelText: 'Bio',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: const Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          onPrimary: Colors.white,
                          primary: Colors.deepPurple,
                        ),
                        onPressed: () {
                          showBioBottomSheet();
                        },
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        child: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          onPrimary: Colors.white,
                          primary: Colors.deepPurple,
                        ),
                        onPressed: () {
                          if (bioController.text != '') {
                            updateUser(
                                name: nameController.text,
                                bio: bioController.text);
                            showBioBottomSheet();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  /*_________________________________________________*/

  void sendMessage({
    required String receiverId,
    required String dateTime,
    required String text,
    required String time,
  }) {
    MessageModel messageModel = MessageModel(
      senderId: userModel!.uId!,
      receiverId: receiverId,
      dateTime: dateTime,
      time: time,
      text: text,
    );
    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .add(messageModel.toMap())
        .then((value) {
      emit(SendMessageSuccess());
    }).catchError((error) {
      emit(SendMessageError(error.toString()));
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userModel!.uId)
        .collection('messages')
        .add(messageModel.toMap())
        .then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .collection('token')
          .get()
          .then((value) {
        var element = value.docs.elementAt(0);
        var receiverToken = element.data()['token'];
        //debugPrint(receiverToken.toString());
        //debugPrint(text);
        //debugPrint(userModel!.name);
        messageNotification(
            receiverToken: receiverToken,
            message: text,
            sender: userModel!.name);
      });
      emit(SendMessageSuccess());
    }).catchError((error) {
      emit(SendMessageError(error.toString()));
    });
  }

  List<MessageModel> messages = [];

  void getMessages({
    required String receiverId,
  }) {
    emit(GetMessageLoading());

    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .orderBy('time')
        .snapshots()
        .listen((event) {
      messages = [];
      for (var element in event.docs) {
        messages.add(MessageModel.fromJson(element.data()));
      }
      emit(GetMessageSuccess());
    });
  }

  /*_________________________________________________*/

}
