import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/app_cubit/app_cubit.dart';
import 'package:flutter_maps/app_cubit/app_states.dart';
import 'package:flutter_maps/chats/chat_details_screen.dart';
import 'package:flutter_maps/models/user_model.dart';
import 'package:flutter_maps/screens/home_screen.dart';
import 'package:flutter_maps/shared/functions.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var users = AppCubit.get(context).allUsers;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_sharp,
                color: Colors.white,
              ),
              onPressed: () {
                navigateAndFinish(context, const HomeScreen());
              },
            ),
            title: const Text('Chats'),
            titleSpacing: 5.0,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConditionalBuilder(
                condition: users.isNotEmpty,
                builder: (context) => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) =>
                        buildProfileItem(users[index], context, isChat: true),
                    separatorBuilder: (context, index) => Container(
                          color: Colors.deepPurple,
                          width: double.infinity,
                          height: 0.5,
                        ),
                    itemCount: users.length),
                fallback: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget buildProfileItem(
  UserModel model,
  context, {
  isChat = false,
}) =>
    InkWell(
      onTap: () {
        if (isChat) {
          navigateTo(context, ChatDetailsScreen(userModel: model));
        } else {
          //navigateTo(context, ProfileDetailsScreen(userModel: model));
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            CircleAvatar(
                radius: 25, backgroundImage: NetworkImage(model.image!)),
            const SizedBox(width: 15),
            Text(model.name!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
