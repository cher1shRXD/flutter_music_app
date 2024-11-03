import 'package:flutter/material.dart';
import 'package:flutter_music_app/components/header.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: [
          Header(
            title: 'Profile',
            icon: Icons.music_note,
          )
        ],
      ),
    );
  }
}
