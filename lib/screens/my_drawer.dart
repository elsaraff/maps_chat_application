import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/app_cubit/app_cubit.dart';
import 'package:flutter_maps/app_cubit/app_states.dart';
import 'package:flutter_maps/chats/chats_screen.dart';
import 'package:flutter_maps/screens/edit_profile.dart';
import 'package:flutter_maps/screens/login_screen.dart';
import 'package:flutter_maps/shared/functions.dart';
import 'package:flutter_maps/shared/image_wrapper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  Widget buildDrawerListItems({
    required IconData leadingIcon,
    required String title,
    Widget? trailing,
    Function()? onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(leadingIcon, color: Colors.deepPurple),
      title: Text(title),
      trailing:
          trailing ?? const Icon(Icons.arrow_forward, color: Colors.deepPurple),
      onTap: onTap,
    );
  }

  Widget buildDrawerListItemsDivider() {
    return const Divider(
      height: 0,
      thickness: 1,
      indent: 18,
      endIndent: 24,
    );
  }

  void _launchURL(String url) async {
    debugPrint(url);
    if (!await launch(url)) {
      throw 'Could not launch $url';
    }
  }

  Widget buildIcon(IconData icon, String url) {
    return InkWell(
      onTap: () {
        _launchURL(url);
      },
      child: Icon(icon, color: Colors.deepPurple, size: 35),
    );
  }

  Widget buildSocialMediaIcons() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16),
      child: Row(
        children: [
          buildIcon(FontAwesomeIcons.facebook,
              'https://www.facebook.com/m7md.elsaraff/'),
          const SizedBox(width: 6),
          buildIcon(FontAwesomeIcons.whatsapp,
              'https://api.whatsapp.com/send?phone=201124609150'),
          const SizedBox(width: 6),
          buildIcon(FontAwesomeIcons.github, 'https://github.com/elsaraff'),
          const SizedBox(width: 6),
          buildIcon(FontAwesomeIcons.linkedin,
              'https://www.linkedin.com/in/mohamedelsaraff/'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var userModel = AppCubit.get(context).userModel;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Column(
                children: [
                  SizedBox(
                      height: 300,
                      child: DrawerHeader(
                          decoration:
                              BoxDecoration(color: Colors.deepPurple[100]),
                          child: ConditionalBuilder(
                            condition: userModel != null,
                            builder: (context) => Column(children: [
                              Container(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    80, 3, 80, 3),
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.deepPurple[100]),
                                child: InkWell(
                                  child: CircleAvatar(
                                    radius: 80,
                                    backgroundImage:
                                        NetworkImage(userModel!.image!),
                                  ),
                                  onTap: () {
                                    navigateTo(
                                      context,
                                      ImageWrapper(
                                        imageProvider:
                                            NetworkImage(userModel.image!),
                                        backgroundDecoration:
                                            const BoxDecoration(
                                                color: Colors.black),
                                        minScale:
                                            PhotoViewComputedScale.contained *
                                                1,
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
                              const SizedBox(height: 8),
                              Text(
                                userModel.name!,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(userModel.phone!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                  )),
                            ]),
                            fallback: (context) => const Center(
                                child: CircularProgressIndicator()),
                          ))),
                  buildDrawerListItems(
                    leadingIcon: Icons.chat_outlined,
                    title: 'Chats',
                    onTap: () {
                      AppCubit.get(context).getAllUsers();
                      navigateAndFinish(context, const ChatsScreen());
                    },
                  ),
                  buildDrawerListItemsDivider(),
                  buildDrawerListItems(
                    leadingIcon: Icons.history,
                    title: 'Places History',
                    onTap: () {},
                  ),
                  buildDrawerListItemsDivider(),
                  buildDrawerListItems(
                    leadingIcon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      navigateAndFinish(context, const EditProfileScreen());
                    },
                  ),
                  buildDrawerListItemsDivider(),
                  buildDrawerListItems(
                    leadingIcon: Icons.help,
                    title: 'Help',
                    onTap: () {},
                  ),
                  buildDrawerListItemsDivider(),
                  buildDrawerListItems(
                    leadingIcon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      AppCubit.get(context).signOut();
                      navigateAndFinish(context, LoginScreen());
                    },
                    trailing: const SizedBox(),
                  ),
                  const SizedBox(height: 230),
                  Row(
                    children: [
                      const Expanded(child: ListTile(title: Text('Follow us'))),
                      buildSocialMediaIcons(),
                      const SizedBox(width: 6)
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
