import 'dart:ui';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/app_cubit/app_cubit.dart';
import 'package:flutter_maps/app_cubit/app_states.dart';
import 'package:flutter_maps/shared/functions.dart';
import 'package:flutter_maps/screens/home_screen.dart';
import 'package:flutter_maps/shared/image_wrapper.dart';
import 'package:photo_view/photo_view.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = AppCubit.get(context);
        var userModel = AppCubit.get(context).userModel;

        //  String d = c ?? 'hello';

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_sharp,
                color: Colors.white,
              ),
              onPressed: () {
                navigateAndFinish(context, const HomeScreen());
                cubit.removeProfileImage();
              },
            ),
            title: const Text('Settings'),
            titleSpacing: 5.0,
          ),
          bottomSheet: cubit.showBottomSheet(),
          body: ConditionalBuilder(
            condition: userModel != null,
            fallback: (context) =>
                const Center(child: CircularProgressIndicator()),
            builder: (context) => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        const SizedBox(height: 170),
                        Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            CircleAvatar(
                              radius: 82,
                              backgroundColor: Colors.grey,
                              child: InkWell(
                                child: CircleAvatar(
                                    radius: 80,
                                    backgroundImage: (profileImage == null
                                            ? NetworkImage(userModel!.image!)
                                            : FileImage(profileImage!))
                                        as ImageProvider),
                                onTap: () {
                                  navigateTo(
                                    context,
                                    ImageWrapper(
                                      imageProvider:
                                          NetworkImage(userModel!.image!),
                                      backgroundDecoration: const BoxDecoration(
                                          color: Colors.black),
                                      minScale:
                                          PhotoViewComputedScale.contained * 1,
                                      maxScale:
                                          PhotoViewComputedScale.covered * 2,
                                      loadingBuilder: (context, event) {
                                        if (event == null) {
                                          return const Center(
                                            child: Text("Loading"),
                                          );
                                        }
                                        final value = event
                                                .cumulativeBytesLoaded /
                                            (event.expectedTotalBytes ??
                                                event.cumulativeBytesLoaded);

                                        final percentage =
                                            (100 * value).floor();
                                        return Center(
                                          child: Column(
                                            children: [
                                              const CircularProgressIndicator(),
                                              Text("$percentage%"),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 5.0, bottom: 10),
                              child: CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                radius: 20,
                                child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      cubit.getProfileImage();
                                    },
                                    icon: const Icon(
                                      Icons.add_a_photo_rounded,
                                      size: 20,
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (profileImage != null)
                      Column(
                        children: [
                          Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.deepPurple),
                              child: MaterialButton(
                                child: const Text('Update Profile Picture',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  cubit.uploadProfileImage(
                                      name: cubit.nameController.text,
                                      bio: cubit.bioController.text);
                                },
                              )),
                          const SizedBox(height: 5),
                          if (state is UserUpdateLoadingState)
                            const LinearProgressIndicator(),
                        ],
                      ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () {
                        cubit.showNameBottomSheet();
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.deepPurple),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Name',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black45)),
                                    const SizedBox(height: 5),
                                    Text(userModel!.name!,
                                        style: const TextStyle(
                                            fontSize: 22, color: Colors.black)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.edit_outlined,
                                  color: Colors.deepPurple),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () {
                        cubit.showBioBottomSheet();
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.info, color: Colors.deepPurple),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Bio',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black45)),
                                    const SizedBox(height: 5),
                                    Text(userModel.bio!,
                                        style: const TextStyle(
                                            fontSize: 22, color: Colors.black)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.edit_outlined,
                                  color: Colors.deepPurple),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () {
                        HapticFeedback.vibrate();
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.call, color: Colors.deepPurple),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Phone',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black45)),
                                    const SizedBox(height: 5),
                                    Text(userModel.phone!,
                                        style: const TextStyle(
                                            fontSize: 22, color: Colors.black)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        const Expanded(
                            flex: 4,
                            child: Text(
                              'Subscribe our Announcement',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )),
                        const SizedBox(width: 5),
                        Expanded(
                          flex: 1,
                          child: CupertinoSwitch(
                            activeColor: Colors.deepPurple[200],
                            onChanged: (value) {
                              cubit.switchValue();
                              debugPrint(value.toString());
                            },
                            value: cubit.announcement,
                          ),
                        ),
                      ],
                    )
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
