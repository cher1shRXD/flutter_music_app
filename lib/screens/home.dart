import 'package:flutter/material.dart';
import 'package:flutter_music_app/components/header.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: [
          Header(
            title: 'MUSICO',
            icon: Icons.music_note,
          )
        ],
      ),
    );
  }
}
